include("cyberp/gamemode/core/player/sh_player_meta.lua")
include("cyberp/gamemode/core/inventory/sh_inventory.lua")
include("cyberp/gamemode/core/player/sh_heat.lua")

CybeRp.Player = CybeRp.Player or {}

local AUTOSAVE_INTERVAL = 60
local STAMINA_TICK = 0.25
local DIRTY_SYNC_INTERVAL = 1

local function networkingAvailable(fnName)
    return CybeRp.Networking and CybeRp.Networking[fnName]
end

local function pushPlayerData(ply, payload)
    if networkingAvailable("PushPlayerData") then
        CybeRp.Networking.PushPlayerData(ply, payload)
        return true
    end

    -- Intentionally avoid sending data directly; the Networking Agent owns transport.
    return false
end

local function pushInventory(ply, payload)
    if networkingAvailable("PushInventory") then
        CybeRp.Networking.PushInventory(ply, payload)
        return true
    end
    return false
end

function CybeRp.Player.MarkDirty(ply, field)
    if not IsValid(ply) then return end
    local sid = ply:SteamID64()
    CybeRp.Player._dirty = CybeRp.Player._dirty or {}
    CybeRp.Player._dirty[sid] = CybeRp.Player._dirty[sid] or {}
    CybeRp.Player._dirty[sid][field or "all"] = true
end

function CybeRp.Player.BuildDefaultData(ply)
    local base = table.Copy(CybeRp.Player.Defaults)
    base.id = ply:SteamID64()
    return base
end

local function mergeData(base, stored)
    for k, v in pairs(stored or {}) do
        if istable(v) then
            base[k] = base[k] or {}
            mergeData(base[k], v)
        else
            base[k] = v
        end
    end
    return base
end

function CybeRp.Player.ApplyData(ply, data)
    local merged = mergeData(CybeRp.Player.BuildDefaultData(ply), data)
    ply.CybeData = merged

    -- Keep a live inventory copy in the inventory system.
    if merged.inventory then
        if CybeRp.Inventory and CybeRp.Inventory.ApplyLoadedInventory then
            CybeRp.Inventory.ApplyLoadedInventory(ply, merged.inventory)
        else
            ply.CybeInventory = table.Copy(merged.inventory)
        end
    end

    CybeRp.Player.RecalculateDerived(ply)
end

function CybeRp.Player.RecalculateDerived(ply)
    if not IsValid(ply) then return end
    local data = ply:GetCybeData()

    -- Cyberware bonuses can alter stamina/health.
    if CybeRp.Cyberware and CybeRp.Cyberware.ApplyBonuses then
        CybeRp.Cyberware.ApplyBonuses(ply, data)
    end

    ply:SetMaxHealth(data.health or 100)
    ply:SetHealth(math.Clamp(data.health or 100, 1, ply:GetMaxHealth()))
    ply:SetArmor(math.max(0, data.armor or 0))

    CybeRp.Player.ApplyMovement(ply)
end

function CybeRp.Player.ApplyMovement(ply)
    local baseWalk = 180
    local baseRun = 280

    if ply:HasCyberware("neural_boost") then
        baseRun = baseRun + 20
    end

    ply:SetWalkSpeed(baseWalk)
    ply:SetRunSpeed(ply.CybeExhausted and baseWalk or baseRun)
end

function CybeRp.Player.Sync(ply, fields)
    if not IsValid(ply) then return end
    local payload

    if istable(fields) then
        payload = fields
    elseif isstring(fields) then
        payload = { [fields] = ply:GetCybeData()[fields] }
    elseif fields == nil then
        payload = ply:GetCybeData()
    end

    if payload then
        pushPlayerData(ply, payload)
    end
end

function CybeRp.Player.FlushDirty(ply)
    if not CybeRp.Player._dirty or not IsValid(ply) then return end
    local bucket = CybeRp.Player._dirty[ply:SteamID64()]
    if not bucket then return end

    if bucket["all"] then
        CybeRp.Player.Sync(ply)
    else
        local payload = {}
        for field in pairs(bucket) do
            payload[field] = ply:GetCybeData()[field]
        end
        CybeRp.Player.Sync(ply, payload)
    end

    CybeRp.Player._dirty[ply:SteamID64()] = nil
end

function CybeRp.Player.Save(ply, silent)
    if not IsValid(ply) or not ply.CybeData then return end
    local sid = ply:SteamID64()

    -- Keep the inventory mirror inside the player data before persisting.
    if CybeRp.Inventory and CybeRp.Inventory.Get then
        ply.CybeData.inventory = CybeRp.Inventory.Get(ply)
    end

    if CybeRp.DB and CybeRp.DB.SaveCharacter then
        CybeRp.DB.SaveCharacter(sid, ply.CybeData)
    end

    if CybeRp.Inventory and CybeRp.Inventory.Save then
        CybeRp.Inventory.Save(ply)
    end

    CybeRp.Player.FlushDirty(ply)

    if not silent and CybeRp.Config and CybeRp.Config.Debug then
        print(("[CybeRp] Saved data for %s"):format(ply:Nick()))
    end
end

function CybeRp.Player.Load(ply)
    local sid = ply:SteamID64()
    local stored = {}
    local storedInv = {}
    local isNew = false

    if CybeRp.DB and CybeRp.DB.LoadCharacter then
        stored = CybeRp.DB.LoadCharacter(sid) or {}
        if not stored or next(stored) == nil then
            isNew = true
            stored = {
                id = sid,
                credits = CybeRp.Config and CybeRp.Config.StartingCredits or CybeRp.Player.Defaults.credits or 500,
            }
        end
    end

    if CybeRp.DB and CybeRp.DB.LoadInventory then
        storedInv = CybeRp.DB.LoadInventory(sid) or {}
    end

    stored.inventory = storedInv

    CybeRp.Player.ApplyData(ply, stored)
    ply.CybeLoaded = true

    hook.Run("PlayerLoadedData", ply, ply.CybeData)
    CybeRp.Player.Sync(ply)
    if CybeRp.Inventory then
        pushInventory(ply, CybeRp.Inventory.Get(ply))
    end
end

local function isSprinting(ply)
    return ply:KeyDown(IN_SPEED) and ply:GetVelocity():Length2D() > 120
end

function CybeRp.Player.UpdateStamina(ply, dt)
    if not IsValid(ply) or not ply.CybeData then return end
    local data = ply:GetCybeData()
    local regen, drain = data.staminaRegen or 8, data.staminaDrain or 14

    if isSprinting(ply) then
        data.stamina = math.max(0, data.stamina - (drain * dt))
        if data.stamina <= 0 and not ply.CybeExhausted then
            ply.CybeExhausted = true
            ply:SetRunSpeed(ply:GetWalkSpeed())
        end
    else
        data.stamina = math.min(data.staminaMax, data.stamina + (regen * dt))
        if ply.CybeExhausted and data.stamina >= data.staminaMax * 0.35 then
            ply.CybeExhausted = false
            CybeRp.Player.ApplyMovement(ply)
        end
    end

    CybeRp.Player.MarkDirty(ply, "stamina")
end

hook.Add("Think", "CybeRp_StaminaTick", function()
    local now = CurTime()
    CybeRp.Player._nextStamina = CybeRp.Player._nextStamina or 0
    if now < CybeRp.Player._nextStamina then return end

    CybeRp.Player._nextStamina = now + STAMINA_TICK
    for _, ply in ipairs(player.GetHumans()) do
        if ply:IsCybeLoaded() then
            CybeRp.Player.UpdateStamina(ply, STAMINA_TICK)
        end
    end
end)

hook.Add("PlayerInitialSpawn", "CybeRp_PlayerInitialSpawn", function(ply)
    CybeRp.Player.Load(ply)
end)

hook.Add("PlayerSpawn", "CybeRp_PlayerSpawn", function(ply)
    if not ply:IsCybeLoaded() then return end
    CybeRp.Player.RecalculateDerived(ply)

    if CybeRp.Jobs and CybeRp.Jobs.ApplySpawnLoadout then
        CybeRp.Jobs.ApplySpawnLoadout(ply)
    end
end)

hook.Add("PlayerDisconnected", "CybeRp_SaveOnLeave", function(ply)
    CybeRp.Player.Save(ply, true)
end)

timer.Create("CybeRp_AutoSave", AUTOSAVE_INTERVAL, 0, function()
    for _, ply in ipairs(player.GetHumans()) do
        if ply:IsCybeLoaded() then
            CybeRp.Player.Save(ply, true)
        end
    end
end)

timer.Create("CybeRp_DirtySync", DIRTY_SYNC_INTERVAL, 0, function()
    if not CybeRp.Player._dirty then return end
    for _, ply in ipairs(player.GetHumans()) do
        if ply:IsCybeLoaded() then
            CybeRp.Player.FlushDirty(ply)
        end
    end
end)


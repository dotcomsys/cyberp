-- CybeRp Networking - server handlers
-- Responsible for all net.Start/net.Send usage.

if not SERVER then return end

CybeRp = CybeRp or {}
CybeRp.Networking = CybeRp.Networking or {}
CybeRp.Net = CybeRp.Net or {}

local NET = CybeRp.NET
local Net = CybeRp.Networking
local Api = CybeRp.Net

local function playerSnapshot(ply)
    if not IsValid(ply) then return {} end
    local data = ply:GetCybeData and ply:GetCybeData() or {}
    return {
        id = ply:SteamID64(),
        credits = ply.GetCredits and ply:GetCredits() or data.credits,
        job = data.job,
        faction = data.faction,
        health = data.health or ply:Health(),
        armor = data.armor or ply:Armor(),
    }
end

local function inventorySnapshot(ply)
    if CybeRp.Inventory and CybeRp.Inventory.Get then
        return CybeRp.Inventory.Get(ply) or {}
    end
    return ply.CybeInventory or {}
end

local function cyberwareSnapshot(ply)
    local data = ply:GetCybeData and ply:GetCybeData() or {}
    return data.cyberware or {}
end

local function isValidItemId(id)
    return isstring(id) and id ~= "" and #id <= 64
end

local function isValidCyberId(id)
    return isstring(id) and id ~= "" and #id <= 64
end

local function sendMessage(msgName, target, payload, codec)
    if not msgName then return false end

    net.Start(msgName)
    local ok = Net.WritePayload(payload, codec)
    if not ok then
        ErrorNoHalt(string.format("[CybeRp][Net] Failed to encode payload for %s\n", msgName))
        return false
    end

    if istable(target) then
        net.Send(target)
    elseif IsValid(target) then
        net.Send(target)
    else
        net.Broadcast()
    end

    return true
end

-- Push a player stat snapshot (full or partial).
function Net.PushPlayerData(target, payload)
    return sendMessage(NET.PLAYER_DATA, target, payload, "pon")
end

-- Sync inventory snapshot or delta to a single player.
function Net.PushInventory(target, payload)
    return sendMessage(NET.INVENTORY_UPDATE, target, payload, "pon")
end

-- Sync cyberware snapshot or delta.
function Net.PushCyberware(target, payload)
    return sendMessage(NET.CYBERWARE_UPDATE, target, payload, "pon")
end

-- Notify job/faction/role changes.
function Net.PushJobUpdate(target, payload)
    return sendMessage(NET.JOB_UPDATE, target, payload, "json")
end

-- Broadcast world events (alarms, wars, police alerts).
function Net.BroadcastWorldEvent(eventName, payload)
    payload = payload or {}
    payload.event = payload.event or eventName
    payload.when = payload.when or CurTime()

    return sendMessage(NET.WORLD_EVENT, nil, payload, "json")
end

-- Convenience for directed alerts (still uses WORLD_EVENT pipe).
function Net.SendAlert(target, kind, payload)
    payload = payload or {}
    payload.event = payload.event or kind or "alert"
    payload.scope = payload.scope or (IsValid(target) and "direct" or "broadcast")
    payload.when = payload.when or CurTime()

    return sendMessage(NET.WORLD_EVENT, target, payload, "json")
end

function Net.PushWorldAlert(target, payload)
    payload = payload or {}
    payload.when = payload.when or CurTime()
    return sendMessage(NET.WORLD_ALERT, target, payload, "json")
end

function Net.PushHackResult(target, payload)
    return sendMessage(NET.HACK_RESULT, target, payload or {}, "json")
end

function Net.PushVendorStock(target, payload)
    return sendMessage(NET.VENDOR_STOCK, target, payload or {}, "json")
end

function Net.PushHeat(target, payload)
    return sendMessage(NET.HEAT_SYNC, target, payload or {}, "json")
end

function Net.PushArrest(target, payload)
    return sendMessage(NET.ARREST_SYNC, target, payload or {}, "json")
end

function Net.PushContracts(target, payload)
    return sendMessage(NET.CONTRACTS_SYNC, target, payload or {}, "json")
end

-- Server -> client RPC helper. Clients dispatch via hook: CybeRp_RPC_<method>.
function Net.SendRPC(target, method, args)
    if not isstring(method) or method == "" then
        return false
    end

    local payload = {
        method = method,
        args = args or {},
        ts = CurTime()
    }

    return sendMessage(NET.RPC, target, payload, "pon")
end

-- Compatibility wrappers per roadmap tasks (Phase 2.1.2)
function Api.SendPlayerFullState(ply)
    if not IsValid(ply) then return end
    return Net.PushPlayerData(ply, playerSnapshot(ply))
end

function Api.BroadcastInventory(ply)
    if not IsValid(ply) then return end
    return Net.PushInventory(ply, inventorySnapshot(ply))
end

function Api.BroadcastCyberware(ply)
    if not IsValid(ply) then return end
    return Net.PushCyberware(ply, cyberwareSnapshot(ply))
end

-- Client -> server handlers (validated)
net.Receive(NET.USE_ITEM, function(_, ply)
    local itemId = net.ReadString()
    if not isValidItemId(itemId) then return end
    if not IsValid(ply) then return end
    if not CybeRp.Inventory or not CybeRp.Inventory.Use then return end
    CybeRp.Inventory.Use(ply, itemId)
end)

net.Receive(NET.DROP_ITEM, function(_, ply)
    local itemId = net.ReadString()
    if not isValidItemId(itemId) then return end
    if not IsValid(ply) then return end
    if not CybeRp.Inventory or not CybeRp.Inventory.Drop then return end
    CybeRp.Inventory.Drop(ply, itemId)
end)

net.Receive(NET.ACTIVATE_CYBERWARE, function(_, ply)
    local cyberId = net.ReadString()
    if not isValidCyberId(cyberId) then return end
    if not IsValid(ply) then return end
    if not CybeRp.Cyberware or not CybeRp.Cyberware.Activate then return end
    CybeRp.Cyberware.Activate(ply, cyberId)
end)

net.Receive(NET.VENDOR_BUY, function(_, ply)
    local itemId = net.ReadString()
    local amount = net.ReadUInt(8)
    if not CybeRp.Economy or not CybeRp.Economy.HandleBuy then return end
    CybeRp.Economy.HandleBuy(ply, itemId, amount)
end)

net.Receive(NET.VENDOR_SELL, function(_, ply)
    local itemId = net.ReadString()
    local amount = net.ReadUInt(8)
    if not CybeRp.Economy or not CybeRp.Economy.HandleSell then return end
    CybeRp.Economy.HandleSell(ply, itemId, amount)
end)

-- Hack request: client asks to start a hack (server validates and kicks off minigame data)
net.Receive(NET.HACK_REQUEST, function(_, ply)
    local ent = net.ReadEntity()
    local targetId = net.ReadString()
    if not IsValid(ply) or not IsValid(ent) then return end
    if not CybeRp.World or not CybeRp.World.BeginTerminalHack then return end

    local meta = {
        id = targetId ~= "" and targetId or ent:GetNWString("CybeRp_TerminalId", "terminal_generic"),
        hackTime = 6,
        cooldown = 75,
        difficulty = 0.5,
        district = ent:GetNWString("CybeRp_TerminalDistrict", "unknown"),
        maxDistance = 160,
    }
    CybeRp.World:BeginTerminalHack(ply, ent, meta, true) -- true to signal minigame kickoff
end)

net.Receive(NET.CONTRACT_ACCEPT, function(_, ply)
    local contractId = net.ReadString()
    if CybeRp.World and CybeRp.World.AcceptContract then
        CybeRp.World:AcceptContract(ply, contractId ~= "" and contractId or "deliver_datacube")
    end
end)

net.Receive(NET.CONTRACT_COMPLETE, function(_, ply)
    local contractId = net.ReadString()
    if CybeRp.World and CybeRp.World.CompleteContract then
        CybeRp.World:CompleteContract(ply, contractId)
    end
end)

-- Receive hack minigame completion (true = success, false = failure)
net.Receive(NET.HACK_RESULT, function(_, ply)
    local success = net.ReadBool()
    if not CybeRp.World or not CybeRp.World.Terminals then return end
    local active = CybeRp.World.Terminals.active[ply]
    if not active or not IsValid(active.ent) then return end

    if success then
        CybeRp.World:FinishTerminalHack(ply, active.ent, active.meta)
    else
        CybeRp.World:OnTerminalBreach(ply, active.ent, active.meta)
    end
    CybeRp.World.Terminals.active[ply] = nil
end)



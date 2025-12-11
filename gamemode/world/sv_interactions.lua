CybeRp = CybeRp or {}
CybeRp.World = CybeRp.World or {}

local World = CybeRp.World

World.Interactables = World.Interactables or {}

local function debugLog(msg, ...)
    if CybeRp.Config and CybeRp.Config.Debug then
        print(("[CybeRp][Interact] " .. msg):format(...))
    end
end

function World:RegisterInteractable(ent, meta)
    if not IsValid(ent) or not meta then return end
    World.Interactables[ent] = meta
    ent:CallOnRemove("CybeRpWorld_InteractableCleanup", function()
        World.Interactables[ent] = nil
    end)
end

local function setupStaticEntity(ent)
    ent:SetUseType(SIMPLE_USE)
    ent:SetMoveType(MOVETYPE_NONE)
    ent:SetSolid(SOLID_VPHYSICS)
end

function World:SpawnTerminal(id, data)
    local ent = ents.Create("prop_dynamic")
    if not IsValid(ent) then return end

    ent:SetModel(data.model or "models/props_lab/reciever_cart.mdl")
    ent:SetPos(data.pos)
    ent:SetAngles(data.ang or Angle(0, 0, 0))
    ent:Spawn()
    setupStaticEntity(ent)

    World:RegisterInteractable(ent, {
        type = "terminal",
        id = id,
        district = data.district,
        difficulty = data.difficulty or 0.55,
        cooldown = data.cooldown or 75,
        hackTime = data.hackTime or 6,
    })

    debugLog("Spawned terminal %s", id)
    return ent
end

function World:SpawnDataCache(id, data)
    local ent = ents.Create("prop_physics")
    if not IsValid(ent) then return end

    ent:SetModel(data.model or "models/props_lab/lockerdoorleft.mdl")
    ent:SetPos(data.pos)
    ent:SetAngles(data.ang or Angle(0, 0, 0))
    ent:Spawn()
    setupStaticEntity(ent)

    World:RegisterInteractable(ent, {
        type = "data_cache",
        id = id,
        reward = data.reward or { intel = 1 },
        cooldown = data.cooldown or 45,
        lastUsed = 0,
        district = data.district,
    })

    debugLog("Spawned data cache %s", id)
    return ent
end

local function tryUseTerminal(ply, ent, meta)
    if not World.BeginTerminalHack then
        return
    end

    return World:BeginTerminalHack(ply, ent, meta)
end

local function openDataCache(ply, ent, meta)
    local now = CurTime()
    if meta.lastUsed and meta.lastUsed > now then
        local wait = math.ceil(meta.lastUsed - now)
        ply:ChatPrint(("[Cache] Cooling down, try again in %ss."):format(wait))
        return false
    end

    meta.lastUsed = now + meta.cooldown
    ply:SetNWInt("CybeRp_DataFragments", (ply:GetNWInt("CybeRp_DataFragments") or 0) + (meta.reward.intel or 1))
    ply:ChatPrint("[Cache] Retrieved encrypted data fragment.")
    hook.Run("CybeRpDataCacheOpened", ply, meta.id, meta.reward)
    ent:EmitSound("buttons/button15.wav", 65)
    return false
end

hook.Add("PlayerUse", "CybeRpWorld_UseInteractables", function(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    local meta = World.Interactables[ent]
    if not meta then return end

    if meta.type == "terminal" then
        return tryUseTerminal(ply, ent, meta)
    elseif meta.type == "data_cache" then
        return openDataCache(ply, ent, meta)
    end
end)

local function spawnDefaults()
    if World._defaultInteractables then return end

    World:SpawnTerminal("grid_access", {
        pos = Vector(90, 120, 36),
        ang = Angle(0, 90, 0),
        district = "neonmile",
        difficulty = 0.5,
        cooldown = 90,
    })

    World:SpawnDataCache("oldgrid_cache", {
        pos = Vector(3400, -1050, 16),
        ang = Angle(0, -10, 0),
        district = "oldgrid",
        reward = { intel = 2 },
        cooldown = 120,
    })

    World._defaultInteractables = true
end

hook.Add("InitPostEntity", "CybeRpWorld_InteractionBootstrap", function()
    spawnDefaults()
end)



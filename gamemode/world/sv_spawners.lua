CybeRp = CybeRp or {}
CybeRp.World = CybeRp.World or {}

local World = CybeRp.World

World.Spawners = World.Spawners or {}
World.LootPools = World.LootPools or {}

local function debugLog(msg, ...)
    if CybeRp.Config and CybeRp.Config.Debug then
        print(("[CybeRp][Spawner] " .. msg):format(...))
    end
end

local function isDistrictActive(districtId)
    if not districtId then return true end
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply.CybeRpDistrict == districtId then
            return true
        end
    end
end

function World:RegisterLootPool(id, entries)
    if not id or not entries then return end
    World.LootPools[id] = entries
    debugLog("Registered loot pool %s (%d entries)", id, #entries)
end

function World:RegisterSpawnPoint(id, data)
    if not id or not data then return end
    data.id = id
    data.nextSpawn = CurTime() + (data.initialDelay or math.random(10, 30))
    data.respawn = data.respawn or 180
    data.cooldown = data.cooldown or 30
    World.Spawners[id] = data
    debugLog("Registered spawn %s for class %s", id, data.class or "prop_physics")
end

local function attachRemovalHook(spawn, ent)
    ent:CallOnRemove("CybeRpWorld_SpawnRespawn_" .. spawn.id, function()
        spawn.activeEnt = nil
        spawn.nextSpawn = CurTime() + spawn.respawn
    end)
end

local function applyModel(ent, model)
    if not model then return end
    ent:SetModel(model)
    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetMoveType(MOVETYPE_NONE)
    ent:SetSolid(SOLID_VPHYSICS)
end

function World:SpawnAtPoint(spawn)
    if not spawn then return end
    if spawn.activeEnt and IsValid(spawn.activeEnt) then return end
    if not isDistrictActive(spawn.district) then return end

    local class = spawn.class or "cyb_lootcrate"
    local ent = ents.Create(class)

    if not IsValid(ent) and class ~= "prop_physics" then
        debugLog("Missing entity class %s, falling back to prop_physics", class)
        class = "prop_physics"
        ent = ents.Create(class)
    end

    if not IsValid(ent) then
        debugLog("Failed to create entity for spawn %s", spawn.id)
        return
    end

    ent:SetPos(spawn.pos)
    ent:SetAngles(spawn.ang or Angle(0, 0, 0))

    if spawn.model then
        applyModel(ent, spawn.model)
    end

    ent:Spawn()
    ent.CybeRpSpawnId = spawn.id
    spawn.activeEnt = ent

    attachRemovalHook(spawn, ent)
    debugLog("Spawned %s at %s", class, tostring(spawn.pos))
end

function World:TickSpawners()
    local now = CurTime()
    for _, spawn in pairs(World.Spawners) do
        if spawn.activeEnt and IsValid(spawn.activeEnt) then
            spawn.nextSpawn = now + spawn.cooldown
        elseif now >= (spawn.nextSpawn or 0) then
            World:SpawnAtPoint(spawn)
        end
    end
end

local function createDefaultSpawns()
    if World._defaultSpawnsLoaded then return end

    World:RegisterSpawnPoint("neonmile_cache", {
        pos = Vector(120, 80, 8),
        ang = Angle(0, 45, 0),
        class = "prop_physics",
        model = "models/Items/item_item_crate.mdl",
        district = "neonmile",
        respawn = 240,
    })

    World:RegisterSpawnPoint("oldgrid_datacache", {
        pos = Vector(3400, -1100, 12),
        ang = Angle(0, -30, 0),
        class = "prop_physics",
        model = "models/props_lab/reciever_cart.mdl",
        district = "oldgrid",
        respawn = 260,
    })

    World:RegisterSpawnPoint("docks_supply", {
        pos = Vector(-2700, 2500, 16),
        ang = Angle(0, 90, 0),
        class = "prop_physics",
        model = "models/Items/ammocrate_smg1.mdl",
        district = "docks",
        respawn = 300,
    })

    World._defaultSpawnsLoaded = true
    debugLog("Default spawner set installed")
end

hook.Add("InitPostEntity", "CybeRpWorld_SpawnerBootstrap", function()
    createDefaultSpawns()
    timer.Create("CybeRpWorld_SpawnPulse", 15, 0, function()
        World:TickSpawners()
    end)
end)



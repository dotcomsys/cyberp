CybeRp = CybeRp or {}
CybeRp.World = CybeRp.World or {}
CybeRp.World.AI = CybeRp.World.AI or {}

local World = CybeRp.World
local AI = CybeRp.World.AI

AI.Police = AI.Police or { active = {}, quotas = { drones = 2, bots = 2, vendors = 1 } }
AI.CrimeQueue = AI.CrimeQueue or {}

local function debugLog(msg, ...)
    if CybeRp.Config and CybeRp.Config.Debug then
        print(("[CybeRp][Police] " .. msg):format(...))
    end
end

local function trackEntity(ent)
    table.insert(AI.Police.active, ent)
    ent:CallOnRemove("CybeRpWorld_PoliceCleanup", function()
        for idx, stored in ipairs(AI.Police.active) do
            if stored == ent then
                table.remove(AI.Police.active, idx)
                break
            end
        end
    end)
end

function AI:SpawnDrone(pos, pathId)
    local ent = ents.Create("npc_cscanner")
    if not IsValid(ent) then
        debugLog("Failed to create drone entity")
        return
    end

    ent:SetPos(pos)
    ent:Spawn()
    ent:SetHealth(40)
    AI:AssignPatrol(ent, pathId or "neon_patrol", { wait = 8 })
    trackEntity(ent)
    debugLog("Spawned police drone at %s", tostring(pos))
    return ent
end

function AI:SpawnSecurityBot(pos, pathId)
    local ent = ents.Create("npc_combine_s")
    if not IsValid(ent) then
        debugLog("Failed to create security bot")
        return
    end

    ent:SetPos(pos)
    ent:Give("weapon_smg1")
    ent:Spawn()
    AI:AssignPatrol(ent, pathId or "neon_patrol", { wait = 6, run = true })
    trackEntity(ent)
    debugLog("Spawned security bot at %s", tostring(pos))
    return ent
end

function AI:SpawnVendor(pos)
    local ent = ents.Create("npc_citizen")
    if not IsValid(ent) then
        debugLog("Failed to create vendor")
        return
    end

    ent:SetPos(pos)
    ent:SetKeyValue("citizentype", "Medic")
    ent:SetKeyValue("spawnflags", 128)
    ent:Spawn()
    ent:SetNWBool("CybeRpVendor", true)
    trackEntity(ent)
    debugLog("Vendor placed at %s", tostring(pos))
    return ent
end

local function countByClass(classname)
    local count = 0
    for _, ent in ipairs(AI.Police.active) do
        if IsValid(ent) and ent:GetClass() == classname then
            count = count + 1
        end
    end
    return count
end

function AI:DispatchQuickResponse(pos, severity)
    severity = severity or 1
    World:BroadcastAlert("CitySec units deployed.", "alert")

    AI:SpawnSecurityBot(pos + Vector(40, 0, 0))
    if severity >= 1.5 then
        AI:SpawnDrone(pos + Vector(-60, 0, 80))
    end
end

function AI:ReportCrime(ply, factionId, severity, note)
    if not IsValid(ply) then return end
    table.insert(AI.CrimeQueue, {
        ply = ply,
        faction = factionId or "authority",
        severity = severity or 1,
        note = note or ""
    })
    debugLog("Crime queued for %s (sev %s)", ply:Nick(), tostring(severity))
end

local function processCrimeQueue()
    if #AI.CrimeQueue == 0 then return end
    local entry = table.remove(AI.CrimeQueue, 1)
    if not entry or not IsValid(entry.ply) then return end

    local pos = entry.ply:GetPos()
    if entry.severity >= 2 then
        AI:DispatchQuickResponse(pos, entry.severity)
    else
        World:BroadcastAlert(("Suspicious activity near %s"):format(entry.ply:Nick()), "warning")
    end
end

local function maintainPresence()
    if countByClass("npc_cscanner") < AI.Police.quotas.drones then
        AI:SpawnDrone(Vector(0, 0, 120), "neon_patrol")
    end

    if countByClass("npc_combine_s") < AI.Police.quotas.bots then
        AI:SpawnSecurityBot(Vector(-2800, 2400, 32), "dock_patrol")
    end

    if countByClass("npc_citizen") < AI.Police.quotas.vendors then
        AI:SpawnVendor(Vector(120, 60, 16))
    end
end

hook.Add("CybeRpWorldRaidStarted", "CybeRpWorld_PoliceRaidResponse", function(districtId)
    World:BroadcastAlert(("CitySec raid response en route to %s."):format(districtId or "sector"), "critical")
    AI:SpawnSecurityBot(Vector(0, 0, 0), "neon_patrol")
    AI:SpawnDrone(Vector(0, 0, 140), "neon_patrol")
end)

hook.Add("CybeRpWorldNightStateChanged", "CybeRpWorld_AdjustNightQuotas", function(isNight)
    if isNight then
        AI.Police.quotas.drones = 3
        AI.Police.quotas.bots = 3
    else
        AI.Police.quotas.drones = 2
        AI.Police.quotas.bots = 2
    end
end)

timer.Create("CybeRpWorld_PolicePulse", 45, 0, function()
    maintainPresence()
    processCrimeQueue()
end)

hook.Add("CybeRp_CrimeRegistered", "CybeRpWorld_PoliceCrimeIntake", function(ply, factionId, severity, note)
    AI:ReportCrime(ply, factionId, severity, note)
end)



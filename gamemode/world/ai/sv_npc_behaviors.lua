CybeRp = CybeRp or {}
CybeRp.World = CybeRp.World or {}
CybeRp.World.AI = CybeRp.World.AI or {}

local AI = CybeRp.World.AI

AI.Paths = AI.Paths or {}
AI.Patrols = AI.Patrols or {}
AI.Guards = AI.Guards or {}

local function debugLog(msg, ...)
    if CybeRp.Config and CybeRp.Config.Debug then
        print(("[CybeRp][AI] " .. msg):format(...))
    end
end

function AI:RegisterPathNetwork(id, nodes)
    if not id or not nodes then return end
    AI.Paths[id] = nodes
    debugLog("Registered path network %s (%d nodes)", id, #nodes)
end

function AI:CommandMove(ent, pos, run)
    if not IsValid(ent) then return end
    ent:SetLastPosition(pos)
    ent:SetSchedule(run and SCHED_FORCED_GO_RUN or SCHED_FORCED_GO)
end

local function stepPatrol(ent, state)
    local path = AI.Paths[state.pathId]
    if not path or #path == 0 then return end

    state.index = (state.index % #path) + 1
    local node = path[state.index]
    if not node then return end

    AI:CommandMove(ent, node.pos, state.run)
    state.nextStep = CurTime() + (state.wait or 6)
    debugLog("Patrol step for %s to node %d", tostring(ent), state.index)
end

function AI:AssignPatrol(ent, pathId, opts)
    if not IsValid(ent) or not pathId then return end
    AI.Patrols[ent] = {
        pathId = pathId,
        index = 0,
        wait = (opts and opts.wait) or 6,
        run = opts and opts.run,
    }

    stepPatrol(ent, AI.Patrols[ent])
    ent:CallOnRemove("CybeRpWorld_AIPatrolCleanup", function()
        AI.Patrols[ent] = nil
    end)
end

function AI:AssignGuard(ent, pos, radius)
    if not IsValid(ent) then return end
    AI.Guards[ent] = {
        pos = pos,
        radius = radius or 250,
        nextCheck = CurTime() + 5,
    }

    ent:CallOnRemove("CybeRpWorld_AIGuardCleanup", function()
        AI.Guards[ent] = nil
    end)
end

local function tickPatrols()
    local now = CurTime()
    for ent, state in pairs(AI.Patrols) do
        if not IsValid(ent) then
            AI.Patrols[ent] = nil
        elseif state.nextStep and now >= state.nextStep then
            stepPatrol(ent, state)
        end
    end
end

local function tickGuards()
    local now = CurTime()
    for ent, state in pairs(AI.Guards) do
        if not IsValid(ent) then
            AI.Guards[ent] = nil
        elseif state.nextCheck and now >= state.nextCheck then
            local dist = ent:GetPos():DistToSqr(state.pos)
            if dist > (state.radius * state.radius) then
                AI:CommandMove(ent, state.pos, true)
            end
            state.nextCheck = now + 5
        end
    end
end

timer.Create("CybeRpWorld_AIPatrolTick", 5, 0, function()
    tickPatrols()
    tickGuards()
end)

hook.Add("OnNPCKilled", "CybeRpWorld_AICleanup", function(npc)
    AI.Patrols[npc] = nil
    AI.Guards[npc] = nil
end)

local function installDefaultPaths()
    if AI._defaultPaths then return end

    AI:RegisterPathNetwork("neon_patrol", {
        { pos = Vector(0, 0, 0) },
        { pos = Vector(420, 320, 0) },
        { pos = Vector(-260, 580, 0) },
    })

    AI:RegisterPathNetwork("dock_patrol", {
        { pos = Vector(-3000, 2200, 16) },
        { pos = Vector(-2600, 2600, 16) },
        { pos = Vector(-2400, 2100, 16) },
    })

    AI._defaultPaths = true
end

hook.Add("InitPostEntity", "CybeRpWorld_AIBootstrap", function()
    installDefaultPaths()
end)



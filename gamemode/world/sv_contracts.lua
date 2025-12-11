CybeRp = CybeRp or {}
CybeRp.World = CybeRp.World or {}

local World = CybeRp.World
World.Contracts = World.Contracts or { active = {} }

local CONTRACT_POOL = {
    { id = "deliver_datacube", type = "delivery", reward = 150, desc = "Deliver a datacube to the safe drop.", duration = 900 },
    { id = "hack_terminal", type = "hack", reward = 200, desc = "Breach a marked terminal.", duration = 900 },
    { id = "escort_asset", type = "escort", reward = 250, desc = "Escort an asset through the docks.", duration = 900 },
    { id = "raid_scout", type = "raid", reward = 220, desc = "Scout a raid entry point.", duration = 900 },
}

local function getActiveTable(ply)
    local sid = ply:SteamID64()
    World.Contracts.active[sid] = World.Contracts.active[sid] or {}
    return World.Contracts.active[sid]
end

-- Objective hooks
hook.Add("CybeRpTerminalHacked", "CybeRp_Contracts_HackObjective", function(ply, terminalId, success)
    if not success then return end
    local active = getActiveTable(ply)
    for id, a in pairs(active) do
        local c = findContract(id)
        if c and c.type == "hack" then
            World:CompleteContract(ply, id)
            break
        end
    end
end)


function World:GetContractsForPlayer(ply)
    local active = getActiveTable(ply)
    local list = {}
    for _, c in ipairs(CONTRACT_POOL) do
        local entry = table.Copy(c)
        local a = active[c.id]
        if a then
            entry.active = true
            entry.deadline = a.deadline
            entry.completed = a.completed
        end
        list[#list + 1] = entry
    end
    return list
end

local function findContract(id)
    for _, c in ipairs(CONTRACT_POOL) do
        if c.id == id then return c end
    end
    return nil
end

function World:AcceptContract(ply, contractId)
    if not IsValid(ply) then return end
    local c = findContract(contractId)
    if not c then return end
    local active = getActiveTable(ply)
    active[contractId] = {
        started = CurTime(),
        deadline = CurTime() + (c.duration or 900),
        completed = false,
        progress = 0,
    }
    if CybeRp.Net and CybeRp.Net.PushContracts then
        CybeRp.Net.PushContracts(ply, World:GetContractsForPlayer(ply))
    end
end

function World:CompleteContract(ply, contractId)
    if not IsValid(ply) then return end
    local c = findContract(contractId)
    if not c then return end
    local active = getActiveTable(ply)
    local a = active[contractId]
    if not a then return end

    active[contractId] = nil

    ply:AddCredits(c.reward or 0)
    CybeRp.Player.MarkDirty(ply, "credits")
    hook.Run("CybeRp_ContractCompleted", ply, c)

    if CybeRp.Net and CybeRp.Net.PushContracts then
        CybeRp.Net.PushContracts(ply, World:GetContractsForPlayer(ply))
    end
end

local function expireContracts()
    for _, ply in ipairs(player.GetHumans()) do
        local active = World.Contracts.active[ply:SteamID64()]
        if active then
            local changed = false
            for id, a in pairs(active) do
                if a.deadline and CurTime() > a.deadline then
                    active[id] = nil
                    changed = true
                end
            end
            if changed and CybeRp.Net and CybeRp.Net.PushContracts then
                CybeRp.Net.PushContracts(ply, World:GetContractsForPlayer(ply))
            end
        end
    end
end

timer.Create("CybeRp_Contracts_Expire", 15, 0, expireContracts)



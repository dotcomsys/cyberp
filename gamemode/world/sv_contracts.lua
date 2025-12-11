CybeRp = CybeRp or {}
CybeRp.World = CybeRp.World or {}

local World = CybeRp.World
World.Contracts = World.Contracts or {}

local CONTRACT_POOL = {
    { id = "deliver_datacube", type = "delivery", reward = 150, desc = "Deliver a datacube to the safe drop." },
    { id = "hack_terminal", type = "hack", reward = 200, desc = "Breach a marked terminal." },
    { id = "escort_asset", type = "escort", reward = 250, desc = "Escort an asset through the docks." },
}

function World:GetContractsForPlayer(ply)
    -- Simple rotation for now
    return CONTRACT_POOL
end

function World:CompleteContract(ply, contractId)
    if not IsValid(ply) then return end
    for _, c in ipairs(CONTRACT_POOL) do
        if c.id == contractId then
            ply:AddCredits(c.reward or 0)
            CybeRp.Player.MarkDirty(ply, "credits")
            hook.Run("CybeRp_ContractCompleted", ply, c)
            break
        end
    end
end



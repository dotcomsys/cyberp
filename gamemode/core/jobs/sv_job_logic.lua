local PAYDAY_INTERVAL = 300
include("cyberp/gamemode/core/jobs/sh_job_system.lua")

function CybeRp.Jobs.Assign(ply, jobId)
    if not IsValid(ply) then return false end
    local ok, reason = CybeRp.Jobs.CanJoin(ply, jobId)
    if not ok then return false, reason end

    local job = CybeRp.Jobs.Get(jobId) or CybeRp.Jobs.Get(CybeRp.Jobs.GetDefaultId())
    if not job then return false, "job missing" end

    ply:SetJob(job.id)
    if job.faction and CybeRp.Factions then
        CybeRp.Factions.SetFaction(ply, job.faction)
    end

    CybeRp.Player.MarkDirty(ply, "job")
    hook.Run("CybeRp_JobChanged", ply, job.id)
    return true
end

function CybeRp.Jobs.RequestChange(ply, jobId)
    local ok, reason = CybeRp.Jobs.Assign(ply, jobId)
    if not ok then
        return false, reason
    end
    return true
end

function CybeRp.Jobs.ApplySpawnLoadout(ply)
    local job = CybeRp.Jobs.Get(ply:GetJob())
    if not job or not job.loadout then return end

    for _, wep in ipairs(job.loadout) do
        if not ply:HasWeapon(wep) then
            ply:Give(wep)
        end
    end
end

local function payday()
    for _, ply in ipairs(player.GetHumans()) do
        if not ply:IsCybeLoaded() then continue end
        local job = CybeRp.Jobs.Get(ply:GetJob())
        if job and job.salary then
            ply:AddCredits(job.salary)
            CybeRp.Player.MarkDirty(ply, "credits")
        end
    end
end

timer.Create("CybeRp_Payday", PAYDAY_INTERVAL, 0, payday)

hook.Add("PlayerLoadedData", "CybeRp_ValidateJob", function(ply)
    local job = CybeRp.Jobs.Get(ply:GetJob())
    if not job then
        CybeRp.Jobs.Assign(ply, CybeRp.Jobs.GetDefaultId())
    end
end)


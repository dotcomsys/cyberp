-- CybeRp Access/Restriction Helpers (shared)
CybeRp = CybeRp or {}
CybeRp.Access = CybeRp.Access or {}

local Access = CybeRp.Access

function Access.AllowsFaction(ply, factionId)
    if not factionId then return true end
    return CybeRp.Factions and CybeRp.Factions.IsMember and CybeRp.Factions.IsMember(ply, factionId)
end

function Access.AllowsJob(ply, jobId)
    if not jobId then return true end
    return string.lower(ply:GetJob() or "") == string.lower(jobId)
end

function Access.AllowsWeapon(ply, weaponClass)
    if CybeRp.Jobs and CybeRp.Jobs.AllowsWeapon then
        return CybeRp.Jobs.AllowsWeapon(ply, weaponClass)
    end
    return true
end

function Access.AllowsCyberware(ply, cyberId)
    if CybeRp.Jobs and CybeRp.Jobs.AllowsCyberware then
        return CybeRp.Jobs.AllowsCyberware(ply, cyberId)
    end
    return true
end

-- Area check helper: specify allowed factions/jobs (tables or single string)
function Access.CanEnterArea(ply, opts)
    if not IsValid(ply) then return false end
    opts = opts or {}

    local function matchList(checkFn, list)
        if not list then return true end
        if isstring(list) then
            return checkFn(ply, list)
        end
        if istable(list) then
            for _, v in ipairs(list) do
                if checkFn(ply, v) then
                    return true
                end
            end
        end
        return false
    end

    if not matchList(Access.AllowsFaction, opts.factions) then return false end
    if not matchList(Access.AllowsJob, opts.jobs) then return false end
    return true
end



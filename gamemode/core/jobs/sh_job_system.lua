CybeRp.Jobs = CybeRp.Jobs or {}

local DEFAULT_JOBS = (CybeRp.ConfigManager and CybeRp.ConfigManager.Defaults and CybeRp.ConfigManager.Defaults.Jobs) or {
    citizen = {
        id = "citizen",
        name = "Citizen",
        description = "Unaligned civilian.",
        salary = 50,
        loadout = {},
        faction = "neutral",
    },
    enforcer = {
        id = "enforcer",
        name = "City Enforcer",
        description = "Keeps the peace with non-lethal force.",
        salary = 120,
        loadout = {"weapon_stunstick", "weapon_pistol"},
        faction = "authority",
    },
}

local function registry()
    if CybeRp.Config and next(CybeRp.Config.Jobs or {}) then
        return CybeRp.Config.Jobs
    end
    return DEFAULT_JOBS
end

function CybeRp.Jobs.Get(id)
    return registry()[id]
end

function CybeRp.Jobs.GetAll()
    return registry()
end

function CybeRp.Jobs.GetDefaultId()
    return "citizen"
end

-- Eligibility checks for job changes
function CybeRp.Jobs.CanJoin(ply, jobId)
    local job = CybeRp.Jobs.Get(jobId)
    if not job then return false, "invalid job" end

    -- Optional faction gate
    if job.requiresFaction and istable(job.requiresFaction) then
        local currentFaction = ply.GetFaction and ply:GetFaction()
        local allowed = false
        for _, fid in ipairs(job.requiresFaction) do
            if string.lower(fid) == string.lower(currentFaction or "") then
                allowed = true
                break
            end
        end
        if not allowed then
            return false, "faction not allowed"
        end
    end

    return true
end

-- Restriction helpers (used by gameplay and cyberware)
function CybeRp.Jobs.AllowsWeapon(ply, weaponClass)
    local job = CybeRp.Jobs.Get(ply:GetJob())
    if not job then return true end
    if job.blockedWeapons and job.blockedWeapons[weaponClass] then
        return false
    end
    if job.allowedWeapons and next(job.allowedWeapons) then
        return job.allowedWeapons[weaponClass] == true
    end
    return true
end

function CybeRp.Jobs.AllowsCyberware(ply, cyberId)
    local job = CybeRp.Jobs.Get(ply:GetJob())
    if not job then return true end
    if job.blockedCyberware and job.blockedCyberware[cyberId] then
        return false
    end
    return true
end


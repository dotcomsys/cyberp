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


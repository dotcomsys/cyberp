CybeRp = CybeRp or {}
CybeRp.Config = CybeRp.Config or {}
CybeRp.ConfigManager = CybeRp.ConfigManager or {}
CybeRp.ConfigManager.Defaults = CybeRp.ConfigManager.Defaults or {}

local CM = CybeRp.ConfigManager

CM.Defaults.Jobs = {
    CIVILIAN = {
        id = "civilian",
        name = "Civilian",
        desc = "Average citizen of the sprawl.",
        startingCredits = 200,
        faction = "NEUTRAL",
        loadout = {},
    },
    STREET_COP = {
        id = "street_cop",
        name = "Street Cop",
        desc = "Keeps order or abuses it.",
        startingCredits = 400,
        faction = "CITYWATCH",
        loadout = {"weapon_stunstick", "weapon_pistol"},
    },
    NETRUNNER = {
        id = "netrunner",
        name = "Netrunner",
        desc = "Hacks grids and dives the Net.",
        startingCredits = 350,
        faction = "NEUTRAL",
        loadout = {"weapon_crowbar"},
    },
    GANG_MEMBER = {
        id = "gang_member",
        name = "Street Gang",
        desc = "Works the alleys for the crew.",
        startingCredits = 300,
        faction = "STREETGANG01",
        loadout = {"weapon_pistol"},
    },
}

-- Export to shared config for runtime access
CybeRp.Config.Jobs = CM.Defaults.Jobs


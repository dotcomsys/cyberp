CybeRp = CybeRp or {}
CybeRp.Config = CybeRp.Config or {}
CybeRp.ConfigManager = CybeRp.ConfigManager or {}
CybeRp.ConfigManager.Defaults = CybeRp.ConfigManager.Defaults or {}

local CM = CybeRp.ConfigManager

CM.Defaults.Factions = {
    NEUTRAL = {
        id = "NEUTRAL",
        name = "Unaffiliated",
        desc = "Independent and unaligned.",
    },
    CITYWATCH = {
        id = "CITYWATCH",
        name = "City Watch",
        desc = "Municipal security and enforcement.",
    },
    STREETGANG01 = {
        id = "STREETGANG01",
        name = "Street Gang 01",
        desc = "Local turf crew with loose rules.",
    },
    CORP01 = {
        id = "CORP01",
        name = "MegaCorp 01",
        desc = "Corporate interests and contractors.",
    },
}

CybeRp.Config.Factions = CM.Defaults.Factions


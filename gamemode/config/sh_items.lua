CybeRp = CybeRp or {}
CybeRp.Config = CybeRp.Config or {}
CybeRp.ConfigManager = CybeRp.ConfigManager or {}
CybeRp.ConfigManager.Defaults = CybeRp.ConfigManager.Defaults or {}

local CM = CybeRp.ConfigManager

CM.Defaults.Items = {
    PISTOL = {
        id = "pistol",
        name = "Sidearm",
        desc = "Reliable 9mm sidearm.",
        type = "weapon",
        weight = 3,
        price = 250,
    },
    MEDKIT = {
        id = "medkit",
        name = "Medkit",
        desc = "Restores health over time.",
        type = "consumable",
        weight = 2,
        price = 150,
    },
    CYBERDECK = {
        id = "cyberdeck",
        name = "Cyberdeck",
        desc = "Entry-level deck for Net actions.",
        type = "tool",
        weight = 4,
        price = 400,
    },
}

CybeRp.Config.Items = CM.Defaults.Items


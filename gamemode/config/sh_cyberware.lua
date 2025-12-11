CybeRp = CybeRp or {}
CybeRp.Config = CybeRp.Config or {}
CybeRp.ConfigManager = CybeRp.ConfigManager or {}
CybeRp.ConfigManager.Defaults = CybeRp.ConfigManager.Defaults or {}

local CM = CybeRp.ConfigManager

CM.Defaults.Cyberware = {
    OCULAR_IMPLANT = {
        id = "ocular_implant",
        name = "Ocular Implant",
        desc = "Enhanced optics; small armor bonus.",
        slot = "HEAD",
        armorBonus = 5,
        passive = true,
    },
    SPRINT_BOOSTER = {
        id = "sprint_booster",
        name = "Sprint Booster",
        desc = "Improved muscle response; better stamina efficiency.",
        slot = "LEGS",
        drainMult = 0.85,
        passive = true,
    },
    NEURAL_BOOST = {
        id = "neural_boost",
        name = "Neural Boost",
        desc = "Faster regen and higher max stamina.",
        slot = "NEURAL",
        staminaMaxBonus = 15,
        regenMult = 1.15,
        passive = true,
    },
    CLOAK_FIELD = {
        id = "cloak_field",
        name = "Cloak Field",
        desc = "Temporary optical cloaking.",
        slot = "TORSO",
        passive = false,
        cooldown = 20,
    },
    SHOCK_PALM = {
        id = "shock_palm",
        name = "Shock Palm",
        desc = "Melee discharge for close quarters.",
        slot = "ARMS",
        passive = false,
        cooldown = 12,
    },
}

CybeRp.Config.Cyberware = CM.Defaults.Cyberware


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
    },
    SPRINT_BOOSTER = {
        id = "sprint_booster",
        name = "Sprint Booster",
        desc = "Improved muscle response; better stamina efficiency.",
        slot = "LEGS",
        drainMult = 0.85,
    },
    NEURAL_BOOST = {
        id = "neural_boost",
        name = "Neural Boost",
        desc = "Faster regen and higher max stamina.",
        slot = "NEURAL",
        staminaMaxBonus = 15,
        regenMult = 1.15,
    },
}

CybeRp.Config.Cyberware = CM.Defaults.Cyberware


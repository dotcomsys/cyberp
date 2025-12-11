CybeRp = CybeRp or {}
CybeRp.Config = CybeRp.Config or {}
CybeRp.ConfigManager = CybeRp.ConfigManager or {}
CybeRp.ConfigManager.Defaults = CybeRp.ConfigManager.Defaults or {}

local CM = CybeRp.ConfigManager

CM.Defaults.Economy = {
    startingCredits     = 500,
    salesTax            = 0.08,
    incomeTax           = 0.05,
    vendorBuyMultiplier = 0.50, -- NPC buys from players
    vendorSellMultiplier= 1.10, -- NPC sells to players
    npcPrices = {
        medkit    = 150,
        pistol    = 250,
        cyberdeck = 400,
    },
}

CybeRp.Config.Economy = CM.Defaults.Economy


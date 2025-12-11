CybeRp = CybeRp or {}
CybeRp.Config = CybeRp.Config or {}

-- Core tunables
CybeRp.Config.StartingCredits   = 500
CybeRp.Config.CyberwareLimit    = 8
CybeRp.Config.InventorySlots    = 32
CybeRp.Config.MaxWeight         = 50 -- placeholder until weight is implemented
CybeRp.Config.Debug             = true

-- World/economy basics
CybeRp.Config.PaycheckInterval  = 300 -- seconds
CybeRp.Config.PaycheckBase      = 50  -- base salary; jobs can override
CybeRp.Config.SalesTax          = 0.08
CybeRp.Config.IncomeTax         = 0.05
CybeRp.Config.VendorBuyMult     = 0.50 -- NPC buys from players at 50%
CybeRp.Config.VendorSellMult    = 1.10 -- NPC sells to players at 110%
CybeRp.Config.HeatWantedThreshold = 50

-- Jail / release positions (world coordinates)
CybeRp.Config.JailPos = CybeRp.Config.JailPos or Vector(0, 0, 0)
CybeRp.Config.JailAng = CybeRp.Config.JailAng or Angle(0, 0, 0)
CybeRp.Config.ReleasePos = CybeRp.Config.ReleasePos or Vector(100, 0, 0)


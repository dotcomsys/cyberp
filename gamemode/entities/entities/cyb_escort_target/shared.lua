ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "CybeRp Escort Target"
ENT.Category = "CybeRp"
ENT.Spawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "EscortId")
end



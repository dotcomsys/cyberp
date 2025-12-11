ENT.Type = "ai"
ENT.Base = "base_ai"
ENT.PrintName = "CybeRp Escort NPC"
ENT.Category = "CybeRp"
ENT.Spawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "EscortId")
    self:NetworkVar("String", 1, "EscortTarget")
end



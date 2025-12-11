ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "CybeRp Objective Zone"
ENT.Category = "CybeRp"
ENT.Spawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "ZoneId")
    self:NetworkVar("String", 1, "ZoneType")
end



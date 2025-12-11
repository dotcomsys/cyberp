ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "CybeRp Terminal"
ENT.Category = "CybeRp"
ENT.Spawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "TerminalId")
    self:NetworkVar("String", 1, "TerminalDistrict")
end



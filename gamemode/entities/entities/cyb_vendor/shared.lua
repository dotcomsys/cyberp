ENT.Type = "ai"
ENT.Base = "base_ai"
ENT.PrintName = "CybeRp Vendor"
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "VendorType")
end



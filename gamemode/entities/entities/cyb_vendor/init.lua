AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model or "models/Humans/Group03/male_02.mdl")
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetSolid(SOLID_BBOX)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE + CAP_TURN_HEAD)
    self:SetUseType(SIMPLE_USE)
    self:DropToFloor()
    self:SetMaxYawSpeed(90)
end

function ENT:AcceptInput(name, activator)
    if name ~= "Use" then return end
    if not IsValid(activator) or not activator:IsPlayer() then return end

    if CybeRp.Net and CybeRp.Net.PushVendorStock then
        local vendorType = self:GetVendorType() or "general"
        local stock = CybeRp.Economy and CybeRp.Economy.BuildVendorStock and CybeRp.Economy.BuildVendorStock(self.Stock or {})
        CybeRp.Net.PushVendorStock(activator, {
            type = vendorType,
            stock = stock or {}
        })
    end
end



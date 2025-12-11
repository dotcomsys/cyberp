AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model or "models/props_combine/combine_interface003.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    local id = self:GetRaidId() or "raid_site"
    hook.Run("CybeRp_RaidCompleted", activator, id)
end



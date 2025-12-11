AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Type = "anim"
ENT.Base = "base_anim"

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
    local meta = {
        id = self:GetNWString("CybeRp_TerminalId", "terminal_generic"),
        hackTime = 6,
        cooldown = 75,
        difficulty = 0.5,
        district = self:GetNWString("CybeRp_TerminalDistrict", "unknown"),
        maxDistance = 160,
    }
    if CybeRp.World and CybeRp.World.BeginTerminalHack then
        CybeRp.World:BeginTerminalHack(activator, self, meta)
    end
end



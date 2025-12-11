AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model or "models/props_junk/TrafficCone001a.mdl")
    self:SetNoDraw(true)
    self:SetSolid(SOLID_NONE)
    self:DrawShadow(false)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionBounds(Vector(-64, -64, 0), Vector(64, 64, 128))
    self:PhysicsInitBox(Vector(-64, -64, 0), Vector(64, 64, 128))
end

function ENT:StartTouch(ent)
    if not IsValid(ent) or not ent:IsPlayer() then return end
    local zoneId = self:GetZoneId() or ""
    local zoneType = self:GetZoneType() or ""

    if zoneType == "delivery" then
        hook.Run("CybeRp_DeliveryComplete", ent, zoneId)
    elseif zoneType == "raid" then
        hook.Run("CybeRp_RaidCompleted", ent, zoneId)
    elseif zoneType == "escort" then
        hook.Run("CybeRp_EscortArrived", ent, zoneId)
    end
end



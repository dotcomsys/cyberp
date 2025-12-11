AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model or "models/Humans/Group03/male_07.mdl")
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetSolid(SOLID_BBOX)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE + CAP_TURN_HEAD + CAP_MOVE_GROUND)
    self:SetUseType(SIMPLE_USE)
    self:SetMaxYawSpeed(90)
    self:SetHealth(120)
    self:SetMaxHealth(120)
    self.PathIndex = 1
    self.TimeoutAt = CurTime() + 300
    self.PathNodes = {}
end

function ENT:SetEscortPath(nodes)
    self.PathNodes = nodes or {}
end

function ENT:Think()
    local targetId = self:GetEscortTarget()
    if targetId ~= "" and CybeRp.World and CybeRp.World.Markers and CybeRp.World.Markers[targetId] then
        local pos = CybeRp.World.Markers[targetId]
        self:SetLastPosition(pos)
        self:SetSchedule(SCHED_FORCED_GO_RUN)
    end

    if self.NextCheck and CurTime() < self.NextCheck then return end
    self.NextCheck = CurTime() + 1

    if self:Health() <= 0 then
        hook.Run("CybeRp_EscortFailed", self, self:GetEscortId(), "dead")
        self:Remove()
        return
    end

    if CurTime() >= self.TimeoutAt then
        hook.Run("CybeRp_EscortFailed", self, self:GetEscortId(), "timeout")
        self:Remove()
    end
end



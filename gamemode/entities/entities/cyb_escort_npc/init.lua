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
end

function ENT:Think()
    local targetId = self:GetEscortTarget()
    if targetId ~= "" and CybeRp.World and CybeRp.World.Markers and CybeRp.World.Markers[targetId] then
        local pos = CybeRp.World.Markers[targetId]
        self:SetLastPosition(pos)
        self:SetSchedule(SCHED_FORCED_GO_RUN)
    end
end



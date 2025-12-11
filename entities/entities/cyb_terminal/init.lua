AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/consolebox01a.mdl")
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(ply)
    ply:ChatPrint("[Terminal] Access Granted.")
end


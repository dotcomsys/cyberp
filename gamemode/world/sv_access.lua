CybeRp = CybeRp or {}
CybeRp.World = CybeRp.World or {}

if not SERVER then return end

-- Simple area access gate using CybeRp.Access helpers
hook.Add("PlayerUse", "CybeRp_Access_DoorUse", function(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    if not CybeRp.Access or not CybeRp.Access.CanEnterArea then return end

    local areaData = ent.CybeAreaAccess -- optional table set on entities/doors: {factions={}, jobs={}}
    if not areaData then return end

    if not CybeRp.Access.CanEnterArea(ply, areaData) then
        if CybeRp.Config and CybeRp.Config.Debug then
            ply:ChatPrint("[Access] Entry denied.")
        end
        return false
    end
end)



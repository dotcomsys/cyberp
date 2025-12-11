function CybeRp.Factions.SetFaction(ply, factionId)
    if not IsValid(ply) then return false end
    local faction = CybeRp.Factions.Get(factionId) or CybeRp.Factions.Get(CybeRp.Factions.GetDefaultId())
    if not faction then return false end
include("cyberp/gamemode/core/factions/sh_faction_system.lua")

    ply:SetFaction(faction.id)
    CybeRp.Player.MarkDirty(ply, "faction")
    return true
end

function CybeRp.Factions.AddReputation(ply, factionId, delta)
    if not IsValid(ply) then return 0 end
    factionId = factionId or CybeRp.Factions.GetDefaultId()
    return ply:AdjustReputation(factionId, delta or 0)
end

function CybeRp.Factions.RegisterCrime(ply, factionId, severity, note)
    if not IsValid(ply) then return end
    ply:AddCrime(factionId or "generic_crime", severity or 1, note)
    CybeRp.Factions.AddReputation(ply, factionId or "authority", -(severity or 1) * 5)
end

hook.Add("PlayerLoadedData", "CybeRp_ValidateFaction", function(ply)
    if not CybeRp.Factions.Get(ply:GetFaction()) then
        CybeRp.Factions.SetFaction(ply, CybeRp.Factions.GetDefaultId())
    end
end)


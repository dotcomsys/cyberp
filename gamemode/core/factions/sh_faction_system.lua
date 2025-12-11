CybeRp.Factions = CybeRp.Factions or {}

local DEFAULT_FACTIONS = (CybeRp.ConfigManager and CybeRp.ConfigManager.Defaults and CybeRp.ConfigManager.Defaults.Factions) or {
    neutral = {
        id = "neutral",
        name = "Unaffiliated",
        description = "Independent and unaligned.",
    },
    authority = {
        id = "authority",
        name = "City Authority",
        description = "Law enforcement and civic services.",
    },
}

local function registry()
    if CybeRp.Config and next(CybeRp.Config.Factions or {}) then
        return CybeRp.Config.Factions
    end
    return DEFAULT_FACTIONS
end

function CybeRp.Factions.Get(id)
    return registry()[id]
end

function CybeRp.Factions.GetAll()
    return registry()
end

function CybeRp.Factions.GetDefaultId()
    return "neutral"
end

function CybeRp.Factions.IsMember(ply, factionId)
    if not IsValid(ply) then return false end
    return string.lower(ply:GetFaction() or "") == string.lower(factionId or "")
end


include("cyberp/gamemode/core/player/sh_player_meta.lua")

CybeRp.Cyberware = CybeRp.Cyberware or {}

local DEFAULT_CYBERWARE = (CybeRp.ConfigManager and CybeRp.ConfigManager.Defaults and CybeRp.ConfigManager.Defaults.Cyberware) or {
    neural_boost = {
        id = "neural_boost",
        name = "Neural Boost",
        staminaMaxBonus = 15,
        regenMult = 1.15,
    },
    subdermal_armor = {
        id = "subdermal_armor",
        name = "Subdermal Armor",
        armorBonus = 25,
    },
    adrenal_pump = {
        id = "adrenal_pump",
        name = "Adrenal Pump",
        drainMult = 0.8,
    },
}

local function catalog()
    local active = DEFAULT_CYBERWARE
    if CybeRp.Config and next(CybeRp.Config.Cyberware or {}) then
        active = CybeRp.Config.Cyberware
    end
    CybeRp.Cyberware.Catalog = active
    return active
end

local function markDirty(ply)
    if CybeRp.Player and CybeRp.Player.MarkDirty then
        CybeRp.Player.MarkDirty(ply, "cyberware")
    end
end

function CybeRp.Cyberware.GetDefinition(id)
    return catalog()[id]
end

function CybeRp.Cyberware.GetAll()
    return catalog()
end

function CybeRp.Cyberware.ApplyBonuses(ply, data)
    if not data then return end
    local baseMax = CybeRp.Player.Defaults.staminaMax or 100
    local baseRegen = CybeRp.Player.Defaults.staminaRegen or 8
    local baseDrain = CybeRp.Player.Defaults.staminaDrain or 14
    local baseArmor = CybeRp.Player.Defaults.armor or 0

    data.staminaMax = baseMax
    data.staminaRegen = baseRegen
    data.staminaDrain = baseDrain
    data.armor = baseArmor

    for id in pairs(data.cyberware or {}) do
        local def = CybeRp.Cyberware.GetDefinition(id)
        if def then
            if def.staminaMaxBonus then
                data.staminaMax = data.staminaMax + def.staminaMaxBonus
            end
            if def.regenMult then
                data.staminaRegen = data.staminaRegen * def.regenMult
            end
            if def.drainMult then
                data.staminaDrain = data.staminaDrain * def.drainMult
            end
            if def.armorBonus then
                data.armor = data.armor + def.armorBonus
            end
        end
    end

    data.stamina = math.min(data.stamina, data.staminaMax)
    data.armor = math.Clamp(data.armor, 0, 150)
end

function CybeRp.Cyberware.Install(ply, id)
    if not IsValid(ply) then return false, "invalid player" end
    local def = CybeRp.Cyberware.GetDefinition(id)
    if not def then return false, "unknown cyberware" end

    local data = ply:GetCybeData()
    data.cyberware[id] = true

    CybeRp.Player.RecalculateDerived(ply)
    markDirty(ply)

    print(("[CybeRp] Installed cyberware %s for %s"):format(id, ply:Nick()))
    return true
end

function CybeRp.Cyberware.Remove(ply, id)
    if not IsValid(ply) then return false, "invalid player" end
    local data = ply:GetCybeData()
    if not data.cyberware[id] then return false, "not installed" end

    data.cyberware[id] = nil
    CybeRp.Player.RecalculateDerived(ply)
    markDirty(ply)

    print(("[CybeRp] Removed cyberware %s from %s"):format(id, ply:Nick()))
    return true
end


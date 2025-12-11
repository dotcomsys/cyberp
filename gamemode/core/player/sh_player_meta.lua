local PLAYER = FindMetaTable("Player")

CybeRp.Player = CybeRp.Player or {}

-- Canonical defaults applied to every player record.
CybeRp.Player.Defaults = {
    id = nil,
    credits = 500,
    bank = 0,
    job = "citizen",
    faction = "neutral",
    level = 1,
    xp = 0,
    stamina = 100,
    staminaMax = 100,
    staminaRegen = 8,   -- per second
    staminaDrain = 14,  -- per second while sprinting
    health = 100,
    armor = 0,
    reputation = {},
    crimes = {},
    cyberware = {},
    inventory = {},
}

local function markDirty(ply, field)
    if SERVER and CybeRp.Player and CybeRp.Player.MarkDirty then
        CybeRp.Player.MarkDirty(ply, field)
    end
end

local function ensureData(ply)
    ply.CybeData = ply.CybeData or table.Copy(CybeRp.Player.Defaults)
    return ply.CybeData
end

function PLAYER:GetCybeData()
    return ensureData(self)
end

function PLAYER:IsCybeLoaded()
    return self.CybeLoaded == true
end

function PLAYER:GetCybeID()
    return ensureData(self).id
end

function PLAYER:SetCybeID(id)
    ensureData(self).id = id
    markDirty(self, "id")
end

-- Aliases for naming consistency (Roadmap Phase 1.1.1)
function PLAYER:GetCyberID()
    return self:GetCybeID()
end

function PLAYER:SetCyberID(id)
    self:SetCybeID(id)
end

function PLAYER:GetCredits()
    return ensureData(self).credits or 0
end

function PLAYER:SetCredits(amount)
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    ensureData(self).credits = amount
    markDirty(self, "credits")
end

function PLAYER:AddCredits(amount)
    amount = math.floor(tonumber(amount) or 0)
    self:SetCredits(self:GetCredits() + amount)
end

function PLAYER:GetBank()
    return ensureData(self).bank or 0
end

function PLAYER:SetBank(amount)
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    ensureData(self).bank = amount
    markDirty(self, "bank")
end

function PLAYER:AddBank(amount)
    amount = math.floor(tonumber(amount) or 0)
    self:SetBank(self:GetBank() + amount)
end

function PLAYER:GetJob()
    return ensureData(self).job
end

function PLAYER:SetJob(jobId)
    ensureData(self).job = jobId
    markDirty(self, "job")
end

function PLAYER:GetFaction()
    return ensureData(self).faction
end

function PLAYER:SetFaction(factionId)
    ensureData(self).faction = factionId
    markDirty(self, "faction")
end

function PLAYER:GetReputation(factionId)
    local rep = ensureData(self).reputation or {}
    if factionId then
        return rep[factionId] or 0
    end
    return rep
end

function PLAYER:AdjustReputation(factionId, delta)
    local rep = ensureData(self).reputation
    rep[factionId] = math.Clamp((rep[factionId] or 0) + (delta or 0), -100, 100)
    markDirty(self, "reputation")
    return rep[factionId]
end

function PLAYER:GetCrimes()
    return ensureData(self).crimes
end

function PLAYER:AddCrime(tag, severity, note)
    local crimes = ensureData(self).crimes
    table.insert(crimes, {
        tag = tag or "unknown",
        severity = math.max(1, severity or 1),
        note = note or "",
        at = os.time(),
    })
    markDirty(self, "crimes")
end

function PLAYER:GetStamina()
    return ensureData(self).stamina
end

function PLAYER:GetMaxStamina()
    return ensureData(self).staminaMax
end

function PLAYER:SetStamina(amount)
    local data = ensureData(self)
    data.stamina = math.Clamp(amount or data.stamina, 0, data.staminaMax)
    markDirty(self, "stamina")
end

function PLAYER:SetMaxStamina(amount)
    local data = ensureData(self)
    data.staminaMax = math.max(1, math.floor(amount or data.staminaMax))
    data.stamina = math.min(data.stamina, data.staminaMax)
    markDirty(self, "staminaMax")
end

function PLAYER:GetStaminaRates()
    local data = ensureData(self)
    return data.staminaRegen, data.staminaDrain
end

function PLAYER:SetStaminaRates(regen, drain)
    local data = ensureData(self)
    data.staminaRegen = math.max(1, regen or data.staminaRegen)
    data.staminaDrain = math.max(1, drain or data.staminaDrain)
    markDirty(self, "staminaRates")
end

function PLAYER:GetCyberware()
    return ensureData(self).cyberware
end

function PLAYER:HasCyberware(id)
    return ensureData(self).cyberware[id] == true
end

function PLAYER:GiveCyberware(id)
    if not id then return false end

    local cyberware = ensureData(self).cyberware
    if cyberware[id] then return false end

    cyberware[id] = true
    markDirty(self, "cyberware")
    return true
end

function PLAYER:RemoveCyberware(id)
    if not id then return false end

    local cyberware = ensureData(self).cyberware
    if not cyberware[id] then return false end

    cyberware[id] = nil
    markDirty(self, "cyberware")
    return true
end

function PLAYER:GetInventory()
    return ensureData(self).inventory
end

function PLAYER:SetInventory(invTable)
    ensureData(self).inventory = invTable or {}
    markDirty(self, "inventory")
end

function PLAYER:GetXP()
    return ensureData(self).xp or 0
end

function PLAYER:AddXP(amount)
    local data = ensureData(self)
    data.xp = math.max(0, math.floor((data.xp or 0) + (amount or 0)))
    markDirty(self, "xp")
    return data.xp
end

function PLAYER:GetLevel()
    return ensureData(self).level or 1
end

function PLAYER:SetLevel(level)
    local data = ensureData(self)
    data.level = math.max(1, math.floor(level or data.level))
    markDirty(self, "level")
end


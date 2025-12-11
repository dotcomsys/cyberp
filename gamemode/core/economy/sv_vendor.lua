CybeRp = CybeRp or {}
CybeRp.Economy = CybeRp.Economy or {}

local Econ = CybeRp.Economy
local Items = CybeRp.Items or {}

local function getItemDef(id)
    return Items and Items[id] or (CybeRp.Config and CybeRp.Config.Items and CybeRp.Config.Items[id])
end

local function basePrice(id)
    local def = getItemDef(id)
    if not def then return nil end
    return def.price or 100
end

local function repMultiplier(ply)
    -- Use authority rep as a proxy; friendlier rep lowers price modestly.
    local rep = 0
    if IsValid(ply) and ply.GetReputation then
        rep = ply:GetReputation("CITYWATCH") or 0
    end
    return math.Clamp(1.0 - (rep / 400), 0.8, 1.2)
end

local function heatMultiplier(ply)
    local heat = 0
    if IsValid(ply) and ply.CybeHeat and ply.CybeHeat.value then
        heat = ply.CybeHeat.value
    end
    local wanted = IsValid(ply) and ply.CybeHeat and ply.CybeHeat.wanted
    local mult = 1.0 + (heat / 300)
    if wanted then mult = mult + 0.25 end
    return math.Clamp(mult, 0.9, 1.5)
end

local function applyVendorTypeMult(price, vendorType)
    if vendorType == "blackmarket" then
        return math.floor(price * 0.9)
    end
    return price
end

function Econ.GetBuyPrice(ply, itemId, vendorType)
    local price = basePrice(itemId)
    if not price then return nil end
    price = price * repMultiplier(ply) * heatMultiplier(ply)
    price = applyVendorTypeMult(price, vendorType)
    return math.max(1, math.floor(price))
end

function Econ.GetSellPrice(ply, itemId, vendorType)
    local price = basePrice(itemId)
    if not price then return nil end
    price = price * 0.5 * repMultiplier(ply) * heatMultiplier(ply)
    price = applyVendorTypeMult(price, vendorType)
    return math.max(1, math.floor(price))
end

-- Handle vendor transactions (server-side)
function Econ.HandleBuy(ply, itemId, amount, vendorType)
    if not IsValid(ply) or not isstring(itemId) or itemId == "" then return false, "invalid" end
    amount = math.max(1, math.floor(amount or 1))
    local price = Econ.GetBuyPrice(ply, itemId, vendorType)
    if not price then return false, "no price" end

    local total = price * amount
    if ply:GetCredits() < total then return false, "insufficient credits" end

    CybeRp.Inventory.Add(ply, itemId, amount)
    ply:AddCredits(-total)
    CybeRp.Player.MarkDirty(ply, "credits")
    CybeRp.Inventory.Sync(ply, { [itemId] = CybeRp.Inventory.Count(ply, itemId) })
    return true
end

function Econ.HandleSell(ply, itemId, amount, vendorType)
    if not IsValid(ply) or not isstring(itemId) or itemId == "" then return false, "invalid" end
    amount = math.max(1, math.floor(amount or 1))
    if not CybeRp.Inventory.Has(ply, itemId, amount) then return false, "not enough" end

    local price = Econ.GetSellPrice(ply, itemId, vendorType)
    if not price then return false, "no price" end
    local total = price * amount

    CybeRp.Inventory.Remove(ply, itemId, amount)
    ply:AddCredits(total)
    CybeRp.Player.MarkDirty(ply, "credits")
    CybeRp.Inventory.Sync(ply, { [itemId] = CybeRp.Inventory.Count(ply, itemId) })
    return true
end

local POOLS = {
    general = {"pistol", "medkit", "cyberdeck"},
    blackmarket = {"cyberdeck", "pistol"},
}

function Econ.GetVendorStockForPlayer(ply, vendorType, overrideList)
    vendorType = vendorType or "general"
    local list = overrideList or POOLS[vendorType] or POOLS.general or {}
    local stock = {}
    for _, id in ipairs(list) do
        local def = getItemDef(id)
        if def then
            stock[#stock + 1] = {
                id = def.id,
                name = def.name,
                desc = def.desc,
                buyPrice = Econ.GetBuyPrice(ply, def.id, vendorType),
                sellPrice = Econ.GetSellPrice(ply, def.id, vendorType),
                vendorType = vendorType
            }
        end
    end
    return stock
end



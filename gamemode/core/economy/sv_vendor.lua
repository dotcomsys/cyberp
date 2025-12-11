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
    -- Placeholder: reputation scaling could be faction-based; currently neutral.
    return 1.0
end

local function heatMultiplier(ply)
    -- Placeholder heat scaling
    return 1.0
end

function Econ.GetBuyPrice(ply, itemId)
    local price = basePrice(itemId)
    if not price then return nil end
    return math.floor(price * repMultiplier(ply) * heatMultiplier(ply))
end

function Econ.GetSellPrice(ply, itemId)
    local price = basePrice(itemId)
    if not price then return nil end
    return math.floor(price * 0.5 * repMultiplier(ply) * heatMultiplier(ply))
end

-- Handle vendor transactions (server-side)
function Econ.HandleBuy(ply, itemId, amount)
    if not IsValid(ply) or not isstring(itemId) or itemId == "" then return false, "invalid" end
    amount = math.max(1, math.floor(amount or 1))
    local price = Econ.GetBuyPrice(ply, itemId)
    if not price then return false, "no price" end

    local total = price * amount
    if ply:GetCredits() < total then return false, "insufficient credits" end

    CybeRp.Inventory.Add(ply, itemId, amount)
    ply:AddCredits(-total)
    CybeRp.Player.MarkDirty(ply, "credits")
    CybeRp.Inventory.Sync(ply, { [itemId] = CybeRp.Inventory.Count(ply, itemId) })
    return true
end

function Econ.HandleSell(ply, itemId, amount)
    if not IsValid(ply) or not isstring(itemId) or itemId == "" then return false, "invalid" end
    amount = math.max(1, math.floor(amount or 1))
    if not CybeRp.Inventory.Has(ply, itemId, amount) then return false, "not enough" end

    local price = Econ.GetSellPrice(ply, itemId)
    if not price then return false, "no price" end
    local total = price * amount

    CybeRp.Inventory.Remove(ply, itemId, amount)
    ply:AddCredits(total)
    CybeRp.Player.MarkDirty(ply, "credits")
    CybeRp.Inventory.Sync(ply, { [itemId] = CybeRp.Inventory.Count(ply, itemId) })
    return true
end

function Econ.BuildVendorStock(list)
    local stock = {}
    for _, id in ipairs(list or {}) do
        local def = getItemDef(id)
        if def then
            stock[#stock + 1] = {
                id = def.id,
                name = def.name,
                desc = def.desc,
                price = def.price or 100
            }
        end
    end
    return stock
end



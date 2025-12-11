CybeRp.Inventory = CybeRp.Inventory or {}

CybeRp.Inventory.MAX_SLOTS = 24

local function ensure(ply)
    if not IsValid(ply) then return {} end
    ply.CybeInventory = ply.CybeInventory or {}
    return ply.CybeInventory
end

function CybeRp.Inventory.Ensure(ply)
    return ensure(ply)
end

function CybeRp.Inventory.Get(ply)
    return ensure(ply)
end

function CybeRp.Inventory.Count(ply, item)
    return ensure(ply)[item] or 0
end

function CybeRp.Inventory.Has(ply, item, amount)
    amount = amount or 1
    return CybeRp.Inventory.Count(ply, item) >= amount
end

function CybeRp.Inventory.Snapshot(invTable)
    return table.Copy(invTable or {})
end

-- Shared API per roadmap (Phase 4.1.1)
function CybeRp.Inventory.Create(ply)
    return ensure(ply)
end

function CybeRp.Inventory.Add(ply, itemID, amount)
    if not isstring(itemID) or itemID == "" then return false end
    amount = math.max(1, math.floor(amount or 1))
    local inv = ensure(ply)
    inv[itemID] = (inv[itemID] or 0) + amount
    return inv[itemID]
end

function CybeRp.Inventory.Remove(ply, itemID, amount)
    if not isstring(itemID) or itemID == "" then return false end
    amount = math.max(1, math.floor(amount or 1))
    local inv = ensure(ply)
    if (inv[itemID] or 0) < amount then return false end
    inv[itemID] = inv[itemID] - amount
    if inv[itemID] <= 0 then
        inv[itemID] = nil
    end
    return true
end

function CybeRp.Inventory.Has(ply, itemID, amount)
    amount = math.max(1, math.floor(amount or 1))
    return (ensure(ply)[itemID] or 0) >= amount
end

function CybeRp.Inventory.GetAll(ply)
    return ensure(ply)
end


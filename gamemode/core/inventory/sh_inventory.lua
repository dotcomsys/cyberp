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


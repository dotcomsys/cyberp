CybeRp.Inventory = CybeRp.Inventory or {}

function CybeRp.Inventory.Create(ply)
    ply.Inventory = ply.Inventory or {}
end

function CybeRp.Inventory.Add(ply, item, amount)
    amount = amount or 1
    ply.Inventory[item] = (ply.Inventory[item] or 0) + amount
end

function CybeRp.Inventory.Get(ply)
    return ply.Inventory or {}
end


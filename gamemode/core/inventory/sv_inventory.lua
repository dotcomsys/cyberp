local function sendInventory(ply, payload)
    if CybeRp.Networking and CybeRp.Networking.PushInventory then
        CybeRp.Networking.PushInventory(ply, payload)
        return true
    end
    return false
end
include("cyberp/gamemode/core/inventory/sh_inventory.lua")

function CybeRp.Inventory.ApplyLoadedInventory(ply, items)
    ply.CybeInventory = table.Copy(items or {})
    if ply.SetInventory then
        ply:SetInventory(ply.CybeInventory)
    end
end

function CybeRp.Inventory.Sync(ply, partial)
    if not IsValid(ply) then return end
    local payload = partial or CybeRp.Inventory.Get(ply)
    sendInventory(ply, payload)
end

function CybeRp.Inventory.AddItem(ply, item, amount)
    if not IsValid(ply) then return false end
    amount = math.max(1, amount or 1)
    local inv = CybeRp.Inventory.Ensure(ply)
    inv[item] = (inv[item] or 0) + amount

    CybeRp.Player.MarkDirty(ply, "inventory")
    CybeRp.Inventory.Sync(ply, { [item] = inv[item] })
    return true
end

function CybeRp.Inventory.RemoveItem(ply, item, amount)
    if not IsValid(ply) then return false end
    amount = math.max(1, amount or 1)
    local inv = CybeRp.Inventory.Ensure(ply)
    if (inv[item] or 0) < amount then return false end

    inv[item] = inv[item] - amount
    if inv[item] <= 0 then
        inv[item] = nil
    end

    CybeRp.Player.MarkDirty(ply, "inventory")
    CybeRp.Inventory.Sync(ply, { [item] = inv[item] })
    return true
end

function CybeRp.Inventory.Clear(ply)
    if not IsValid(ply) then return end
    ply.CybeInventory = {}
    CybeRp.Player.MarkDirty(ply, "inventory")
    CybeRp.Inventory.Sync(ply)
end


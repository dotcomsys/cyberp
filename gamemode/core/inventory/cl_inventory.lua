-- CybeRp client inventory state
if SERVER then return end

CybeRp = CybeRp or {}
CybeRp.ClientState = CybeRp.ClientState or {}
CybeRp.Inventory = CybeRp.Inventory or {}

CybeRp.ClientState.inventory = CybeRp.ClientState.inventory or {}

function CybeRp.Inventory.GetClient()
    return CybeRp.ClientState.inventory or {}
end

-- Hooked from networking handlers (NET.INVENTORY_UPDATE)
hook.Add("CybeRp_UI_InventoryUpdated", "CybeRp_ClientInventory_Update", function(data)
    CybeRp.ClientState.inventory = data or {}
end)



CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}
CybeRp.UI.Inventory = CybeRp.UI.Inventory or {}

local function rebuildGrid(panel, data)
    if not IsValid(panel.Grid) then return end
    panel.Grid:Clear()

    local inv = data or (CybeRp.UI.State and CybeRp.UI.State.GetInventory and CybeRp.UI.State:GetInventory()) or {}
    panel.WeightLabel:SetText(string.format("Weight: %.1f / %.1f", inv.weight or 0, inv.maxWeight or inv.capacity or 0))

    for slotId = 1, inv.capacity or 0 do
        local slot = panel.Grid:Add("CybeRpItemSlot")
        slot:SetSlot(slotId)
        slot:SetItem(inv.slots and inv.slots[slotId])
    end
end

local function buildInventoryFrame()
    local frame = CybeRp.UI.MakeWindow("inventory", "CybeRp Inventory", 940, 620)

    if IsValid(frame.Body) then frame.Body:Remove() end

    frame.Body = vgui.Create("DPanel", frame)
    frame.Body:Dock(FILL)
    frame.Body:DockMargin(12, 48, 12, 12)

    frame.Body.Paint = function(pnl, w, h)
        CybeRp.UI.DrawPanelBackground(pnl, w, h, {outline = true, outlineColor = CybeRp.UI.GetColor("outline")})
    end

    local top = vgui.Create("DPanel", frame.Body)
    top:Dock(TOP)
    top:SetTall(42)
    top:DockMargin(12, 12, 12, 12)
    top.Paint = function() end

    local title = vgui.Create("DLabel", top)
    title:SetFont("CybeRp.Subheader")
    title:SetText("Gear Locker")
    title:SizeToContents()
    title:Dock(LEFT)
    title:DockMargin(0, 0, 16, 0)

    local refreshBtn = vgui.Create("CybeRpPanelButton", top)
    refreshBtn:SetText("Request Update")
    refreshBtn:SetWide(140)
    refreshBtn:Dock(RIGHT)
    refreshBtn:DockMargin(8, 0, 0, 0)
    refreshBtn.DoClick = function()
        hook.Run("CybeRp_UI_RequestInventorySnapshot")
    end

    local sortBtn = vgui.Create("CybeRpPanelButton", top)
    sortBtn:SetText("Sort (Client)")
    sortBtn:SetWide(120)
    sortBtn:Dock(RIGHT)
    sortBtn.DoClick = function()
        local inv = table.Copy(CybeRp.UI.State:GetInventory())
        table.sort(inv.slots or {}, function(a, b)
            if not a then return false end
            if not b then return true end
            return (a.name or "") < (b.name or "")
        end)
        rebuildGrid(frame.Body, inv)
    end

    local weight = vgui.Create("DLabel", top)
    weight:SetFont("CybeRp.Tiny")
    weight:SetTextColor(color_white)
    weight:Dock(LEFT)
    weight:DockMargin(0, 4, 0, 0)
    frame.Body.WeightLabel = weight

    local scroll = vgui.Create("DScrollPanel", frame.Body)
    scroll:Dock(FILL)
    scroll:DockMargin(12, 0, 12, 12)

    local grid = scroll:Add("DIconLayout")
    grid:Dock(FILL)
    grid:SetSpaceX(10)
    grid:SetSpaceY(10)
    grid:DockMargin(4, 4, 4, 4)
    frame.Body.Grid = grid

    rebuildGrid(frame.Body, (CybeRp.UI.State and CybeRp.UI.State.GetInventory and CybeRp.UI.State:GetInventory()) or {})

    frame:MakePopup()
    frame:Center()

    hook.Add("CybeRp_UI_InventoryUpdated", frame, function(_, data)
        if not IsValid(frame) then return end
        rebuildGrid(frame.Body, data)
    end)

    frame.OnRemove = function()
        hook.Remove("CybeRp_UI_InventoryUpdated", frame)
    end

    return frame
end

function CybeRp.UI.Inventory.Open()
    buildInventoryFrame()
end

function CybeRp.UI.Inventory.Toggle()
    if IsValid(CybeRp.UI.ActiveWindows and CybeRp.UI.ActiveWindows["inventory"]) then
        CybeRp.UI.ActiveWindows["inventory"]:Remove()
        return
    end
    CybeRp.UI.Inventory.Open()
end

concommand.Add("cyberp_inventory", function()
    CybeRp.UI.Inventory.Open()
end)

concommand.Add("cyberp_inventory_toggle", function()
    CybeRp.UI.Inventory.Toggle()
end)



local rarityColors = {
    common = Color(170, 190, 205),
    uncommon = Color(0, 200, 180),
    rare = Color(0, 140, 255),
    epic = Color(200, 80, 255),
    legendary = Color(255, 170, 0),
}

local PANEL = {}

function PANEL:Init()
    self.Item = nil
    self.SlotId = 0
    self:SetSize(96, 96)
    self:Droppable("cyberp_item")
    self:Receiver("cyberp_item", function(pnl, panels, dropped)
        if not dropped then return end
        local from = panels[1]
        if not IsValid(from) or from == pnl then return end
        CybeRp.UI.State:RequestInventoryMove(from:GetSlotId(), pnl:GetSlotId())
    end)
end

function PANEL:SetSlot(slotId)
    self.SlotId = slotId
end

function PANEL:GetSlotId()
    return self.SlotId
end

function PANEL:SetItem(data)
    self.Item = data
end

function PANEL:GetItem()
    return self.Item
end

function PANEL:OnMousePressed(code)
    self:MouseCapture(true)
    self:DragMousePress(code)
end

function PANEL:OnMouseReleased(code)
    self:MouseCapture(false)
    self:DragMouseRelease(code)
end

function PANEL:Paint(w, h)
    local hovered = self:IsHovered()
    local col = CybeRp.UI.GetColor("panel")

    draw.RoundedBox(8, 0, 0, w, h, col)

    if hovered then
        surface.SetDrawColor(255, 255, 255, 6)
        surface.DrawRect(0, 0, w, h)
    end

    local accent = CybeRp.UI.GetColor("accent")
    if self.Item and self.Item.rarity then
        accent = rarityColors[string.lower(self.Item.rarity)] or accent
    end

    CybeRp.UI.DrawNeonBorder(w, h, hovered and 2 or 1, accent)

    if not self.Item then
        CybeRp.UI.DrawShadowedText("Empty", "CybeRp.Small", w / 2, h / 2, CybeRp.UI.GetColor("muted"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    local qty = self.Item.quantity or self.Item.count or 1
    local name = self.Item.name or "Unknown"
    local weight = self.Item.weight or 0

    CybeRp.UI.DrawShadowedText(name, "CybeRp.Small", 8, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    CybeRp.UI.DrawShadowedText("x" .. qty, "CybeRp.Tiny", w - 8, h - 24, CybeRp.UI.GetColor("muted"), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    CybeRp.UI.DrawShadowedText(string.format("%.1f kg", weight), "CybeRp.Tiny", 8, h - 24, CybeRp.UI.GetColor("muted"), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

vgui.Register("CybeRpItemSlot", PANEL, "DPanel")



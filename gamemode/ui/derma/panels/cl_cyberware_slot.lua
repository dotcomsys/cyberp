local PANEL = {}

function PANEL:Init()
    self.Module = nil
    self.SlotId = ""
    self:SetSize(120, 120)
    self:Droppable("cyberp_cyberware")
    self:Receiver("cyberp_cyberware", function(pnl, panels, dropped)
        if not dropped then return end
        local from = panels[1]
        if not IsValid(from) or from == pnl then return end
        CybeRp.UI.State:RequestCyberwareSwap(from:GetSlotId(), pnl:GetSlotId())
    end)
end

function PANEL:SetSlotId(id)
    self.SlotId = id
end

function PANEL:GetSlotId()
    return self.SlotId
end

function PANEL:SetModule(data)
    self.Module = data
end

function PANEL:GetModule()
    return self.Module
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
    local bg = CybeRp.UI.GetColor("panel")

    draw.RoundedBox(10, 0, 0, w, h, bg)

    if hovered then
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawRect(0, 0, w, h)
    end

    CybeRp.UI.DrawNeonBorder(w, h, hovered and 3 or 2, CybeRp.UI.GetColor("accentAlt"))

    CybeRp.UI.DrawShadowedText(self.SlotId or "Slot", "CybeRp.Subheader", w / 2, 12, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

    if not self.Module then
        CybeRp.UI.DrawShadowedText("Empty socket", "CybeRp.Tiny", w / 2, h / 2, CybeRp.UI.GetColor("muted"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    CybeRp.UI.DrawShadowedText(self.Module.name or "Unknown mod", "CybeRp.Small", w / 2, h / 2 - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    CybeRp.UI.DrawShadowedText(self.Module.bonus or "", "CybeRp.Tiny", w / 2, h / 2 + 16, CybeRp.UI.GetColor("muted"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("CybeRpCyberwareSlot", PANEL, "DPanel")



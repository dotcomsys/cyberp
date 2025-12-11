local PANEL = {}

function PANEL:Init()
    self:SetText("")
    self.Label = "BUTTON"
    self.Accent = CybeRp.UI.GetColor("accent")
    self:SetCursor("hand")
end

function PANEL:SetText(txt)
    self.Label = txt
end

function PANEL:SetAccentColor(col)
    self.Accent = col
end

function PANEL:Paint(w, h)
    local hovered = self:IsHovered()
    local bg = CybeRp.UI.GetColor("panel")

    draw.RoundedBox(6, 0, 0, w, h, bg)

    if hovered or self.Depressed then
        surface.SetDrawColor(self.Accent.r, self.Accent.g, self.Accent.b, 16)
        surface.DrawRect(0, 0, w, h)
    end

    CybeRp.UI.DrawNeonBorder(w, h, hovered and 2 or 1, self.Accent)
    CybeRp.UI.DrawShadowedText(self.Label, "CybeRp.Body", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("CybeRpPanelButton", PANEL, "DButton")



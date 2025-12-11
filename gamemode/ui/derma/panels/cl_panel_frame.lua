local PANEL = {}

function PANEL:Init()
    self:SetTitle("")
    self:SetDraggable(true)
    self:ShowCloseButton(false)
    self:SetSizable(false)
    self.HeaderText = "CybeRp"
    self.Padding = 16

    self.CloseButton = vgui.Create("CybeRpPanelButton", self)
    self.CloseButton:SetText("X")
    self.CloseButton:SetAccentColor(CybeRp.UI.GetColor("danger"))
    self.CloseButton.DoClick = function()
        self:Close()
    end
end

function PANEL:SetHeaderText(text)
    self.HeaderText = text
end

function PANEL:GetHeaderText()
    return self.HeaderText
end

function PANEL:PerformLayout(w, h)
    self.CloseButton:SetSize(36, 24)
    self.CloseButton:SetPos(w - self.CloseButton:GetWide() - self.Padding, self.Padding)
end

function PANEL:Paint(w, h)
    CybeRp.UI.DrawPanelBackground(self, w, h, {
        blur = true,
        outlineColor = CybeRp.UI.GetColor("accent"),
    })

    CybeRp.UI.DrawShadowedText(self.HeaderText, "CybeRp.Header", self.Padding, self.Padding, CybeRp.UI.GetColor("accent"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    -- Footer branding
    local footer = string.format("%s v1.0 - Powered by Unsound Studios", self.HeaderText or "CybeRp")
    CybeRp.UI.DrawShadowedText(footer, "CybeRp.Footer", self.Padding, h - self.Padding - 14, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

vgui.Register("CybeRpFrame", PANEL, "DFrame")



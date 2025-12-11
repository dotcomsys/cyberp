local rarityColors = {
    common = Color(170, 190, 205),
    uncommon = Color(0, 200, 180),
    rare = Color(0, 140, 255),
    epic = Color(200, 80, 255),
    legendary = Color(255, 170, 0),
}

local SLOT_LABELS = {
    HEAD = "Optics",
    NEURAL = "Neural",
    TORSO = "Torso",
    ARMS = "Arms",
    LEGS = "Legs",
}

local PANEL = {}

function PANEL:Init()
    self:SetSize(140, 120)
    self.slotId = "UNKNOWN"
    self.module = nil

    self.ActivateBtn = vgui.Create("CybeRpPanelButton", self)
    self.ActivateBtn:SetText("Activate")
    self.ActivateBtn:SetWide(90)
    self.ActivateBtn:SetTall(24)
    self.ActivateBtn:SetVisible(false)
    self.ActivateBtn.DoClick = function()
        if not self.module or not self.module.id then return end
        if CybeRp.NetActivateCyberware then
            CybeRp.NetActivateCyberware(self.module.id)
        end
    end
end

function PANEL:SetSlotId(slot)
    self.slotId = slot or "UNKNOWN"
end

function PANEL:SetModule(mod)
    self.module = mod
    self.ActivateBtn:SetVisible(mod and mod.passive == false)
end

function PANEL:Paint(w, h)
    local colPanel = CybeRp.UI.GetColor("panel")
    draw.RoundedBox(8, 0, 0, w, h, colPanel)

    local label = SLOT_LABELS[self.slotId] or self.slotId or "Slot"
    CybeRp.UI.DrawShadowedText(label, "CybeRp.Small", 8, 6, CybeRp.UI.GetColor("muted"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    if not self.module then
        CybeRp.UI.DrawShadowedText("Empty", "CybeRp.Body", w / 2, h / 2, CybeRp.UI.GetColor("muted"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    local name = self.module.name or self.module.id or "Unknown"
    local desc = self.module.desc or ""
    local accent = CybeRp.UI.GetColor("accent")
    if self.module.rarity then
        accent = rarityColors[string.lower(self.module.rarity)] or accent
    end

    CybeRp.UI.DrawShadowedText(name, "CybeRp.Subheader", 8, 28, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    CybeRp.UI.DrawShadowedText(desc, "CybeRp.Tiny", 8, 52, CybeRp.UI.GetColor("muted"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    if self.module.cooldown then
        CybeRp.UI.DrawShadowedText("CD: " .. tostring(self.module.cooldown) .. "s", "CybeRp.Tiny", w - 8, h - 8, CybeRp.UI.GetColor("muted"), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end
end

function PANEL:PerformLayout(w, h)
    self.ActivateBtn:SetPos(w - self.ActivateBtn:GetWide() - 8, h - self.ActivateBtn:GetTall() - 8)
end

vgui.Register("CybeRpCyberwareSlot", PANEL, "DPanel")

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



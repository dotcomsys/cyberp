CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}
CybeRp.UI.Cyberware = CybeRp.UI.Cyberware or {}

local defaultSlots = {"Neural", "Optics", "Torso", "Arms", "Legs"}

local function rebuildSlots(body, data)
    if not IsValid(body.Grid) then return end
    body.Grid:Clear()

    local cyber = data or (CybeRp.UI.State and CybeRp.UI.State.GetCyberware and CybeRp.UI.State:GetCyberware()) or {}

    if IsValid(body.Essence) then
        body.Essence:SetText(string.format("Essence: %.1f / %.1f", cyber.essenceUsed or 0, cyber.essence or 6))
        body.Essence:SizeToContents()
    end

    local slots = cyber.slots or {}
    for _, slotId in ipairs(defaultSlots) do
        local slotPanel = body.Grid:Add("CybeRpCyberwareSlot")
        slotPanel:SetSlotId(slotId)
        slotPanel:SetModule(slots[slotId])
    end

    for slotId, module in pairs(slots) do
        if not table.HasValue(defaultSlots, slotId) then
            local slotPanel = body.Grid:Add("CybeRpCyberwareSlot")
            slotPanel:SetSlotId(slotId)
            slotPanel:SetModule(module)
        end
    end
end

local function buildFrame()
    local frame = CybeRp.UI.MakeWindow("cyberware", "Cyberware Matrix", 820, 520)

    if IsValid(frame.Body) then frame.Body:Remove() end
    frame.Body = vgui.Create("DPanel", frame)
    frame.Body:Dock(FILL)
    frame.Body:DockMargin(12, 48, 12, 12)
    frame.Body.Paint = function(pnl, w, h)
        CybeRp.UI.DrawPanelBackground(pnl, w, h, {outlineColor = CybeRp.UI.GetColor("accentAlt")})
    end

    local top = vgui.Create("DPanel", frame.Body)
    top:Dock(TOP)
    top:SetTall(42)
    top:DockMargin(12, 12, 12, 12)
    top.Paint = function() end

    local essence = vgui.Create("DLabel", top)
    essence:SetFont("CybeRp.Subheader")
    essence:SetTextColor(color_white)
    essence:Dock(LEFT)
    frame.Body.Essence = essence

    local refreshBtn = vgui.Create("CybeRpPanelButton", top)
    refreshBtn:SetText("Request Update")
    refreshBtn:SetWide(140)
    refreshBtn:Dock(RIGHT)
    refreshBtn.DoClick = function()
        hook.Run("CybeRp_UI_RequestCyberwareSnapshot")
    end

    local grid = vgui.Create("DIconLayout", frame.Body)
    grid:Dock(FILL)
    grid:DockMargin(12, 0, 12, 12)
    grid:SetSpaceX(12)
    grid:SetSpaceY(12)
    frame.Body.Grid = grid

    rebuildSlots(frame.Body, CybeRp.UI.State:GetCyberware())

    hook.Add("CybeRp_UI_CyberwareUpdated", frame, function(_, data)
        if not IsValid(frame) then return end
        rebuildSlots(frame.Body, data)
    end)

    frame.OnRemove = function()
        hook.Remove("CybeRp_UI_CyberwareUpdated", frame)
    end

    return frame
end

function CybeRp.UI.Cyberware.Open()
    buildFrame()
end

concommand.Add("cyberp_cyberware", function()
    CybeRp.UI.Cyberware.Open()
end)

-- Allow toggle behavior
function CybeRp.UI.Cyberware.Toggle()
    if IsValid(CybeRp.UI.ActiveWindows and CybeRp.UI.ActiveWindows["cyberware"]) then
        CybeRp.UI.ActiveWindows["cyberware"]:Remove()
        return
    end
    CybeRp.UI.Cyberware.Open()
end

concommand.Add("cyberp_cyberware_toggle", function()
    CybeRp.UI.Cyberware.Toggle()
end)



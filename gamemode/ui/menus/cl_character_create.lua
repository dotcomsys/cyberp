CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}
CybeRp.UI.Character = CybeRp.UI.Character or {}

local function clearChildren(panel)
    for _, child in ipairs(panel:GetChildren()) do
        child:Remove()
    end
end

local function buildProfile(frame, data)
    if not IsValid(frame.Body) then return end
    clearChildren(frame.Body)

    local info = {
        {"Callsign", data.callsign ~= "" and data.callsign or "Pending"},
        {"Faction", data.faction or "Unaffiliated"},
        {"Assignment", data.job or "Civilian"},
        {"Level", string.format("%d  (%d / %d XP)", data.level or 1, data.xp or 0, data.xpMax or 0)},
        {"Credits", string.Comma(data.credits or 0)},
    }

    for _, row in ipairs(info) do
        local line = frame.Body:Add("DPanel")
        line:Dock(TOP)
        line:SetTall(42)
        line:DockMargin(0, 0, 0, 6)
        line.Paint = function(pnl, w, h)
            draw.RoundedBox(6, 0, 0, w, h, CybeRp.UI.GetColor("panel"))
            CybeRp.UI.DrawNeonBorder(w, h, 1, CybeRp.UI.GetColor("accent"))
        end

        local label = vgui.Create("DLabel", line)
        label:SetFont("CybeRp.Small")
        label:SetTextColor(CybeRp.UI.GetColor("muted"))
        label:SetText(row[1])
        label:Dock(LEFT)
        label:DockMargin(10, 0, 0, 0)
        label:SizeToContents()

        local value = vgui.Create("DLabel", line)
        value:SetFont("CybeRp.Subheader")
        value:SetTextColor(color_white)
        value:SetText(row[2])
        value:Dock(RIGHT)
        value:DockMargin(0, 0, 12, 0)
        value:SizeToContents()
    end
end

local function buildFrame()
    local frame = CybeRp.UI.MakeWindow("character", "CybeRp Identity", 640, 460)

    if IsValid(frame.BodyWrapper) then frame.BodyWrapper:Remove() end
    frame.BodyWrapper = vgui.Create("DPanel", frame)
    frame.BodyWrapper:Dock(FILL)
    frame.BodyWrapper:DockMargin(12, 48, 12, 12)
    frame.BodyWrapper.Paint = function(pnl, w, h)
        CybeRp.UI.DrawPanelBackground(pnl, w, h, {outlineColor = CybeRp.UI.GetColor("accent")})
    end

    local top = vgui.Create("DPanel", frame.BodyWrapper)
    top:Dock(TOP)
    top:SetTall(44)
    top:DockMargin(8, 8, 8, 8)
    top.Paint = function() end

    local refresh = vgui.Create("CybeRpPanelButton", top)
    refresh:SetText("Request Snapshot")
    refresh:SetWide(150)
    refresh:Dock(RIGHT)
    refresh.DoClick = function()
        hook.Run("CybeRp_UI_RequestPlayerSnapshot")
    end

    local reroll = vgui.Create("CybeRpPanelButton", top)
    reroll:SetText("Request Re-roll")
    reroll:SetWide(140)
    reroll:Dock(LEFT)
    reroll.DoClick = function()
        hook.Run("CybeRp_UI_CharacterCreateRequested")
    end

    local scroll = vgui.Create("DScrollPanel", frame.BodyWrapper)
    scroll:Dock(FILL)
    scroll:DockMargin(8, 0, 8, 8)

    local container = vgui.Create("DPanel", scroll)
    container:Dock(TOP)
    container:DockMargin(0, 0, 0, 0)
    container:SetTall(320)
    container.Paint = function() end
    frame.Body = container

    buildProfile(frame, CybeRp.UI.State:GetPlayer())

    hook.Add("CybeRp_UI_PlayerDataUpdated", frame, function(_, data)
        if not IsValid(frame) then return end
        buildProfile(frame, data)
    end)

    frame.OnRemove = function()
        hook.Remove("CybeRp_UI_PlayerDataUpdated", frame)
    end

    return frame
end

function CybeRp.UI.Character.Open()
    buildFrame()
end

concommand.Add("cyberp_character", function()
    CybeRp.UI.Character.Open()
end)



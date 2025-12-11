CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}
CybeRp.UI.SettingsMenu = CybeRp.UI.SettingsMenu or {}

local function addCheckbox(parent, label, key)
    local row = parent:Add("DPanel")
    row:Dock(TOP)
    row:SetTall(36)
    row:DockMargin(0, 0, 0, 6)
    row.Paint = function(pnl, w, h)
        draw.RoundedBox(6, 0, 0, w, h, CybeRp.UI.GetColor("panel"))
    end

    local cb = vgui.Create("DCheckBoxLabel", row)
    cb:SetText(label)
    cb:SetFont("CybeRp.Body")
    cb:SetTextColor(color_white)
    cb:SetValue(CybeRp.UI.Settings[key] and 1 or 0)
    cb:Dock(FILL)
    cb:DockMargin(8, 0, 0, 0)

    cb.OnChange = function(_, val)
        CybeRp.UI.Settings[key] = val
    end
end

local function buildFrame()
    local frame = CybeRp.UI.MakeWindow("settings", "UI Settings", 520, 360)

    if IsValid(frame.Body) then frame.Body:Remove() end
    frame.Body = vgui.Create("DPanel", frame)
    frame.Body:Dock(FILL)
    frame.Body:DockMargin(12, 48, 12, 12)
    frame.Body.Paint = function(pnl, w, h)
        CybeRp.UI.DrawPanelBackground(pnl, w, h, {outlineColor = CybeRp.UI.GetColor("outline")})
    end

    local list = vgui.Create("DScrollPanel", frame.Body)
    list:Dock(FILL)
    list:DockMargin(8, 8, 8, 8)

    addCheckbox(list, "Minimal HUD (hide credits tile)", "minimalHud")
    addCheckbox(list, "Always show interact hints", "alwaysShowVitals")

    return frame
end

function CybeRp.UI.SettingsMenu.Open()
    buildFrame()
end

concommand.Add("cyberp_ui_settings", function()
    CybeRp.UI.SettingsMenu.Open()
end)



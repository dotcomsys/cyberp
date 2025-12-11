CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}
CybeRp.UI.Factions = CybeRp.UI.Factions or {}

local function clearChildren(panel)
    for _, child in ipairs(panel:GetChildren()) do
        child:Remove()
    end
end

local function rebuild(body, data)
    if not IsValid(body.List) then return end
    clearChildren(body.List)

    local faction = data.faction or "Unaffiliated"
    local standing = data.factionStanding or {}

    local header = body.List:Add("DLabel")
    header:SetFont("CybeRp.Subheader")
    header:SetTextColor(color_white)
    header:SetText("Current: " .. faction)
    header:Dock(TOP)
    header:DockMargin(0, 0, 0, 10)
    header:SizeToContents()

    if table.IsEmpty(standing) then
        local empty = body.List:Add("DLabel")
        empty:SetFont("CybeRp.Tiny")
        empty:SetTextColor(CybeRp.UI.GetColor("muted"))
        empty:SetText("No faction telemetry received.")
        empty:Dock(TOP)
        empty:SizeToContents()
        return
    end

    for name, rep in pairs(standing) do
        local row = body.List:Add("DPanel")
        row:SetTall(46)
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 8)
        row.Paint = function(pnl, w, h)
            draw.RoundedBox(6, 0, 0, w, h, CybeRp.UI.GetColor("panel"))
            CybeRp.UI.DrawNeonBorder(w, h, 1, CybeRp.UI.GetColor("accentAlt"))
        end

        local label = vgui.Create("DLabel", row)
        label:SetFont("CybeRp.Small")
        label:SetTextColor(color_white)
        label:SetText(name)
        label:Dock(LEFT)
        label:DockMargin(10, 0, 0, 0)
        label:SizeToContents()

        local val = vgui.Create("DLabel", row)
        val:SetFont("CybeRp.Small")
        val:SetTextColor(rep >= 0 and CybeRp.UI.GetColor("success") or CybeRp.UI.GetColor("danger"))
        val:SetText(string.format("%d", rep))
        val:Dock(RIGHT)
        val:DockMargin(0, 0, 10, 0)
        val:SizeToContents()
    end
end

local function buildFrame()
    local frame = CybeRp.UI.MakeWindow("factions", "Faction Status", 560, 420)

    if IsValid(frame.Body) then frame.Body:Remove() end
    frame.Body = vgui.Create("DPanel", frame)
    frame.Body:Dock(FILL)
    frame.Body:DockMargin(12, 48, 12, 12)
    frame.Body.Paint = function(pnl, w, h)
        CybeRp.UI.DrawPanelBackground(pnl, w, h, {outlineColor = CybeRp.UI.GetColor("outline")})
    end

    local refresh = vgui.Create("CybeRpPanelButton", frame.Body)
    refresh:SetText("Sync Faction Data")
    refresh:SetWide(150)
    refresh:Dock(TOP)
    refresh:DockMargin(12, 12, 12, 8)
    refresh.DoClick = function()
        hook.Run("CybeRp_UI_RequestPlayerSnapshot")
    end

    local list = vgui.Create("DScrollPanel", frame.Body)
    list:Dock(FILL)
    list:DockMargin(12, 0, 12, 12)
    frame.Body.List = vgui.Create("DListLayout", list)
    frame.Body.List:Dock(FILL)

    rebuild(frame.Body, CybeRp.UI.State:GetPlayer())

    hook.Add("CybeRp_UI_PlayerDataUpdated", frame, function(_, data)
        if not IsValid(frame) then return end
        rebuild(frame.Body, data)
    end)

    frame.OnRemove = function()
        hook.Remove("CybeRp_UI_PlayerDataUpdated", frame)
    end

    return frame
end

function CybeRp.UI.Factions.Open()
    buildFrame()
end

concommand.Add("cyberp_factions", function()
    CybeRp.UI.Factions.Open()
end)



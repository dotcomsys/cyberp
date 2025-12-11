CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}
CybeRp.UI.Jobs = CybeRp.UI.Jobs or {}

local function clearChildren(panel)
    for _, child in ipairs(panel:GetChildren()) do
        child:Remove()
    end
end

local function rebuildJobs(body, playerData)
    if not IsValid(body.List) then return end
    clearChildren(body.List)

    local jobs = (playerData and playerData.jobs) or {}
    if table.IsEmpty(jobs) then
        local empty = body.List:Add("DLabel")
        empty:SetFont("CybeRp.Small")
        empty:SetTextColor(CybeRp.UI.GetColor("muted"))
        empty:SetText("Awaiting job feed from server...")
        empty:Dock(TOP)
        empty:DockMargin(0, 0, 0, 6)
        empty:SizeToContents()
        return
    end

    for _, job in ipairs(jobs) do
        local card = body.List:Add("DPanel")
        card:SetTall(76)
        card:Dock(TOP)
        card:DockMargin(0, 0, 0, 10)
        card.Paint = function(pnl, w, h)
            draw.RoundedBox(6, 0, 0, w, h, CybeRp.UI.GetColor("panel"))
            CybeRp.UI.DrawNeonBorder(w, h, 1, CybeRp.UI.GetColor("accent"))
        end

        local name = vgui.Create("DLabel", card)
        name:SetFont("CybeRp.Subheader")
        name:SetTextColor(color_white)
        name:SetText(job.name or "Unknown Contract")
        name:Dock(TOP)
        name:DockMargin(10, 6, 10, 0)
        name:SizeToContents()

        local desc = vgui.Create("DLabel", card)
        desc:SetFont("CybeRp.Tiny")
        desc:SetTextColor(CybeRp.UI.GetColor("muted"))
        desc:SetText(job.description or "No intel supplied.")
        desc:SetWrap(true)
        desc:SetTall(32)
        desc:Dock(TOP)
        desc:DockMargin(10, 2, 10, 0)

        local apply = vgui.Create("CybeRpPanelButton", card)
        apply:SetText("Request Contract")
        apply:SetWide(140)
        apply:Dock(RIGHT)
        apply:DockMargin(0, 16, 10, 10)
        apply.DoClick = function()
            hook.Run("CybeRp_UI_JobSelected", job)
        end

        local reward = vgui.Create("DLabel", card)
        reward:SetFont("CybeRp.Small")
        reward:SetTextColor(CybeRp.UI.GetColor("accent"))
        reward:SetText(string.format("%s cr", string.Comma(job.reward or 0)))
        reward:Dock(RIGHT)
        reward:DockMargin(0, 20, 16, 0)
        reward:SizeToContents()
    end
end

local function buildFrame()
    local frame = CybeRp.UI.MakeWindow("jobs", "Job Board", 680, 520)

    if IsValid(frame.Body) then frame.Body:Remove() end
    frame.Body = vgui.Create("DPanel", frame)
    frame.Body:Dock(FILL)
    frame.Body:DockMargin(12, 48, 12, 12)
    frame.Body.Paint = function(pnl, w, h)
        CybeRp.UI.DrawPanelBackground(pnl, w, h, {outlineColor = CybeRp.UI.GetColor("accentAlt")})
    end

    local refresh = vgui.Create("CybeRpPanelButton", frame.Body)
    refresh:SetText("Refresh Contracts")
    refresh:SetWide(160)
    refresh:Dock(TOP)
    refresh:DockMargin(12, 12, 12, 8)
    refresh.DoClick = function()
        hook.Run("CybeRp_UI_RequestJobFeed")
    end

    local listHolder = vgui.Create("DScrollPanel", frame.Body)
    listHolder:Dock(FILL)
    listHolder:DockMargin(12, 0, 12, 12)
    frame.Body.List = vgui.Create("DListLayout", listHolder)
    frame.Body.List:Dock(FILL)
    frame.Body.List:DockMargin(0, 0, 0, 0)

    rebuildJobs(frame.Body, CybeRp.UI.State:GetPlayer())

    hook.Add("CybeRp_UI_PlayerDataUpdated", frame, function(_, data)
        if not IsValid(frame) then return end
        rebuildJobs(frame.Body, data)
    end)

    frame.OnRemove = function()
        hook.Remove("CybeRp_UI_PlayerDataUpdated", frame)
    end

    return frame
end

function CybeRp.UI.Jobs.Open()
    buildFrame()
end

concommand.Add("cyberp_jobs", function()
    CybeRp.UI.Jobs.Open()
end)



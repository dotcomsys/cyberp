CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}
CybeRp.UI.Contracts = CybeRp.UI.Contracts or {}

local function requestContracts()
    net.Start(CybeRp.NET.CONTRACT_ACCEPT)
        net.WriteString("") -- request list
    net.SendToServer()
end

local function buildContractsFrame(data)
    local frame = CybeRp.UI.MakeWindow("contracts", "Contracts", 520, 600)

    if IsValid(frame.Body) then frame.Body:Remove() end
    frame.Body = vgui.Create("DPanel", frame)
    frame.Body:Dock(FILL)
    frame.Body:DockMargin(12, 48, 12, 12)
    frame.Body.Paint = function(pnl, w, h)
        CybeRp.UI.DrawPanelBackground(pnl, w, h, { outlineColor = CybeRp.UI.GetColor("accentAlt") })
    end

    local list = vgui.Create("DScrollPanel", frame.Body)
    list:Dock(FILL)
    list:DockMargin(8, 8, 8, 8)

    for _, c in ipairs(data or {}) do
        local row = vgui.Create("DPanel", list)
        row:Dock(TOP)
        row:SetTall(80)
        row:DockMargin(0, 0, 0, 6)
        row.Paint = function(pnl, w, h)
            CybeRp.UI.DrawPanelBackground(pnl, w, h, { outline = true, outlineColor = CybeRp.UI.GetColor("outline") })
        end

        local name = vgui.Create("DLabel", row)
        name:SetFont("CybeRp.Subheader")
        name:SetText(c.id or "contract")
        name:Dock(TOP)
        name:DockMargin(8, 6, 8, 0)
        name:SizeToContents()

        local desc = vgui.Create("DLabel", row)
        desc:SetFont("CybeRp.Tiny")
        desc:SetText(c.desc or "")
        desc:Dock(TOP)
        desc:DockMargin(8, 2, 8, 0)
        desc:SetWrap(true)
        desc:SetTall(28)

        local reward = vgui.Create("DLabel", row)
        reward:SetFont("CybeRp.Small")
        reward:SetText("Reward: " .. (c.reward or 0) .. "₡")
        reward:Dock(LEFT)
        reward:DockMargin(8, 0, 0, 8)
        reward:SizeToContents()

        local btnAccept = vgui.Create("CybeRpPanelButton", row)
        btnAccept:SetText("Accept")
        btnAccept:SetWide(90)
        btnAccept:Dock(RIGHT)
        btnAccept:DockMargin(8, 8, 8, 8)
        btnAccept.DoClick = function()
            net.Start(CybeRp.NET.CONTRACT_ACCEPT)
                net.WriteString(c.id or "")
            net.SendToServer()
        end

        local btnComplete = vgui.Create("CybeRpPanelButton", row)
        btnComplete:SetText("Complete")
        btnComplete:SetWide(90)
        btnComplete:Dock(RIGHT)
        btnComplete:DockMargin(0, 8, 0, 8)
        btnComplete.DoClick = function()
            net.Start(CybeRp.NET.CONTRACT_COMPLETE)
                net.WriteString(c.id or "")
            net.SendToServer()
        end
    end

    frame:MakePopup()
    frame:Center()
end

concommand.Add("cyberp_contracts", function()
    requestContracts()
end)

hook.Add("CybeRp_Net_Contracts", "CybeRp_UI_Contracts", function(payload)
    buildContractsFrame(payload or {})
end)



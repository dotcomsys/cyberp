CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}
CybeRp.UI.Vendor = CybeRp.UI.Vendor or {}

local function buildVendorFrame(data)
    local frame = CybeRp.UI.MakeWindow("vendor", "Vendor", 480, 560)

    if IsValid(frame.Body) then frame.Body:Remove() end
    frame.Body = vgui.Create("DPanel", frame)
    frame.Body:Dock(FILL)
    frame.Body:DockMargin(12, 48, 12, 12)
    frame.Body.Paint = function(pnl, w, h)
        CybeRp.UI.DrawPanelBackground(pnl, w, h, { outlineColor = CybeRp.UI.GetColor("accent") })
    end

    local list = vgui.Create("DScrollPanel", frame.Body)
    list:Dock(FILL)
    list:DockMargin(8, 8, 8, 8)

    for _, entry in ipairs(data.stock or {}) do
        local row = vgui.Create("DPanel", list)
        row:Dock(TOP)
        row:SetTall(64)
        row:DockMargin(0, 0, 0, 6)
        row.Paint = function(pnl, w, h)
            CybeRp.UI.DrawPanelBackground(pnl, w, h, { outline = true, outlineColor = CybeRp.UI.GetColor("outline") })
        end

        local name = vgui.Create("DLabel", row)
        name:SetFont("CybeRp.Subheader")
        name:SetText(entry.name or entry.id or "Item")
        name:Dock(TOP)
        name:DockMargin(8, 6, 8, 0)
        name:SizeToContents()

        local desc = vgui.Create("DLabel", row)
        desc:SetFont("CybeRp.Tiny")
        desc:SetText(entry.desc or "")
        desc:Dock(TOP)
        desc:DockMargin(8, 2, 8, 0)
        desc:SetWrap(true)
        desc:SetTall(24)

        local btnBuy = vgui.Create("CybeRpPanelButton", row)
        btnBuy:SetText("Buy (" .. (entry.price or 0) .. "₡)")
        btnBuy:SetWide(120)
        btnBuy:Dock(RIGHT)
        btnBuy:DockMargin(8, 8, 8, 8)
        btnBuy.DoClick = function()
            net.Start(CybeRp.NET.VENDOR_BUY)
                net.WriteString(entry.id)
                net.WriteUInt(1, 8)
            net.SendToServer()
        end

        local btnSell = vgui.Create("CybeRpPanelButton", row)
        btnSell:SetText("Sell")
        btnSell:SetWide(80)
        btnSell:Dock(RIGHT)
        btnSell:DockMargin(0, 8, 0, 8)
        btnSell.DoClick = function()
            net.Start(CybeRp.NET.VENDOR_SELL)
                net.WriteString(entry.id)
                net.WriteUInt(1, 8)
            net.SendToServer()
        end
    end

    frame:MakePopup()
    frame:Center()
end

hook.Add("CybeRp_Net_VendorStock", "CybeRp_UI_OpenVendor", function(data)
    buildVendorFrame(data or {})
end)



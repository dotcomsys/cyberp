CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}
CybeRp.UI.HUD = CybeRp.UI.HUD or {}
CybeRp.ClientState = CybeRp.ClientState or {}

local colors = {
    accent   = CybeRp.UI.GetColor and CybeRp.UI.GetColor("accent") or Color(0, 255, 214),
    accent2  = CybeRp.UI.GetColor and CybeRp.UI.GetColor("accentAlt") or Color(255, 55, 155),
    panel    = CybeRp.UI.GetColor and CybeRp.UI.GetColor("panel") or Color(18, 28, 42, 230),
    text     = CybeRp.UI.GetColor and CybeRp.UI.GetColor("text") or color_white,
    muted    = CybeRp.UI.GetColor and CybeRp.UI.GetColor("muted") or Color(180, 200, 210),
    danger   = CybeRp.UI.GetColor and CybeRp.UI.GetColor("danger") or Color(255, 70, 90),
    outline  = CybeRp.UI.GetColor and CybeRp.UI.GetColor("outline") or Color(0, 130, 255),
}

local fonts = {
    header = "CybeRp.Header",
    body   = "CybeRp.Body",
    small  = "CybeRp.Small",
}

local hidden = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
}

hook.Add("HUDShouldDraw", "CybeRp_HideDefaultHUD", function(name)
    if hidden[name] then return false end
end)

CybeRp.UI.HUD.Hint = {text = "", expires = 0}

function CybeRp.UI.HUD.ShowHint(text, duration)
    CybeRp.UI.HUD.Hint.text = text or ""
    CybeRp.UI.HUD.Hint.expires = CurTime() + (duration or 2.5)
end

hook.Add("CybeRp_UI_ShowHint", "CybeRp_HUDHint", function(text, duration)
    CybeRp.UI.HUD.ShowHint(text, duration)
end)

local function drawBar(x, y, w, h, pct, colFill)
    pct = math.Clamp(pct or 0, 0, 1)
    surface.SetDrawColor(colors.panel)
    surface.DrawRect(x, y, w, h)

    surface.SetDrawColor(colFill)
    surface.DrawRect(x, y, w * pct, h)

    surface.SetDrawColor(colors.outline)
    surface.DrawOutlinedRect(x, y, w, h)
end

local function getVitals()
    local ply = LocalPlayer()
    if not IsValid(ply) then
        return {health = 0, armor = 0}
    end
    return {
        health = math.max(0, ply:Health()),
        armor = math.max(0, ply:Armor())
    }
end

function CybeRp.UI.HUD.DrawVitals(playerState, x, bottom)
    local vitals = getVitals()
    local barW, barH = 220, 18
    local pad = 6

    -- Health
    drawBar(x, bottom, barW, barH, vitals.health / 100, colors.accent)
    draw.SimpleText("HEALTH " .. vitals.health, fonts.body, x + 8, bottom + barH / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    -- Armor
    drawBar(x, bottom + barH + pad, barW, barH, vitals.armor / 100, colors.accent2)
    draw.SimpleText("ARMOR " .. vitals.armor, fonts.body, x + 8, bottom + barH + pad + barH / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function CybeRp.UI.HUD.DrawCredits(playerState, x, bottom)
    local credits = (CybeRp.ClientState and CybeRp.ClientState.credits) or 0
    draw.SimpleText("CREDITS", fonts.small, x, bottom, colors.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    draw.SimpleText(string.Comma(credits) .. "₡", fonts.header, x, bottom - 6, colors.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

local function drawContractsBadge()
    local contracts = CybeRp.ClientState and CybeRp.ClientState.contracts or {}
    local activeCount = 0
    local nearest = math.huge
    local nearestLabel = nil
    for _, c in ipairs(contracts or {}) do
        if c.active and c.deadline then
            activeCount = activeCount + 1
            nearest = math.min(nearest, c.deadline - CurTime())
            nearestLabel = nearestLabel or (c.type and c.type:upper() or c.id)
        end
    end
    if activeCount <= 0 then return end

    local text = string.format("CONTRACTS: %d (%.0fs%s)", activeCount, math.max(0, nearest), nearestLabel and (" " .. nearestLabel) or "")
    local w, h = surface.GetTextSize(text)
    surface.SetFont("CybeRp.Small")
    w, h = surface.GetTextSize(text)
    local pad = 8
    local bw, bh = w + pad * 2, h + pad
    local x = ScrW() - bw - 24
    local y = 24
    draw.RoundedBox(8, x, y, bw, bh, colors.panel)
    CybeRp.UI.DrawNeonBorder(bw, bh, 1, colors.accent)
    CybeRp.UI.DrawShadowedText(text, "CybeRp.Small", x + pad, y + bh / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function CybeRp.UI.HUD.DrawTargetHint(text)
    local w, h = 320, 36
    local x = (ScrW() - w) / 2
    local y = ScrH() * 0.72
    surface.SetDrawColor(colors.panel)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(colors.outline)
    surface.DrawOutlinedRect(x, y, w, h)
    draw.SimpleText(text or "", fonts.body, x + w / 2, y + h / 2, colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("HUDPaint", "CybeRp_HUD", function()
    if not CybeRp.UI then return end

    local settings = CybeRp.UI.Settings or {}
    local playerState = (CybeRp.UI.State and CybeRp.UI.State.GetPlayer and CybeRp.UI.State:GetPlayer()) or {}
    local x = 24
    local bottom = ScrH() - 140

    CybeRp.UI.HUD.DrawVitals(playerState, x, bottom)
    if not settings.minimalHud then
        CybeRp.UI.HUD.DrawCredits(playerState, x + 280, bottom)
    end

    if settings.alwaysShowVitals then
        local hint = CybeRp.UI.HUD.Hint
        if hint.text ~= "" and CurTime() < hint.expires then
            CybeRp.UI.HUD.DrawTargetHint(hint.text)
        end
    end

    drawContractsBadge()
end)


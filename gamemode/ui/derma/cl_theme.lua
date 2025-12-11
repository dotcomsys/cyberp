-- CybeRp UI theme + helpers
CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}

local theme = {}
local gradient = Material("vgui/gradient-l")
local blurMat = Material("pp/blurscreen")
local glow = Material("sprites/light_glow02_add")

local function drawOutline(x, y, w, h, thickness)
    thickness = math.max(1, math.floor(thickness or 1))
    for i = 0, thickness - 1 do
        surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
    end
end

local fallback = {
    bg = Color(6, 10, 14, 235),
    bgStrong = Color(12, 18, 28, 255),
    panel = Color(18, 28, 42, 230),
    accent = Color(0, 255, 214),
    accentAlt = Color(255, 55, 155),
    outline = Color(0, 130, 255),
    text = color_white,
    muted = Color(180, 200, 210),
    warning = Color(255, 170, 0),
    danger = Color(255, 70, 90),
    success = Color(90, 255, 150),
}

local colors = CybeRp.Colors or fallback

function CybeRp.UI.GetColor(key)
    return colors[key] or fallback[key] or color_white
end

local function drawBlur(panel, layers, density)
    local x, y = panel:LocalToScreen(0, 0)
    local scrW, scrH = ScrW(), ScrH()

    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(blurMat)

    for i = 1, layers do
        blurMat:SetFloat("$blur", (i / layers) * (density or 5))
        blurMat:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(-x, -y, scrW, scrH)
    end
end

function CybeRp.UI.DrawPanelBackground(panel, w, h, opts)
    opts = opts or {}
    local col = opts.color or CybeRp.UI.GetColor("panel")

    if opts.blur then
        drawBlur(panel, 2, 6)
    end

    draw.RoundedBox(opts.radius or 8, 0, 0, w, h, col)

    surface.SetDrawColor(255, 255, 255, 9)
    surface.SetMaterial(gradient)
    surface.DrawTexturedRect(0, 0, w * 0.4, h)

    if opts.outline ~= false then
        surface.SetDrawColor(opts.outlineColor or CybeRp.UI.GetColor("outline"))
        drawOutline(0, 0, w, h, opts.thickness or 2)
    end
end

function CybeRp.UI.DrawNeonBorder(w, h, thickness, col)
    thickness = thickness or 2
    col = col or CybeRp.UI.GetColor("accent")

    surface.SetDrawColor(col)
    drawOutline(0, 0, w, h, thickness)

    surface.SetMaterial(glow)
    surface.SetDrawColor(col.r, col.g, col.b, 60)
    surface.DrawTexturedRect(-thickness * 2, -thickness * 2, w + thickness * 4, h + thickness * 4)
end

function CybeRp.UI.DrawShadowedText(text, font, x, y, col, alignX, alignY)
    draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, 180), alignX, alignY)
    draw.SimpleText(text, font, x, y, col, alignX, alignY)
end

function CybeRp.UI.MakeWindow(key, title, w, h)
    local existing = CybeRp.UI.ActiveWindows and CybeRp.UI.ActiveWindows[key]
    if IsValid(existing) then
        existing:MakePopup()
        existing:Center()
        return existing
    end

    local frame = vgui.Create("CybeRpFrame")
    frame:SetSize(w, h)
    frame:SetHeaderText(title or "CybeRp")
    frame:Center()
    frame:MakePopup()

    CybeRp.UI.ActiveWindows = CybeRp.UI.ActiveWindows or {}
    CybeRp.UI.ActiveWindows[key] = frame

    frame.OnRemove = function()
        if CybeRp.UI.ActiveWindows[key] == frame then
            CybeRp.UI.ActiveWindows[key] = nil
        end
    end

    return frame
end



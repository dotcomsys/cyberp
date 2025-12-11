CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}
CybeRp.UI.HUD = CybeRp.UI.HUD or {}

local function drawBar(x, y, w, h, value, maxValue, label, col)
    local pct = math.Clamp(maxValue > 0 and value / maxValue or 0, 0, 1)

    surface.SetDrawColor(CybeRp.UI.GetColor("bgStrong"))
    surface.DrawRect(x, y, w, h)

    surface.SetDrawColor(col.r, col.g, col.b, 180)
    surface.DrawRect(x, y, w * pct, h)

    surface.SetDrawColor(col.r, col.g, col.b, 40)
    surface.DrawRect(x, y, w * math.Clamp(pct + 0.05, 0, 1), h)

    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawOutlinedRect(x, y, w, h, 1)

    CybeRp.UI.DrawShadowedText(label, "CybeRp.Small", x + 8, y + h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    CybeRp.UI.DrawShadowedText(string.format("%d / %d", math.floor(value), math.floor(maxValue)), "CybeRp.Tiny", x + w - 8, y + h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

function CybeRp.UI.HUD.DrawVitals(state, x, y)
    local ply = LocalPlayer()
    local hp = state.health or ply:Health()
    local maxHp = state.maxHealth or ply:GetMaxHealth() or 100
    local armor = state.armor or ply:Armor()
    local maxArmor = state.maxArmor or 100
    local stamina = state.stamina or 100
    local maxStamina = state.maxStamina or 100

    drawBar(x, y, 260, 20, hp, maxHp, "VITALS", CybeRp.UI.GetColor("success"))
    drawBar(x, y + 28, 260, 16, armor, maxArmor, "SHIELD", CybeRp.UI.GetColor("accent"))
    drawBar(x, y + 52, 260, 14, stamina, maxStamina, "STAMINA", CybeRp.UI.GetColor("warning"))
end

function CybeRp.UI.HUD.DrawCredits(state, x, y)
    local credits = state.credits or 0
    local job = state.job or "Civilian"
    local faction = state.faction or "Unaffiliated"

    local w, h = 240, 70
    draw.RoundedBox(8, x, y, w, h, CybeRp.UI.GetColor("panel"))
    CybeRp.UI.DrawNeonBorder(w, h, 1, CybeRp.UI.GetColor("accentAlt"))

    CybeRp.UI.DrawShadowedText("CREDITS", "CybeRp.Tiny", x + 12, y + 10, CybeRp.UI.GetColor("muted"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    CybeRp.UI.DrawShadowedText(string.Comma(credits), "CybeRp.Header", x + 12, y + 28, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    CybeRp.UI.DrawShadowedText(faction, "CybeRp.Tiny", x + 12, y + 52, CybeRp.UI.GetColor("muted"), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    CybeRp.UI.DrawShadowedText(job, "CybeRp.Small", x + w - 12, y + 52, CybeRp.UI.GetColor("accent"), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

function CybeRp.UI.HUD.DrawTargetHint(text)
    if not text or text == "" then return end
    local w, h = 400, 28
    local x, y = ScrW() / 2 - w / 2, ScrH() * 0.65
    draw.RoundedBox(6, x, y, w, h, CybeRp.UI.GetColor("bg"))
    CybeRp.UI.DrawNeonBorder(w, h, 1, CybeRp.UI.GetColor("accent"))
    CybeRp.UI.DrawShadowedText(text, "CybeRp.Body", x + w / 2, y + h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end



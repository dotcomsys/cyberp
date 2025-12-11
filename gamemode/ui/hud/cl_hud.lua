CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}
CybeRp.UI.HUD = CybeRp.UI.HUD or {}

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

hook.Add("HUDPaint", "CybeRp_HUD", function()
    if not CybeRp.UI.State then return end

    local settings = CybeRp.UI.Settings or {}
    local playerState = CybeRp.UI.State:GetPlayer()
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
end)


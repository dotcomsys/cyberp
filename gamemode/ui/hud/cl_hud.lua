hook.Add("HUDPaint", "CybeRp_HUD", function()
    draw.SimpleText("CYBERPUNK RP", "DermaLarge", 25, 25, Color(0, 255, 255))

    local ply = LocalPlayer()
    draw.SimpleText("Credits: " .. (ply:GetCredits() or 0), "DermaDefault", 25, 60, Color(255,255,255))
end)

-- Disable default HUD elements
local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
}

hook.Add("HUDShouldDraw", "CybeRp_HideHUD", function(name)
    if hide[name] then return false end
end)


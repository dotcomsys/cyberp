-- CybeRp UI fonts
CybeRp = CybeRp or {}
CybeRp.UI = CybeRp.UI or {}

local baseFont = system.IsWindows() and "Bahnschrift" or "Arial"

local fontDefs = {
    {name = "CybeRp.Header", size = 24, weight = 800},
    {name = "CybeRp.Subheader", size = 20, weight = 700},
    {name = "CybeRp.Body", size = 18, weight = 600},
    {name = "CybeRp.Small", size = 15, weight = 500},
    {name = "CybeRp.Tiny", size = 13, weight = 500},
    {name = "CybeRp.Footer", size = 13, weight = 500, italic = true},
}

CybeRp.UI.Fonts = CybeRp.UI.Fonts or {}

for _, def in ipairs(fontDefs) do
    surface.CreateFont(def.name, {
        font = baseFont,
        size = def.size,
        weight = def.weight,
        extended = true,
        italic = def.italic or false,
    })

    CybeRp.UI.Fonts[def.name] = def.name
end



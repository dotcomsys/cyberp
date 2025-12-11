-- CybeRp - cl_init.lua (client)

include("shared.lua")

local function IncludeClientFolder(path)
    local files, dirs = file.Find(path .. "/*", "LUA")

    for _, f in ipairs(files) do
        if string.StartWith(f, "cl_") or string.StartWith(f, "sh_") then
            include(path .. "/" .. f)
        end
    end

    for _, d in ipairs(dirs) do
        IncludeClientFolder(path .. "/" .. d)
    end
end

IncludeClientFolder("cyberp/gamemode")

function GM:Initialize()
    print("[CybeRp] Client Initialized.")
end


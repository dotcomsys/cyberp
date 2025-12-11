-- CybeRp - init.lua (server)

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- Automatically add all client files
local function AddClientFolder(path)
    local files, dirs = file.Find(path .. "/*", "LUA")

    for _, f in ipairs(files) do
        if string.StartWith(f, "cl_") or string.StartWith(f, "sh_") then
            AddCSLuaFile(path .. "/" .. f)
        end
    end

    for _, d in ipairs(dirs) do
        AddClientFolder(path .. "/" .. d)
    end
end

AddClientFolder("cyberp/gamemode")

-- SHARED FILES (server include)
local function IncludeSharedFolder(path)
    local files, dirs = file.Find(path .. "/*", "LUA")

    for _, f in ipairs(files) do
        if string.StartWith(f, "sh_") then
            include(path .. "/" .. f)
        end
    end

    for _, d in ipairs(dirs) do
        IncludeSharedFolder(path .. "/" .. d)
    end
end

-- SERVER-ONLY FILES
local function IncludeServerFolder(path)
    local files, dirs = file.Find(path .. "/*", "LUA")

    for _, f in ipairs(files) do
        if string.StartWith(f, "sv_") then
            include(path .. "/" .. f)
        end
    end

    for _, d in ipairs(dirs) do
        IncludeServerFolder(path .. "/" .. d)
    end
end

-- Load shared modules before server-specific ones
IncludeSharedFolder("cyberp/gamemode")
IncludeServerFolder("cyberp/gamemode")

-- Initialize gamemode
function GM:Initialize()
    if CybeRp.Config.Debug then
        print("[CybeRp] Server Initialized.")
    end
end


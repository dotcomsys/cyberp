-- CybeRp - shared.lua

GM.Name        = "CybeRp"
GM.Author      = "Unsound Studios"
GM.Email       = "N/A"
GM.Website     = "N/A"
GM.Version     = "0.1-alpha"

CybeRp = CybeRp or {}
CybeRp.Config = CybeRp.Config or {}

-- Universal enums
CybeRp.NET = {
    PLAYER_DATA = "cyberp_player_data",
    INVENTORY_UPDATE = "cyberp_inventory_update",
    CYBERWARE_UPDATE = "cyberp_cyberware_update",
}

-- Load shared configs
include("config/sh_config.lua")
include("config/sh_jobs.lua")
include("config/sh_factions.lua")
include("config/sh_items.lua")
include("config/sh_cyberware.lua")
include("config/sh_economy.lua")

print("[CybeRp] Shared Loaded")


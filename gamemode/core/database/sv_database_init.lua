-- SQLite is default; designed to be swappable for external drivers.
CybeRp.DB = CybeRp.DB or {}

local CHAR_TABLE = "cyberp_characters"
local INV_TABLE = "cyberp_inventories"

local function query(sqlStr)
    local result = sql.Query(sqlStr)
    if result == false then
        CybeRp.DB.LastError = sql.LastError()
        print("[CybeRp][DB] Error: " .. tostring(sql.LastError()))
    end
    return result
end

function CybeRp.DB.ToJSON(tbl)
    return util.TableToJSON(tbl or {}, false)
end

function CybeRp.DB.FromJSON(json)
    if not json or json == "" then return {} end
    local ok, res = pcall(util.JSONToTable, json)
    if ok and istable(res) then return res end
    return {}
end

function CybeRp.DB.Initialize()
    query(string.format([[
        CREATE TABLE IF NOT EXISTS %s(
            steamid TEXT PRIMARY KEY,
            data TEXT NOT NULL
        )
    ]], CHAR_TABLE))

    query(string.format([[
        CREATE TABLE IF NOT EXISTS %s(
            steamid TEXT PRIMARY KEY,
            items TEXT NOT NULL
        )
    ]], INV_TABLE))

    print("[CybeRp] Database Initialized (SQLite)")
end

-- Expose table names for the store modules.
CybeRp.DB._CHAR_TABLE = CHAR_TABLE
CybeRp.DB._INV_TABLE = INV_TABLE

hook.Add("Initialize", "CybeRp_DB_Init", function()
    CybeRp.DB.Initialize()
end)


local function ensureTables()
    if not CybeRp.DB or not CybeRp.DB._INV_TABLE then
        error("[CybeRp] Database not initialized before inventory store use.")
    end
end

function CybeRp.DB.LoadInventory(steamid)
    ensureTables()
    steamid = sql.SQLStr(steamid, true)
    local rows = sql.Query("SELECT items FROM " .. CybeRp.DB._INV_TABLE .. " WHERE steamid = " .. steamid .. " LIMIT 1;")
    if rows and rows[1] and rows[1].items then
        return CybeRp.DB.FromJSON(rows[1].items)
    end
    return {}
end

function CybeRp.DB.SaveInventory(steamid, items)
    ensureTables()
    steamid = sql.SQLStr(steamid, true)
    local json = CybeRp.DB.ToJSON(items or {})

    sql.Query(string.format([[
        REPLACE INTO %s(steamid, items)
        VALUES('%s', '%s');
    ]], CybeRp.DB._INV_TABLE, steamid, sql.SQLStr(json, true)))
end


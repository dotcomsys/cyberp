local function ensureTables()
    if not CybeRp.DB or not CybeRp.DB._CHAR_TABLE then
        error("[CybeRp] Database not initialized before character store use.")
    end
end

function CybeRp.DB.LoadCharacter(steamid)
    ensureTables()
    steamid = sql.SQLStr(steamid, true)
    local rows = sql.Query("SELECT data FROM " .. CybeRp.DB._CHAR_TABLE .. " WHERE steamid = " .. steamid .. " LIMIT 1;")
    if rows and rows[1] and rows[1].data then
        return CybeRp.DB.FromJSON(rows[1].data)
    end
    return nil
end

function CybeRp.DB.SaveCharacter(steamid, data)
    ensureTables()
    steamid = sql.SQLStr(steamid, true)
    local json = CybeRp.DB.ToJSON(data)

    sql.Query(string.format([[
        REPLACE INTO %s(steamid, data)
        VALUES('%s', '%s');
    ]], CybeRp.DB._CHAR_TABLE, steamid, sql.SQLStr(json, true)))
end


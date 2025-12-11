local function ensureTables()
    if not CybeRp.DB or not CybeRp.DB._CHAR_TABLE then
        error("[CybeRp] Database not initialized before character store use.")
    end
end

local function rowToData(row)
    if not row then return nil end
    local payload = CybeRp.DB.FromJSON(row.data)
    payload = payload or {}
    payload.id = payload.id or row.id
    payload.steamid = payload.steamid or row.steamid
    payload.name = payload.name or row.name
    payload.job = payload.job or row.job
    payload.faction = payload.faction or row.faction
    payload.credits = payload.credits or tonumber(row.credits) or 0
    return payload
end

-- Overloaded to accept player or steamid string.
function CybeRp.DB.LoadCharacter(target, callback)
    ensureTables()
    local steamid
    if IsEntity(target) then
        steamid = target:SteamID64()
    else
        steamid = tostring(target or "")
    end

    local esc = sql.SQLStr(steamid, true)
    local rows = sql.Query("SELECT * FROM " .. CybeRp.DB._CHAR_TABLE .. " WHERE steamid = " .. esc .. " LIMIT 1;")
    local data = rows and rowToData(rows[1]) or nil

    if isfunction(callback) then
        callback(data)
    end

    return data
end

-- Overloaded to accept player or (steamid, data)
function CybeRp.DB.SaveCharacter(target, data)
    ensureTables()

    local steamid, name, job, faction, credits, jsonBlob

    if IsEntity(target) then
        steamid = target:SteamID64()
        name = target:Nick()
        job = target.GetJob and target:GetJob() or "civilian"
        faction = target.GetFaction and target:GetFaction() or "NEUTRAL"
        credits = target.GetCredits and target:GetCredits() or 0
        jsonBlob = CybeRp.DB.ToJSON(target:GetCybeData() or {})
    else
        steamid = tostring(target or "")
        name = data and data.name or "Unknown"
        job = data and data.job or "civilian"
        faction = data and data.faction or "NEUTRAL"
        credits = data and data.credits or 0
        jsonBlob = CybeRp.DB.ToJSON(data)
    end

    sql.Query(string.format([[
        REPLACE INTO %s(steamid, name, job, faction, credits, data)
        VALUES(%s, %s, %s, %s, %d, %s);
    ]], CybeRp.DB._CHAR_TABLE,
        sql.SQLStr(steamid, true),
        sql.SQLStr(name or "", true),
        sql.SQLStr(job or "", true),
        sql.SQLStr(faction or "", true),
        tonumber(credits) or 0,
        sql.SQLStr(jsonBlob or "{}", true)
    ))
end

CybeRp = CybeRp or {}
CybeRp.Log = CybeRp.Log or {}
CybeRp.Logging = CybeRp.Log -- alias for readability

local Log = CybeRp.Log
local fmt = string.format

local function timestamp()
    return os.date("%H:%M:%S")
end

local function safeFormat(message, ...)
    if select("#", ...) == 0 then
        return tostring(message or "")
    end

    local ok, out = pcall(fmt, message or "", ...)
    if not ok then
        return tostring(message or "")
    end
    return out
end

local function emit(level, message, ...)
    local line = ("[%s][%s] %s"):format(timestamp(), level, safeFormat(message, ...))
    if SERVER then
        -- Server console gets a timestamped line.
        print(line)
    else
        -- Client fallback still visible in developer console.
        print(line)
    end
    return line
end

function Log.Info(message, ...)
    return emit("INFO", message, ...)
end

function Log.Warn(message, ...)
    return emit("WARN", message, ...)
end

function Log.Error(message, ...)
    local line = emit("ERROR", message, ...)
    if SERVER then
        ErrorNoHalt(line .. "\n")
    end
    return line
end

function Log.Data(message, ...)
    return emit("DATA", message, ...)
end

function Log.Debug(message, ...)
    if CybeRp.Config and CybeRp.Config.Debug then
        return emit("DEBUG", message, ...)
    end
end

function Log.DebugDelay(delay, message, ...)
    if not (CybeRp.Config and CybeRp.Config.Debug) then return end
    local seconds = tonumber(delay) or 0
    timer.Simple(seconds, function()
        emit("DEBUG", message, ...)
    end)
end

function Log.PlayerLabel(ply)
    if not IsValid(ply) then
        return "unknown player"
    end
    return ("%s (%s)"):format(ply:Nick(), ply:SteamID64() or "noid")
end

return Log


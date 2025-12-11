if not CLIENT then return end

-- CybeRp_HooksGuardian (Client Hooks)
CybeRp = CybeRp or {}
CybeRp.HooksGuardian = CybeRp.HooksGuardian or {}

local Guardian = CybeRp.HooksGuardian
local registry = Guardian._registry or {}

Guardian._registry = registry
Guardian._realm = "CLIENT"

local function logWarn(fmt, ...)
    if CybeRp.Log and CybeRp.Log.Warn then
        CybeRp.Log.Warn(fmt, ...)
        return
    end

    print(("[CybeRp][Hooks][%s] " .. fmt):format(Guardian._realm, ...))
end

local function logInfo(fmt, ...)
    if CybeRp.Log and CybeRp.Log.Info then
        CybeRp.Log.Info(fmt, ...)
        return
    end

    print(("[CybeRp][Hooks][%s] " .. fmt):format(Guardian._realm, ...))
end

local function buildName(moduleName, hookName)
    if not isstring(moduleName) or not isstring(hookName) then
        return nil, "module and hook names must be strings"
    end

    if moduleName == "" or hookName == "" then
        return nil, "module and hook names cannot be empty"
    end

    local identifier = ("CybeRp_%s_%s"):format(moduleName, hookName)
    if not identifier:match("^CybeRp_%w+_%w+$") then
        return nil, "must match CybeRp_<Module>_<HookName> (alphanumeric and underscores)"
    end

    return identifier
end

local function hookExists(eventName, identifier)
    local tbl = hook.GetTable()
    return tbl and tbl[eventName] and tbl[eventName][identifier] ~= nil
end

function Guardian.Add(eventName, moduleName, hookName, fn)
    if not isstring(eventName) or eventName == "" then
        logWarn("Blocked hook with invalid event name")
        return false
    end

    if not isfunction(fn) then
        logWarn("Blocked hook %s/%s: callback missing", tostring(moduleName), tostring(hookName))
        return false
    end

    local identifier, err = buildName(moduleName, hookName)
    if not identifier then
        logWarn("Blocked hook for %s/%s: %s", tostring(moduleName), tostring(hookName), err or "invalid name")
        return false
    end

    if hookExists(eventName, identifier) then
        logWarn("Duplicate hook prevented: %s -> %s", eventName, identifier)
        return false
    end

    hook.Add(eventName, identifier, fn)

    registry[eventName] = registry[eventName] or {}
    registry[eventName][identifier] = true

    logInfo("Registered %s on %s", identifier, eventName)
    return identifier
end

function Guardian.Replace(eventName, moduleName, hookName, fn)
    local identifier, err = buildName(moduleName, hookName)
    if not identifier then
        logWarn("Replace failed for %s/%s: %s", tostring(moduleName), tostring(hookName), err or "invalid name")
        return false
    end

    Guardian.Remove(eventName, moduleName, hookName)
    return Guardian.Add(eventName, moduleName, hookName, fn)
end

function Guardian.Remove(eventName, moduleName, hookName)
    local identifier, err = buildName(moduleName, hookName)
    if not identifier then
        logWarn("Remove failed for %s/%s: %s", tostring(moduleName), tostring(hookName), err or "invalid name")
        return false
    end

    hook.Remove(eventName, identifier)

    if registry[eventName] then
        registry[eventName][identifier] = nil
        if next(registry[eventName]) == nil then
            registry[eventName] = nil
        end
    end

    return true
end

function Guardian.Exists(eventName, moduleName, hookName)
    local identifier, err = buildName(moduleName, hookName)
    if not identifier then
        logWarn("Exists check failed for %s/%s: %s", tostring(moduleName), tostring(hookName), err or "invalid name")
        return false
    end

    return hookExists(eventName, identifier)
end

function Guardian.List(eventName)
    if eventName then
        local set = registry[eventName]
        if not set then return {} end

        local out = {}
        for name in pairs(set) do
            out[#out + 1] = name
        end
        table.sort(out)
        return out
    end

    local snapshot = {}
    for event, set in pairs(registry) do
        snapshot[event] = {}
        for name in pairs(set) do
            snapshot[event][#snapshot[event] + 1] = name
        end
        table.sort(snapshot[event])
    end
    return snapshot
end

Guardian.BuildName = buildName


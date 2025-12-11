if not SERVER then return end

CybeRp = CybeRp or {}
CybeRp.Log = CybeRp.Log or {}
CybeRp.LoggingGuardian = CybeRp.LoggingGuardian or {}

local Log = CybeRp.Log
local Guardian = CybeRp.LoggingGuardian
local unpackFn = unpack or table.unpack

local netStats = {}
local netWrapped = {}

local function safeLog(level, message, ...)
    if Log and Log[level] then
        return Log[level](message, ...)
    end
end

local function playerLabel(ply)
    if Log and Log.PlayerLabel then
        return Log.PlayerLabel(ply)
    end
    if not IsValid(ply) then return "unknown player" end
    return ("%s (%s)"):format(ply:Nick(), ply:SteamID64() or "noid")
end

local function measurePayload(payload, codec)
    if not (CybeRp.Networking and CybeRp.Networking.EncodeTable) then
        return 0, codec or "unknown"
    end

    local encoded, len, usedCodec = CybeRp.Networking.EncodeTable(payload, codec)
    if encoded == false then
        return 0, codec or usedCodec or "unknown"
    end
    return len or 0, usedCodec or codec or "unknown"
end

local function recordNet(name, bytes)
    local bucket = netStats[name] or {count = 0, bytes = 0}
    bucket.count = bucket.count + 1
    bucket.bytes = bucket.bytes + (bytes or 0)
    bucket.last = CurTime()
    netStats[name] = bucket
end

local function targetLabel(target)
    if istable(target) then
        return ("table[%d]"):format(#target)
    end
    if IsValid(target) then
        return playerLabel(target)
    end
    return "broadcast"
end

local function wrapCyberwareInstall()
    if Guardian._cyberInstall then return end
    if not (CybeRp.Cyberware and isfunction(CybeRp.Cyberware.Install)) then return end

    local original = CybeRp.Cyberware.Install
    CybeRp.Cyberware.Install = function(ply, id)
        local result = {original(ply, id)}
        local ok, reason = result[1], result[2]

        if ok then
            safeLog("Info", "Cyberware install: %s -> %s", playerLabel(ply), tostring(id))
        else
            safeLog("Warn", "Cyberware install failed for %s (%s): %s", playerLabel(ply), tostring(id), tostring(reason or "unknown"))
        end

        return unpackFn(result)
    end

    Guardian._cyberInstall = true
end

local function wrapCyberwareRemove()
    if Guardian._cyberRemove then return end
    if not (CybeRp.Cyberware and isfunction(CybeRp.Cyberware.Remove)) then return end

    local original = CybeRp.Cyberware.Remove
    CybeRp.Cyberware.Remove = function(ply, id)
        local result = {original(ply, id)}
        local ok, reason = result[1], result[2]

        if ok then
            safeLog("Info", "Cyberware removal: %s -> %s", playerLabel(ply), tostring(id))
        else
            safeLog("Warn", "Cyberware removal failed for %s (%s): %s", playerLabel(ply), tostring(id), tostring(reason or "unknown"))
        end

        return unpackFn(result)
    end

    Guardian._cyberRemove = true
end

local function wrapInventoryAdd()
    if Guardian._invAdd then return end
    if not (CybeRp.Inventory and isfunction(CybeRp.Inventory.AddItem)) then return end

    local original = CybeRp.Inventory.AddItem
    CybeRp.Inventory.AddItem = function(ply, item, amount)
        local result = {original(ply, item, amount)}
        local ok = result[1]
        local newCount = CybeRp.Inventory.Count and CybeRp.Inventory.Count(ply, item) or 0
        local delta = tonumber(amount) or 1

        if ok then
            safeLog("Info", "Inventory add: %s +%s (%d) -> %d", playerLabel(ply), tostring(item), delta, newCount)
        else
            safeLog("Warn", "Inventory add failed: %s item=%s amount=%s", playerLabel(ply), tostring(item), tostring(delta))
        end

        return unpackFn(result)
    end

    Guardian._invAdd = true
end

local function wrapInventoryRemove()
    if Guardian._invRemove then return end
    if not (CybeRp.Inventory and isfunction(CybeRp.Inventory.RemoveItem)) then return end

    local original = CybeRp.Inventory.RemoveItem
    CybeRp.Inventory.RemoveItem = function(ply, item, amount)
        local before = CybeRp.Inventory.Count and CybeRp.Inventory.Count(ply, item) or 0
        local result = {original(ply, item, amount)}
        local ok = result[1]
        local newCount = CybeRp.Inventory.Count and CybeRp.Inventory.Count(ply, item) or 0
        local delta = tonumber(amount) or 1

        if ok then
            safeLog("Info", "Inventory remove: %s -%s (%d) -> %d (was %d)", playerLabel(ply), tostring(item), delta, newCount, before)
        else
            safeLog("Warn", "Inventory remove failed: %s item=%s amount=%s", playerLabel(ply), tostring(item), tostring(delta))
        end

        return unpackFn(result)
    end

    Guardian._invRemove = true
end

local function wrapInventoryClear()
    if Guardian._invClear then return end
    if not (CybeRp.Inventory and isfunction(CybeRp.Inventory.Clear)) then return end

    local original = CybeRp.Inventory.Clear
    CybeRp.Inventory.Clear = function(ply)
        local before = CybeRp.Inventory.Get and CybeRp.Inventory.Get(ply) or {}
        local removed = table.Count(before)
        local result = {original(ply)}

        safeLog("Info", "Inventory cleared: %s removed %d entries", playerLabel(ply), removed)
        return unpackFn(result)
    end

    Guardian._invClear = true
end

local function wrapJobAssign()
    if Guardian._jobAssign then return end
    if not (CybeRp.Jobs and isfunction(CybeRp.Jobs.Assign)) then return end

    local original = CybeRp.Jobs.Assign
    CybeRp.Jobs.Assign = function(ply, jobId)
        local prev = ply.GetJob and ply:GetJob() or "unknown"
        local result = {original(ply, jobId)}
        local ok = result[1]
        local newJob = ply.GetJob and ply:GetJob() or prev

        if ok then
            safeLog("Info", "Job change: %s %s -> %s", playerLabel(ply), tostring(prev), tostring(newJob))
        else
            safeLog("Warn", "Job change failed: %s -> %s", playerLabel(ply), tostring(jobId))
        end

        return unpackFn(result)
    end

    Guardian._jobAssign = true
end

local function wrapFactionSet()
    if Guardian._factionSet then return end
    if not (CybeRp.Factions and isfunction(CybeRp.Factions.SetFaction)) then return end

    local original = CybeRp.Factions.SetFaction
    CybeRp.Factions.SetFaction = function(ply, factionId)
        local prev = ply.GetFaction and ply:GetFaction() or "unknown"
        local result = {original(ply, factionId)}
        local ok = result[1]
        local newFaction = ply.GetFaction and ply:GetFaction() or prev

        if ok then
            safeLog("Info", "Faction change: %s %s -> %s", playerLabel(ply), tostring(prev), tostring(newFaction))
        else
            safeLog("Warn", "Faction change failed: %s -> %s", playerLabel(ply), tostring(factionId))
        end

        return unpackFn(result)
    end

    Guardian._factionSet = true
end

local function wrapPlayerSave()
    if Guardian._playerSave then return end
    if not (CybeRp.Player and isfunction(CybeRp.Player.Save)) then return end

    local original = CybeRp.Player.Save
    CybeRp.Player.Save = function(ply, silent)
        local invCount = 0
        if CybeRp.Inventory and CybeRp.Inventory.Get then
            invCount = table.Count(CybeRp.Inventory.Get(ply))
        end

        local credits = ply.GetCredits and ply:GetCredits() or 0
        local result = {original(ply, silent)}

        if IsValid(ply) then
            safeLog("Data", "Saved player %s (credits=%d, inventory entries=%d%s)", playerLabel(ply), credits, invCount, silent and ", silent" or "")
        else
            safeLog("Warn", "Attempted to save invalid player (silent=%s)", tostring(silent))
        end

        return unpackFn(result)
    end

    Guardian._playerSave = true
end

local function wrapNetSend(fnName, msgName, codec)
    if netWrapped[fnName] then return end
    if not (CybeRp.Networking and isfunction(CybeRp.Networking[fnName])) then return end

    local original = CybeRp.Networking[fnName]
    CybeRp.Networking[fnName] = function(target, payload, ...)
        local bytes, usedCodec = measurePayload(payload, codec)
        recordNet(msgName, bytes)

        if CybeRp.Config and CybeRp.Config.Debug then
            safeLog("Debug", "NET %s -> %s | %d bytes via %s", msgName, targetLabel(target), bytes, usedCodec)
        end

        return original(target, payload, ...)
    end

    netWrapped[fnName] = true
end

local function wrapNetMessages()
    if not (CybeRp.NET and CybeRp.Networking) then return end

    wrapNetSend("PushPlayerData", CybeRp.NET.PLAYER_DATA, "pon")
    wrapNetSend("PushInventory", CybeRp.NET.INVENTORY_UPDATE, "pon")
    wrapNetSend("PushCyberware", CybeRp.NET.CYBERWARE_UPDATE, "pon")
    wrapNetSend("PushJobUpdate", CybeRp.NET.JOB_UPDATE, "json")
    wrapNetSend("BroadcastWorldEvent", CybeRp.NET.WORLD_EVENT, "json")
    wrapNetSend("SendAlert", CybeRp.NET.WORLD_EVENT, "json")
    wrapNetSend("SendRPC", CybeRp.NET.RPC, "pon")
end

local function bootstrap()
    wrapCyberwareInstall()
    wrapCyberwareRemove()
    wrapInventoryAdd()
    wrapInventoryRemove()
    wrapInventoryClear()
    wrapJobAssign()
    wrapFactionSet()
    wrapPlayerSave()
    wrapNetMessages()
end

hook.Add("Initialize", "CybeRp_LoggingGuardian_Bootstrap", bootstrap)
timer.Create("CybeRp_LoggingGuardian_Retry", 1, 5, bootstrap)

timer.Create("CybeRp_LoggingGuardian_NetSummary", 60, 0, function()
    if not (CybeRp.Config and CybeRp.Config.Debug) then return end

    for name, data in pairs(netStats) do
        local avg = data.count > 0 and (data.bytes / data.count) or 0
        safeLog("Debug", "NET DIGEST %s | count=%d bytes=%d avg=%.1f", name, data.count, data.bytes, avg)
    end

    netStats = {}
end)


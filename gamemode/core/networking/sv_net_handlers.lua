-- CybeRp Networking - server handlers
-- Responsible for all net.Start/net.Send usage.

if not SERVER then return end

CybeRp = CybeRp or {}
CybeRp.Networking = CybeRp.Networking or {}
CybeRp.Net = CybeRp.Net or {}

local NET = CybeRp.NET
local Net = CybeRp.Networking
local Api = CybeRp.Net

local function playerSnapshot(ply)
    if not IsValid(ply) then return {} end
    local data = ply:GetCybeData and ply:GetCybeData() or {}
    return {
        id = ply:SteamID64(),
        credits = ply.GetCredits and ply:GetCredits() or data.credits,
        job = data.job,
        faction = data.faction,
        health = data.health or ply:Health(),
        armor = data.armor or ply:Armor(),
    }
end

local function inventorySnapshot(ply)
    if CybeRp.Inventory and CybeRp.Inventory.Get then
        return CybeRp.Inventory.Get(ply) or {}
    end
    return ply.CybeInventory or {}
end

local function cyberwareSnapshot(ply)
    local data = ply:GetCybeData and ply:GetCybeData() or {}
    return data.cyberware or {}
end

local function sendMessage(msgName, target, payload, codec)
    if not msgName then return false end

    net.Start(msgName)
    local ok = Net.WritePayload(payload, codec)
    if not ok then
        ErrorNoHalt(string.format("[CybeRp][Net] Failed to encode payload for %s\n", msgName))
        return false
    end

    if istable(target) then
        net.Send(target)
    elseif IsValid(target) then
        net.Send(target)
    else
        net.Broadcast()
    end

    return true
end

-- Push a player stat snapshot (full or partial).
function Net.PushPlayerData(target, payload)
    return sendMessage(NET.PLAYER_DATA, target, payload, "pon")
end

-- Sync inventory snapshot or delta to a single player.
function Net.PushInventory(target, payload)
    return sendMessage(NET.INVENTORY_UPDATE, target, payload, "pon")
end

-- Sync cyberware snapshot or delta.
function Net.PushCyberware(target, payload)
    return sendMessage(NET.CYBERWARE_UPDATE, target, payload, "pon")
end

-- Notify job/faction/role changes.
function Net.PushJobUpdate(target, payload)
    return sendMessage(NET.JOB_UPDATE, target, payload, "json")
end

-- Broadcast world events (alarms, wars, police alerts).
function Net.BroadcastWorldEvent(eventName, payload)
    payload = payload or {}
    payload.event = payload.event or eventName
    payload.when = payload.when or CurTime()

    return sendMessage(NET.WORLD_EVENT, nil, payload, "json")
end

-- Convenience for directed alerts (still uses WORLD_EVENT pipe).
function Net.SendAlert(target, kind, payload)
    payload = payload or {}
    payload.event = payload.event or kind or "alert"
    payload.scope = payload.scope or (IsValid(target) and "direct" or "broadcast")
    payload.when = payload.when or CurTime()

    return sendMessage(NET.WORLD_EVENT, target, payload, "json")
end

-- Server -> client RPC helper. Clients dispatch via hook: CybeRp_RPC_<method>.
function Net.SendRPC(target, method, args)
    if not isstring(method) or method == "" then
        return false
    end

    local payload = {
        method = method,
        args = args or {},
        ts = CurTime()
    }

    return sendMessage(NET.RPC, target, payload, "pon")
end

-- Compatibility wrappers per roadmap tasks (Phase 2.1.2)
function Api.SendPlayerFullState(ply)
    if not IsValid(ply) then return end
    return Net.PushPlayerData(ply, playerSnapshot(ply))
end

function Api.BroadcastInventory(ply)
    if not IsValid(ply) then return end
    return Net.PushInventory(ply, inventorySnapshot(ply))
end

function Api.BroadcastCyberware(ply)
    if not IsValid(ply) then return end
    return Net.PushCyberware(ply, cyberwareSnapshot(ply))
end



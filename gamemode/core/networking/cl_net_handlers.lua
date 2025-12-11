-- CybeRp Networking - client receivers
-- Decodes payloads and dispatches to subsystems/hooks.

if SERVER then return end

CybeRp = CybeRp or {}
CybeRp.Networking = CybeRp.Networking or {}
CybeRp.ClientState = CybeRp.ClientState or {}

local NET = CybeRp.NET
local Net = CybeRp.Networking
local CS = CybeRp.ClientState

-- Client → Server helpers
function CybeRp.NetUseItem(itemId)
    if not isstring(itemId) or itemId == "" then return end
    net.Start(NET.USE_ITEM)
        net.WriteString(itemId)
    net.SendToServer()
end

function CybeRp.NetDropItem(itemId)
    if not isstring(itemId) or itemId == "" then return end
    net.Start(NET.DROP_ITEM)
        net.WriteString(itemId)
    net.SendToServer()
end

function CybeRp.NetActivateCyberware(cyberId)
    if not isstring(cyberId) or cyberId == "" then return end
    net.Start(NET.ACTIVATE_CYBERWARE)
        net.WriteString(cyberId)
    net.SendToServer()
end

function CybeRp.NetHackRequest(ent, targetId)
    if not IsValid(ent) then return end
    net.Start(NET.HACK_REQUEST)
        net.WriteEntity(ent)
        net.WriteString(targetId or "")
    net.SendToServer()
end

local function safeCall(handler, payload)
    if not handler then return end
    local ok, err = pcall(handler, payload or {})
    if not ok then
        ErrorNoHalt(string.format("[CybeRp][Net] Handler error: %s\n", err or "unknown"))
    end
end

local function dispatchHook(suffix, payload)
    hook.Run("CybeRp_Net_" .. suffix, payload)
end

local function handlePlayerData(payload)
    dispatchHook("PlayerData", payload)

    if istable(payload) then
        CS.credits = payload.credits or CS.credits
        CS.job = payload.job or CS.job
        CS.faction = payload.faction or CS.faction
        CS.health = payload.health or CS.health
        CS.armor = payload.armor or CS.armor
    end

    if CybeRp.UI and CybeRp.UI.State and CybeRp.UI.State.ApplyPlayerSnapshot then
        CybeRp.UI.State:ApplyPlayerSnapshot(payload or {})
    end
end

local function handleInventory(payload)
    dispatchHook("Inventory", payload)

    if istable(payload) then
        CS.inventory = payload
    end

    if CybeRp.UI and CybeRp.UI.State and CybeRp.UI.State.ApplyInventorySnapshot then
        CybeRp.UI.State:ApplyInventorySnapshot(payload or {})
    end

    hook.Run("CybeRp_UI_InventoryUpdated", payload or {})
end

local function handleCyberware(payload)
    dispatchHook("Cyberware", payload)

    if istable(payload) then
        CS.cyberware = payload
    end

    if CybeRp.UI and CybeRp.UI.State and CybeRp.UI.State.ApplyCyberwareSnapshot then
        CybeRp.UI.State:ApplyCyberwareSnapshot(payload or {})
    end
end

local function handleJob(payload)
    dispatchHook("Job", payload)
end

local function handleWorldEvent(payload)
    dispatchHook("WorldEvent", payload)
end

local function handleRPC(payload)
    if not istable(payload) then return end
    local method = payload.method
    if not isstring(method) or method == "" then return end

    dispatchHook("RPC", payload)
    hook.Run("CybeRp_RPC_" .. method, payload.args or {}, payload)
end

local HANDLERS = {
    [NET.PLAYER_DATA] = handlePlayerData,
    [NET.INVENTORY_UPDATE] = handleInventory,
    [NET.CYBERWARE_UPDATE] = handleCyberware,
    [NET.JOB_UPDATE] = handleJob,
    [NET.WORLD_EVENT] = handleWorldEvent,
    [NET.WORLD_ALERT] = function(payload)
        dispatchHook("WorldAlert", payload)
    end,
    [NET.HACK_RESULT] = function(payload)
        dispatchHook("HackResult", payload)
    end,
    [NET.VENDOR_STOCK] = function(payload)
        dispatchHook("VendorStock", payload)
    end,
    [NET.HEAT_SYNC] = function(payload)
        CS.heat = payload and payload.heat or CS.heat
        CS.wanted = payload and payload.wanted or false
        dispatchHook("Heat", payload)
    end,
    [NET.RPC] = handleRPC
}

local function bindAll()
    for name, handler in pairs(HANDLERS) do
        net.Receive(name, function()
            local payload = Net.ReadPayload()
            safeCall(handler, payload)
        end)
    end
end

-- Bind now and once more on the next tick to override any ad-hoc receivers.
bindAll()
timer.Simple(0, bindAll)




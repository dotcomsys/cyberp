CybeRp = CybeRp or {}
CybeRp.World = CybeRp.World or {}

local World = CybeRp.World
World.Events = World.Events or {}

local function debugLog(msg, ...)
    if CybeRp.Config and CybeRp.Config.Debug then
        print(("[CybeRp][Events] " .. msg):format(...))
    end
end

-- Register a simple event template
function World.RegisterEvent(id, handler)
    if not isstring(id) or id == "" then return end
    World.Events[id] = handler
    debugLog("Registered world event %s", id)
end

-- Trigger an event by id
function World.TriggerEvent(id, context)
    local fn = World.Events[id]
    if not fn then return end
    local payload = fn(context or {}) or context or {}
    if CybeRp.Net and CybeRp.Net.PushWorldAlert then
        CybeRp.Net.PushWorldAlert(nil, payload)
    end
    hook.Run("CybeRp_World_Event", id, payload)
    debugLog("Event %s fired", id)
end

-- Scheduler stub: rotate placeholder events
local EVENT_ROTATION = {"city_alert", "sector_patrol", "raid_warning"}
local idx = 1

timer.Create("CybeRp_World_EventScheduler", 240, 0, function()
    local id = EVENT_ROTATION[idx]
    idx = idx % #EVENT_ROTATION + 1
    World.TriggerEvent(id, { ts = CurTime() })
end)

-- Default handlers
World.RegisterEvent("city_alert", function(ctx)
    return { level = "info", message = "Heightened surveillance in progress", when = ctx.ts or CurTime() }
end)

World.RegisterEvent("sector_patrol", function(ctx)
    return { level = "warning", message = "Patrol redeployed to central sector", when = ctx.ts or CurTime() }
end)

World.RegisterEvent("raid_warning", function(ctx)
    return { level = "critical", message = "CitySec raid mobilizing", when = ctx.ts or CurTime() }
end)



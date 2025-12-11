CybeRp = CybeRp or {}
CybeRp.World = CybeRp.World or {}

local World = CybeRp.World

World.HackableDoors = World.HackableDoors or {}

local function debugLog(msg, ...)
    if CybeRp.Config and CybeRp.Config.Debug then
        print(("[CybeRp][Doors] " .. msg):format(...))
    end
end

local function inArea(pos, data)
    if not data then return false end
    if data.bounds and data.bounds.min and data.bounds.max then
        return pos:WithinAABox(data.bounds.min, data.bounds.max)
    end
    if data.center and data.radius then
        local r = data.radius
        return pos:DistToSqr(data.center) <= (r * r)
    end
    return false
end

function World:RegisterHackableDoor(ent, data)
    if not IsValid(ent) then return end

    World.HackableDoors[ent] = {
        difficulty = data.difficulty or 0.5,
        cooldown = data.cooldown or 45,
        lastHack = 0,
        district = data.district,
        triggerAlert = data.triggerAlert ~= false,
    }

    ent:SetNWBool("CybeRpHackableDoor", true)
    ent:CallOnRemove("CybeRpWorld_DoorCleanup", function()
        World.HackableDoors[ent] = nil
    end)

    debugLog("Door marked hackable (%s)", tostring(ent))
end

local function handleHack(ply, ent, meta)
    local now = CurTime()
    if meta.lastHack and meta.lastHack > now then
        ply:ChatPrint(("[Door] Cooling down. %ss left."):format(math.ceil(meta.lastHack - now)))
        return false
    end

    meta.lastHack = now + meta.cooldown
    local duration = meta.time or 4
    ply:ChatPrint("[Door] Bypassing lock...")
    ent:EmitSound("buttons/combine_button5.wav", 70)

    timer.Simple(duration, function()
        if not IsValid(ply) or not IsValid(ent) then return end
        local successChance = math.Clamp(1 - (meta.difficulty or 0.5), 0.05, 0.95)
        local success = math.Rand(0, 1) <= successChance

        if success then
            ent:Fire("Unlock")
            ent:Fire("Open")
            ent:EmitSound("doors/door_latch3.wav", 75)
            ply:ChatPrint("[Door] Access granted.")
            debugLog("Door hack success by %s", ply:Nick())
        else
            ent:EmitSound("buttons/combine_button_locked.wav", 80)
            ply:ChatPrint("[Door] Lockdown triggered.")
            if meta.triggerAlert then
                CybeRp.World:BroadcastAlert("Unauthorized door breach attempt detected.", "warning")
            end
            if CybeRp.World.AI and CybeRp.World.AI.DispatchQuickResponse then
                CybeRp.World.AI:DispatchQuickResponse(ent:GetPos(), 1.2 + (meta.difficulty or 0.5))
            end
            debugLog("Door hack failed by %s", ply:Nick())
        end
    end)

    return false
end

hook.Add("PlayerUse", "CybeRpWorld_DoorHackUse", function(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    local meta = World.HackableDoors[ent]
    if not meta then return end

    return handleHack(ply, ent, meta)
end)

local function autoMarkDoors()
    if not CybeRp.Config or not CybeRp.Config.Debug then return end
    for _, ent in ipairs(ents.FindByClass("prop_door_rotating")) do
        for _, zone in pairs(World.HackingZones or {}) do
            if inArea(ent:GetPos(), zone) then
                World:RegisterHackableDoor(ent, { difficulty = zone.difficulty or 0.5, cooldown = 60, district = zone.id })
                break
            end
        end
    end
end

hook.Add("InitPostEntity", "CybeRpWorld_DoorBootstrap", function()
    autoMarkDoors()
end)



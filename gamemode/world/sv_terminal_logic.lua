CybeRp = CybeRp or {}
CybeRp.World = CybeRp.World or {}

local World = CybeRp.World

World.Terminals = World.Terminals or { cooldowns = {}, active = {} }

local function debugLog(msg, ...)
    if CybeRp.Config and CybeRp.Config.Debug then
        print(("[CybeRp][Terminal] " .. msg):format(...))
    end
end

local function clearActive(ply)
    if not ply then return end
    World.Terminals.active[ply] = nil
end

function World:GetTerminalCooldown(id)
    local untilTime = World.Terminals.cooldowns[id]
    if not untilTime then return 0 end
    return math.max(0, untilTime - CurTime())
end

function World:BroadcastAlert(message, level)
    if CybeRp.Net and CybeRp.Net.PushWorldAlert then
        CybeRp.Net.PushWorldAlert(nil, {
            message = message,
            level = level or "info",
            when = CurTime()
        })
    end
end

function World:BeginTerminalHack(ply, ent, meta, startMinigame)
    if not IsValid(ply) or not IsValid(ent) or not meta then return end

    local cd = World:GetTerminalCooldown(meta.id)
    if cd > 0 then
        ply:ChatPrint(("[Terminal] Cooling down, %ss remaining."):format(math.ceil(cd)))
        return false
    end

    local duration = meta.hackTime or 6
    local maxDist = meta.maxDistance or 160
    local timerId = "CybeRpWorld_TerminalHack_" .. ply:UserID()

    World.Terminals.active[ply] = { ent = ent, meta = meta, endsAt = CurTime() + duration }
    ent:EmitSound("buttons/combine_button7.wav", 70)
    ply:ChatPrint("[Terminal] Breach attempt started...")

    if startMinigame then
        net.Start("cyberp_hack_minigame")
            net.WriteFloat(duration)
            net.WriteUInt(4, 5)
            net.WriteString("W")
            net.WriteString("A")
            net.WriteString("S")
            net.WriteString("D")
        net.Send(ply)
    end

    timer.Create(timerId .. "_check", 0.5, math.max(1, math.ceil(duration / 0.5)), function()
        if not IsValid(ply) or not IsValid(ent) then
            clearActive(ply)
            return
        end

        if ply:GetPos():DistToSqr(ent:GetPos()) > (maxDist * maxDist) then
            ply:ChatPrint("[Terminal] Link lost.")
            ent:EmitSound("buttons/combine_button_locked.wav", 70)
            clearActive(ply)
            timer.Remove(timerId .. "_check")
        end
    end)

    timer.Create(timerId .. "_finish", duration, 1, function()
        if not IsValid(ply) or not IsValid(ent) then
            clearActive(ply)
            return
        end

        local active = World.Terminals.active[ply]
        if not active or active.ent ~= ent then return end

        World:FinishTerminalHack(ply, ent, meta)
        clearActive(ply)
    end)

    return false
end

function World:FinishTerminalHack(ply, ent, meta)
    local successChance = math.Clamp(1 - (meta.difficulty or 0.5), 0.05, 0.95)
    local success = math.Rand(0, 1) <= successChance
    World.Terminals.cooldowns[meta.id] = CurTime() + (meta.cooldown or 75)

    if success then
        World:OnTerminalSuccess(ply, ent, meta)
    else
        World:OnTerminalBreach(ply, ent, meta)
    end
end

function World:OnTerminalSuccess(ply, ent, meta)
    ply:SetNWInt("CybeRp_DataFragments", ply:GetNWInt("CybeRp_DataFragments") + 2)
    ply:ChatPrint("[Terminal] Access granted. Data siphoned.")
    ent:EmitSound("buttons/button9.wav", 70)
    hook.Run("CybeRpTerminalHacked", ply, meta.id, true)
    debugLog("Terminal %s hacked successfully by %s", tostring(meta.id), ply:Nick())
end

function World:OnTerminalBreach(ply, ent, meta)
    ply:ChatPrint("[Terminal] ICE triggered! Security en route.")
    ent:EmitSound("buttons/combine_button_locked.wav", 75)
    World:BroadcastAlert(("Unauthorized terminal breach near %s."):format(meta.district or "unknown sector"), "warning")

    if CybeRp.World.AI and CybeRp.World.AI.DispatchQuickResponse then
        CybeRp.World.AI:DispatchQuickResponse(ent:GetPos(), 1 + (meta.difficulty or 0.5))
    end

    hook.Run("CybeRpTerminalHacked", ply, meta.id, false)
    debugLog("Terminal %s breach by %s failed, alert dispatched", tostring(meta.id), ply:Nick())
end



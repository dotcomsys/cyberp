CybeRp = CybeRp or {}
CybeRp.Arrest = CybeRp.Arrest or {}

local Arrest = CybeRp.Arrest

local function ensure(ply)
    ply.CybeArrest = ply.CybeArrest or { jailed = false, releaseAt = 0 }
    return ply.CybeArrest
end

function Arrest.Jail(ply, duration)
    local st = ensure(ply)
    st.jailed = true
    st.releaseAt = CurTime() + (duration or 60)
    ply:StripWeapons()
    if CybeRp.Net and CybeRp.Net.PushArrest then
        CybeRp.Net.PushArrest(ply, { jailed = true, releaseAt = st.releaseAt })
    end
end

function Arrest.Release(ply)
    local st = ensure(ply)
    st.jailed = false
    st.releaseAt = 0
    if CybeRp.Net and CybeRp.Net.PushArrest then
        CybeRp.Net.PushArrest(ply, { jailed = false, releaseAt = 0 })
    end
end

function Arrest.Tick()
    for _, ply in ipairs(player.GetHumans()) do
        local st = ensure(ply)
        if st.jailed and st.releaseAt > 0 and CurTime() >= st.releaseAt then
            Arrest.Release(ply)
        end
    end
end

timer.Create("CybeRp_ArrestTick", 1, 0, Arrest.Tick)



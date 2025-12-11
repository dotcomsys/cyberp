CybeRp = CybeRp or {}
CybeRp.Heat = CybeRp.Heat or {}

local Heat = CybeRp.Heat

local function ensure(ply)
    ply.CybeHeat = ply.CybeHeat or { value = 0, wanted = false }
    return ply.CybeHeat
end

function Heat.Get(ply)
    local h = ensure(ply)
    return h.value or 0, h.wanted or false
end

function Heat.Add(ply, amount)
    local h = ensure(ply)
    h.value = math.max(0, (h.value or 0) + (amount or 0))
    h.wanted = h.wanted or h.value >= (CybeRp.Config and CybeRp.Config.HeatWantedThreshold or 50)
end

function Heat.Decay(ply, rate)
    local h = ensure(ply)
    h.value = math.max(0, h.value - (rate or 1))
    if h.value < (CybeRp.Config and CybeRp.Config.HeatWantedThreshold or 50) then
        h.wanted = false
    end
end

function Heat.SetWanted(ply, state)
    local h = ensure(ply)
    h.wanted = state == true
end



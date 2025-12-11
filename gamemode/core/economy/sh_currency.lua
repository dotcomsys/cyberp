CybeRp.Currency = CybeRp.Currency or {}

function CybeRp.Currency.Clamp(amount)
    return math.max(0, math.floor(tonumber(amount) or 0))
end

function CybeRp.Currency.Format(amount)
    amount = CybeRp.Currency.Clamp(amount)
    return string.Comma(amount) .. "₡"
end


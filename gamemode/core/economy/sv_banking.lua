CybeRp.Banking = CybeRp.Banking or {}
include("cyberp/gamemode/core/economy/sh_currency.lua")

local function adjust(ply, cashDelta, bankDelta)
    if cashDelta ~= 0 then
        ply:AddCredits(cashDelta)
    end
    if bankDelta ~= 0 then
        ply:AddBank(bankDelta)
    end
end

function CybeRp.Banking.Deposit(ply, amount)
    if not IsValid(ply) then return false end
    amount = CybeRp.Currency.Clamp(amount)
    if amount <= 0 then return false end

    amount = math.min(amount, ply:GetCredits())
    adjust(ply, -amount, amount)
    CybeRp.Player.MarkDirty(ply, "bank")
    return true
end

function CybeRp.Banking.Withdraw(ply, amount)
    if not IsValid(ply) then return false end
    amount = CybeRp.Currency.Clamp(amount)
    if amount <= 0 then return false end

    amount = math.min(amount, ply:GetBank())
    adjust(ply, amount, -amount)
    CybeRp.Player.MarkDirty(ply, "bank")
    return true
end

function CybeRp.Banking.Transfer(fromPly, toPly, amount)
    if not (IsValid(fromPly) and IsValid(toPly)) then return false end
    amount = CybeRp.Currency.Clamp(amount)
    if amount <= 0 then return false end

    amount = math.min(amount, fromPly:GetBank())
    if amount <= 0 then return false end

    fromPly:AddBank(-amount)
    toPly:AddBank(amount)

    CybeRp.Player.MarkDirty(fromPly, "bank")
    CybeRp.Player.MarkDirty(toPly, "bank")
    return true
end


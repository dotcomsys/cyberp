local PLAYER = FindMetaTable("Player")

function PLAYER:GetCybeID()
    return self.CybeID
end

function PLAYER:SetCybeID(id)
    self.CybeID = id
end

function PLAYER:AddCredits(amount)
    self.Credits = (self.Credits or 0) + amount
end

function PLAYER:GetCredits()
    return self.Credits or 0
end

function PLAYER:HasCyberware(id)
    return self.Cyberware and self.Cyberware[id] == true
end


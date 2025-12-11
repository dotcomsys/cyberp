SWEP.PrintName = "Cyber Hacktool"
SWEP.Author = "Unsound Studios"
SWEP.Spawnable = true

SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = ""

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local ply = self:GetOwner()
    ply:ChatPrint("Hacking...")
end


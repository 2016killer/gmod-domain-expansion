if SERVER then
	AddCSLuaFile()
end

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.PrintName = 'Fukuma Mizushi'
SWEP.Category = 'Domain'
SWEP.Author = 'Zack'

// SWEP.ViewModel = 'models/weapons/c_goldenkatana.mdl'
// SWEP.WorldModel = 'models/weapons/w_goldenkatana.mdl'
SWEP.Spawnable = true
SWEP.HoldType = 'melee2'

function SWEP:PrimaryAttack()
	if CLIENT then
		self:SetNextPrimaryFire(CurTime() + 0.5)
	end
end


function SWEP:SecondaryAttack()
	if CLIENT then

	end
end
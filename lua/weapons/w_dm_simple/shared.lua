if SERVER then
	AddCSLuaFile()
end

SWEP.Slot = 4
SWEP.SlotPos = 99
SWEP.DrawAmmo = false
SWEP.PrintName = 'Simple Nucleus'
SWEP.Category = 'Domain Nucleus'
SWEP.Author = 'Zack'
SWEP.UseHands = true
SWEP.ViewModel = 'models/weapons/c_bugbait.mdl'
SWEP.WorldModel = 'models/weapons/w_bugbait.mdl'
SWEP.Spawnable = true
SWEP.HoldType = 'melee2'

if CLIENT then
	SWEP.PrintName = language.GetPhrase('dm.wp.simple.name')
	SWEP.Category = language.GetPhrase('dm.wp.category')
	SWEP.Instructions = language.GetPhrase('dm.wp.instructions')..'bind g "+dm_start dm_simple"'
end

function SWEP:PrimaryAttack() end

function SWEP:SecondaryAttack() end
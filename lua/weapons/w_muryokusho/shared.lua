if SERVER then
	AddCSLuaFile()
end

SWEP.Slot = 4
SWEP.SlotPos = 99
SWEP.DrawAmmo = false
SWEP.PrintName = 'Muryokusho Nucleus'
SWEP.Category = 'Domain Nucleus'
SWEP.Author = 'Zack'
SWEP.UseHands = true
SWEP.ViewModel = 'models/weapons/c_bugbait.mdl'
SWEP.WorldModel = 'models/weapons/w_bugbait.mdl'
SWEP.Spawnable = true
SWEP.HoldType = 'melee2'

if CLIENT then
	SWEP.PrintName = language.GetPhrase('mryks.wp.name')
	SWEP.Category = language.GetPhrase('mryks.wp.category')
	SWEP.Instructions = language.GetPhrase('mryks.wp.instructions')
end

function SWEP:PrimaryAttack() end

function SWEP:SecondaryAttack() end

if not game.SinglePlayer() then
    hook.Add('PreDomainExpand', 'mryks_condition', function(ply, dotype)
        if dotype == 'muryokusho' and not IsValid(ply:GetWeapon('w_muryokusho')) then
            if CLIENT then ply:EmitSound('Weapon_AR2.Empty') end
            return true
        end
    end)
end
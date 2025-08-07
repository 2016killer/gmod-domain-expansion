ENT.Type = 'anim'
ENT.Base = 'dm_base'

ENT.ClassName = 'dm_health'
ENT.PrintName = 'Health'
ENT.Category = 'Domain'
ENT.Spawnable = true

hook.Add('PreDomainExpand', 'dm_health_condition', function(ply, dotype)
    if dotype == 'dm_health' and not IsValid(ply:GetWeapon('w_dm_health')) then
        if CLIENT then ply:EmitSound('Weapon_AR2.Empty') end
        return true
    end
end)
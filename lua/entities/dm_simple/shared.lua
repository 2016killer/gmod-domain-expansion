ENT.Type = 'anim'
ENT.Base = 'dm_base'

ENT.ClassName = 'dm_simple'
ENT.PrintName = 'Simple'
ENT.Category = 'Domain'
ENT.Spawnable = true

hook.Add('PreDomainExpand', 'dm_simple_condition', function(ply, dotype)
    if dotype == 'dm_simple' and not IsValid(ply:GetWeapon('w_dm_simple')) then
        if CLIENT then ply:EmitSound('Weapon_AR2.Empty') end
        return true
    end
end)
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Impact(owner, entsIn, dt)
    local dmginfo = DamageInfo()
    dmginfo:SetDamage(1)
    dmginfo:SetDamageType(DMG_BULLET)
    dmginfo:SetDamageForce(VectorRand() * 500) 
    dmginfo:SetAttacker(self) 
    dmginfo:SetInflictor(self) 

    for _, ent in pairs(entsIn) do  
        if IsValid(ent) then
            ent:TakeDamageInfo(dmginfo)
            // ent:TakeDamageInfo(dmginfo)
            // ent:TakeDamageInfo(dmginfo)
            // ent:TakeDamageInfo(dmginfo)
        end
    end
end

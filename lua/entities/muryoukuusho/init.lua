AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Impact(owner, entsIn, dt)
    local dmginfo = DamageInfo()
    dmginfo:SetDamage(10)
    dmginfo:SetAttacker(self) 
    dmginfo:SetInflictor(self) 
    dmginfo:SetDamageType(DMG_BULLET)
    dmginfo:SetDamageForce(VectorRand() * 500)

    for _, ent in pairs(entsIn) do  
        if ent:IsNPC() then
            ent:NextThink(0)
        end
        // if ent:IsNPC() or ent:IsPlayer() then
        //     ent:TakeDamageInfo(dmginfo)
        // end
    end
end

function ENT:Cost()


end

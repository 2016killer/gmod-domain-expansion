AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

// function ENT:Effect(owner, entsIn, dt)
//     local dmginfo = DamageInfo()
//     dmginfo:SetDamage(10)
//     dmginfo:SetAttacker(self) 
//     dmginfo:SetInflictor(self) 
//     dmginfo:SetDamageType(DMG_BULLET)
//     dmginfo:SetDamageForce(VectorRand() * 500)

//     for _, ent in ipairs(entsIn) do  
//         ent:TakeDamageInfo(dmginfo)
//         ent:TakeDamageInfo(dmginfo)
//         ent:TakeDamageInfo(dmginfo)
//         ent:TakeDamageInfo(dmginfo)
//     end
// end

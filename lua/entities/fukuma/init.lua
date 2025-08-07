AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local VectorRand = VectorRand


local fkm_ka = CreateConVar('fkm_ka', '2.5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local fkm_kh = CreateConVar('fkm_kh', '5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

function ENT:Cost(radius, dt)
    return fkm_ka:GetFloat() * radius * 0.00390625 * dt, fkm_kh:GetFloat() * dt
end

local fkm_damage = CreateConVar('fkm_damage', '20', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local KillAnimPlayInServer = fkmd_PlayInServer

function ENT:Impact(owner, entsIn, dt)
    local owner = self:GetOwner()
    local force = VectorRand() * 500

    local dmgbullet = DamageInfo()
    dmgbullet:SetDamage(fkm_damage:GetFloat() * dt)
    dmgbullet:SetDamageType(DMG_BULLET)
    dmgbullet:SetDamageForce(force) 
    dmgbullet:SetAttacker(owner) 
    dmgbullet:SetInflictor(self) 
    dmgbullet:SetDamagePosition(self:GetPos())

    for _, ent in pairs(entsIn) do  
        if IsValid(ent) and ent ~=owner then
            ent:TakeDamageInfo(dmgbullet)
        end
        
        if not ent:IsPlayer() and not ent:IsNPC() then
            KillAnimPlayInServer(ent, 0.5)
        end
    end
end



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
    -- 至少间隔1s, 对prop造成伤害, 同时加入动画队列 (一批20个)
    local propDmg, propRemoveCollect
    self.propDmgTimer = (self.propDmgTimer or 0.5) + dt
    if self.propDmgTimer > 1 then 
        self.propDmgTimer = 0 
        propDmg = DamageInfo()
        propDmg:SetDamage(fkm_damage:GetFloat())
        propDmg:SetDamageType(DMG_BULLET)
        propDmg:SetDamageForce(force) 
        propDmg:SetAttacker(owner) 
        propDmg:SetInflictor(self) 
        propDmg:SetDamagePosition(self:GetPos())

        propRemoveCollect = {}
    end
    
    
    local dmgbullet = DamageInfo()
    dmgbullet:SetDamage(fkm_damage:GetFloat() * dt)
    dmgbullet:SetDamageType(DMG_BULLET)
    dmgbullet:SetDamageForce(force) 
    dmgbullet:SetAttacker(owner) 
    dmgbullet:SetInflictor(self) 
    dmgbullet:SetDamagePosition(self:GetPos())

    for _, ent in pairs(entsIn) do  
        if IsValid(ent) and ent ~=owner then
            if ent:IsPlayer() or ent:IsNPC() then
                ent:TakeDamageInfo(dmgbullet)
            elseif propDmg then
                ent:TakeDamageInfo(propDmg)
                if not ent.fkm_aflag and #propRemoveCollect < 20 then
                    ent.fkm_aflag = true
                    propRemoveCollect[#propRemoveCollect + 1] = ent
                end
            end
        end
    end

    if propRemoveCollect then
        KillAnimPlayInServer(propRemoveCollect, 0.5)
    end
end



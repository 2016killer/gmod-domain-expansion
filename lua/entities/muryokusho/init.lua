AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local mryks_ka = CreateConVar('mryks_ka', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local mryks_damage = CreateConVar('mryks_damage', '200', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local mryks_damage_brain = CreateConVar('mryks_damage_brain', '10', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local mryks_sleep_max = CreateConVar('mryks_sleep_max', '60', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local CurTime = CurTime
local FrameTime = FrameTime

function ENT:Cost(radius, dt)
    return mryks_ka:GetFloat() * radius * radius * 0.00390625 * 0.00390625 * dt, 0
end

function ENT:Impact(owner, entsIn, dt)
    local owner = self:GetOwner()

    local dmginfo = DamageInfo()
    dmginfo:SetDamage(mryks_damage:GetFloat() * dt)
    dmginfo:SetAttacker(owner) 
    dmginfo:SetInflictor(self) 
    dmginfo:SetDamageType(DMG_POISON)
    dmginfo:SetDamagePosition(self:GetPos())

    local damageBrain = mryks_damage_brain:GetFloat()
    local sleepMax = mryks_sleep_max:GetFloat()

    for _, ent in pairs(entsIn) do  
        if ent == owner then continue end
        if IsValid(ent) then
            if ent:IsNPC() then
                ent.mryks_sleepTime = math.Clamp((ent.mryks_sleepTime or 0) + dt * damageBrain, 0, sleepMax)
                ent:NextThink(CurTime() + ent.mryks_sleepTime)
                ent:TakeDamageInfo(dmginfo)
            elseif ent:IsPlayer() then
                if ent.mryks_sleepTime == nil then
                    ent:Freeze(true) 
                    ent:SendLua('mryks_eyefx(true)')
                    ent.mryks_sleepTime = math.Clamp(dt * damageBrain, 0, sleepMax)
                else
                    ent.mryks_sleepTime = math.Clamp(ent.mryks_sleepTime + dt * damageBrain, 0, sleepMax)
                end
            
                ent:TakeDamageInfo(dmginfo)
            end
        end
    end
end


local period = 0.5
local timeCount = 0
hook.Add('Think', 'mryks_player_sleep', function()
    timeCount = timeCount + FrameTime()
    if timeCount < period then return end
    timeCount = timeCount - period

    for _, ply in pairs(player.GetAll()) do
        if ply.mryks_sleepTime and ply.mryks_sleepTime > 0 then
            ply.mryks_sleepTime = ply.mryks_sleepTime - period
        end
        if ply.mryks_sleepTime and ply.mryks_sleepTime <= 0 then
            ply.mryks_sleepTime = nil
            ply:Freeze(false) 
            ply:SendLua('mryks_eyefx(false)')
        end
    end
end)
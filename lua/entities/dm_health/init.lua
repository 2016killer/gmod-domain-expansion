AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local dm_health_ka = CreateConVar('dm_health_ka', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local dm_health_damage = CreateConVar('dm_health_damage', '10', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

function ENT:Cost(radius, dt)
    return dm_health_ka:GetFloat() * radius * radius * 0.00390625 * 0.00390625 * dt, 0
end

function ENT:Impact(owner, entsIn, dt)
    local healthDamage = dm_health_damage:GetInt()

    for _, ent in pairs(entsIn) do
        if ent:IsPlayer() or ent:IsNPC() then
            ent:SetHealth(ent:Health() + healthDamage)
        end
    end
end

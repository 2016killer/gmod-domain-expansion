AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:OnTakeDamage(dmginfo)
    self:CostAcc(dmginfo:GetDamage(), 0)
end

function ENT:Impact(owner, entsIn, dt)
    -- (特性) 效果
end

function ENT:Cost(radius, dt)
    -- (特性) 消耗
end

function ENT:BornCall(dt)
    -- (特性) 展开时执行
end

function ENT:RunCall(dt)
    -- (特性) 运行时执行
end

function ENT:BreakCall(dt)
    -- (特性) 失效时执行
end
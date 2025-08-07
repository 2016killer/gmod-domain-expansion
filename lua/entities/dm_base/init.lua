AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:OnTakeDamage(dmginfo)
    self:CostAcc(dmginfo:GetDamage(), 0)
end

function ENT:Impact(owner, entsIn, dt)
    -- (特性) 效果
    -- 输入
    -- 归属, 目标, 时间增量

end

function ENT:Cost(radius, dt)
    -- (特性) 消耗
    -- 输入
    -- 半径, 时间增量
 
    -- 返回值
    -- 消耗护甲, 消耗生命

    return 0, 0
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
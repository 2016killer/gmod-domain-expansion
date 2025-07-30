AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')


function ENT:BreakCondition()
    -- (特性) 状态"失效"的切换条件
    -- 返回 true 切换
    local owner = self:GetOwner()
    if !IsValid(owner) then return true end
    if owner:Armor() <= 10 or owner:Health() < 50 then return true end 
end


function ENT:Impact(owner, entsIn, dt)
    -- (特性) 效果
end

function ENT:Cost(owner, dt)
    -- (特性) 消耗
    owner:SetHealth(owner:Health() - 1)
    owner:SetArmor(owner:Armor() - 1)
end


function ENT:Expand()
    -- (特性) 展开时执行
end

function ENT:Run()
    -- (特性) 运行时执行
end

function ENT:Break()
    -- (特性) 失效时执行
end



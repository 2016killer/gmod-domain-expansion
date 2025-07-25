ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = 'body'
ENT.Spawnable = true

-- 初始化函数
function ENT:Initialize()
    -- 设置模型为简单立方体
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    
    -- 启用物理
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    -- 获取物理对象并设置属性
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()               -- 唤醒物理对象
        phys:SetMass(25)          -- 设置质量
        phys:SetMaterial("metal") -- 设置材质（影响碰撞声音等）
    end
end


-- 玩家使用实体时的交互
function ENT:Use(activator, caller)
    if IsValid(activator) and activator:IsPlayer() then
        -- 给玩家一个小的力反馈
        if activator:GetVelocity():Length() < 500 then
            local pushDir = (activator:GetPos() - self:GetPos()):GetNormalized()
            activator:SetVelocity(pushDir * 200)
        end
        
        -- 播放使用声音
        self:EmitSound("buttons/button15.wav")
    end
end
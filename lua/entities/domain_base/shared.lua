ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'

ENT.ClassName = 'domain_base'
ENT.PrintName = 'Domain Base'
ENT.Category = 'domain'
ENT.Spawnable = true

RYOIKI_STATE_IDLE = 1
RYOIKI_STATE_EXPAND = 2
RYOIKI_STATE_RUN = 3
RYOIKI_STATE_BREAK = 4


if SERVER then
    function ENT:SetArmor(armor)
        self:SetNWInt('armor', armor)
    end

    function ENT:SetOwner_(owner)
        self:SetNWEntity('owner', owner)
    end

    function ENT:SetState(state)
        self:SetNWInt('state', state)
    end

    function ENT:SetTRadius(radius)
        self:SetNWFloat('tRadius', radius)
    end
else
    function ENT:GetShellEnts(state)
        local shell = self.shells[state]

        local extEnt
        if IsValid(shell.extEnt) then
            extEnt = shell.extEnt
        else
            local material = isstring(shell.extMaterial) and shell.extMaterial or 'domain/black'
            extEnt = ClientsideModel('models/dav0r/hoverball.mdl')
            extEnt:SetMaterial(material)
            extEnt:SetNoDraw(true)
            shell.extEnt = extEnt
        end

        local intEnt
        if IsValid(shell.intEnt) then
            intEnt = shell.intEnt
        else
            local material = isstring(shell.intMaterial) and shell.intMaterial or 'domain/black'
            intEnt = ClientsideModel('models/dav0r/hoverball.mdl')
            intEnt:SetMaterial(material)
            intEnt:SetNoDraw(true)
            shell.intEnt = intEnt
        end

        return extEnt, intEnt
    end

    function ENT:UpdateShellProgress(state, dt) 
        local shell = self.shells[state]
        local progress = shell.progress or 0
        dt = math.max(dt, 0)
        if dt == 0 then return progress end

        local fadeInSpeed = math.max(shell.fadeInSpeed or 1, 0)
        local fadeOutSpeed = math.max(shell.fadeOutSpeed or 1, 0)
        progress = math.Clamp(progress + (self:GetState() == state and fadeInSpeed or -fadeOutSpeed) * dt, 0, 1)
        shell.progress = progress
        return progress
    end

    function ENT:DrawShellExtEnt(state)
        -- (特性) 绘制领域外部
        local shell = self.shells[state]
        local extEnt = shell.extEnt
        if not IsValid(extEnt) then return end
        extEnt:DrawModel()
    end

    function ENT:DrawShellIntEnt(state)
        -- (特性) 绘制领域内部
        local shell = self.shells[state]
        local intEnt = shell.intEnt
        if not IsValid(intEnt) then return end
        render.CullMode(MATERIAL_CULLMODE_CW)
            intEnt:DrawModel()
        render.CullMode(MATERIAL_CULLMODE_CCW)
    end

    function ENT:InitShells()
        -- (特性) 领域外壳
        -- extMaterial 外部材质
        -- intMaterial 内部材质 (仅当extMaterial有剔除时有效)
        -- fadeInSpeed 淡入速度
        -- fadeOutSpeed 淡出速度
        self.shells = {
            [RYOIKI_STATE_EXPAND] = {},
            [RYOIKI_STATE_RUN] = {},
            [RYOIKI_STATE_BREAK] = {}
        }
    end

    function ENT:Draw()
        local dt = FrameTime()
        local scale = self.radius * 0.166
        self:SetModelScale(scale)

        for state, shell in pairs(self.shells) do
            local extEnt, intEnt = self:GetShellEnts(state)
            extEnt:SetPos(self:GetPos())
            intEnt:SetPos(self:GetPos())

            extEnt:SetModelScale(scale + 0.1)
            intEnt:SetModelScale(scale)

            local progress = self:UpdateShellProgress(state, dt)
            if progress == 0 then continue end

            render.ClearStencil()
            render.SetStencilEnable(true)
                render.SetStencilWriteMask(255)
                render.SetStencilTestMask(255)
                render.SetStencilReferenceValue(1)
                render.SetStencilCompareFunction(STENCIL_ALWAYS)
                render.SetStencilPassOperation(STENCIL_REPLACE)
                render.SetStencilFailOperation(STENCIL_KEEP)
                render.SetStencilZFailOperation(STENCIL_KEEP)

                render.SetBlend(progress)
                self:DrawShellExtEnt(state)
                

                render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
                
                self:DrawShellIntEnt(state)
                render.SetBlend(1)
            render.SetStencilEnable(false)

            if isfunction(shell.custom) then shell.custom(shell) end
        end
    end
end


function ENT:GetState()
    return self:GetNWInt('state')
end

function ENT:GetTRadius()
    return self:GetNWFloat('tRadius')
end

function ENT:GetOwner_()
    local owner = self:GetNWEntity('owner')
    return IsValid(owner) and owner or self
end

function ENT:Armor()
    return self:GetNWInt('armor') or 100
end


function ENT:Initialize() 
    if CLIENT then 
        self:InitShells() 
    else
        self:SetHealth(100)
        self:SetArmor(100)

        self:SetTRadius(500)
        self:SetState(RYOIKI_STATE_EXPAND)
    end

    self.radius = 0
    self.expandSpeed = GetConVar('domain_expand_speed'):GetFloat() -- 展开速度

    -- 静态
    self.open = true -- 开放性
    self.offset = true -- 防御
    self.run = true -- 效果

    self:SetModel('models/dav0r/hoverball.mdl')
    self:DrawShadow(false)
end

function ENT:BreakCondition()
    -- (特性) (SERVER) 领域消耗
    -- 返回true将解除领域
    local owner = self:GetOwner_()
    if !IsValid(owner) then return true end
    if owner:Armor() <= 10 or owner:Health() < 50 then return true end 
end

function ENT:Run(ents, dt)
    -- (特性) 领域效果
end

function ENT:Cost(owner, dt)
    -- (特性) 领域消耗
    if SERVER then
        owner:SetHealth(owner:Health() - 1)
        owner:SetArmor(owner:Armor() - 1)
    end
end

function ENT:Break()
    -- (特性) 领域解除
end

function ENT:Think()
    local state = self:GetState()

    if SERVER then
        -- 生命周期
        if self:BreakCondition() then 
            self:SetState(RYOIKI_STATE_BREAK) 
        end
        if state == RYOIKI_STATE_EXPAND and self.radius >= self:GetTRadius() then 
            self:SetState(RYOIKI_STATE_RUN)
        end
    end

    local dt = SERVER and 0.1 or FrameTime()
    if state == RYOIKI_STATE_EXPAND then
        self.radius = math.Clamp(self.radius + self.expandSpeed * dt, 0, self:GetTRadius()) 
    elseif state == RYOIKI_STATE_RUN then
        local owner = self:GetOwner_()
        self:Cost(owner, dt)  
        if self.run then
            self:Run(owner, ents.FindInSphere(self:GetPos(), self.radius), dt)
        else
            self:SetPos(owner:GetPos())
        end
    elseif state == RYOIKI_STATE_BREAK then 
        self.radius = math.max(self.radius - self.expandSpeed * dt * 3, 0)
        if SERVER and self.radius <= 0 then self:Remove() end
        self:Break()
    end

    self:NextThink(CurTime() + dt)
    return true
end

function ENT:OnRemove()
    if CLIENT then
        for state, _ in pairs(self.shells) do
            local extEnt, intEnt = self:GetShellEnts(state)
            extEnt:Remove()
            intEnt:Remove()
        end
    end
end

    // -- 启用物理
    // self:PhysicsInit(SOLID_VPHYSICS)
    // self:SetMoveType(MOVETYPE_VPHYSICS)
    // self:SetSolid(SOLID_VPHYSICS)
    
    // -- 获取物理对象并设置属性
    // local phys = self:GetPhysicsObject()
    // if phys:IsValid() then
    //     phys:Wake()               -- 唤醒物理对象
    //     phys:SetMass(25)          -- 设置质量
    //     phys:SetMaterial("metal") -- 设置材质（影响碰撞声音等）
    // end
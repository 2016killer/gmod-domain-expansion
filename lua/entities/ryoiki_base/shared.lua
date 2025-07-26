ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'

ENT.ClassName = 'ryoiki_base'
ENT.PrintName = 'Ryoiki Base'
ENT.Category = 'ryoiki'
ENT.Spawnable = true


RYOIKI_STATE_EXPAND = 1
RYOIKI_STATE_RUN = 2
RYOIKI_STATE_BREAK = 3


local function GetShellEnts(shell)
    local extEnt
    if IsValid(shell.extEnt) then
        extEnt = shell.extEnt
    else
        local material = isstring(shell.extMaterial) and shell.extMaterial or ''
        extEnt = ClientsideModel('models/dav0r/hoverball.mdl')
        extEnt:SetMaterial(material)
        extEnt:SetNoDraw(true)
        shell.extEnt = extEnt
    end

    local intEnt
    if IsValid(shell.intEnt) then
        intEnt = shell.intEnt
    else
        local material = isstring(shell.intMaterial) and shell.intMaterial or ''
        intEnt = ClientsideModel('models/dav0r/hoverball.mdl')
        intEnt:SetMaterial(material)
        intEnt:SetNoDraw(true)
        shell.intEnt = intEnt
    end

    return extEnt, intEnt
end

local function UpdateShellProgress(shell, dir, dt) 
    dt = math.max(dt, 0)
    if dt == 0 then return shell.progress end

    local fadeInSpeed = math.max(shell.fadeInSpeed or 1, 0)
    local fadeOutSpeed = math.max(shell.fadeOutSpeed or 1, 0)
    shell.progress = math.Clamp(shell.progress + (dir and fadeInSpeed or -fadeOutSpeed) * dt, 0, 1)
    return shell.progress
end

function ENT:Initialize() 
    if CLIENT then
        self.shells = {
            [RYOIKI_STATE_EXPAND] = {
                extMaterial = 'ryoiki/black',
                intMaterial = 'ryoiki/white',
    
                progress = 0
            },
            [RYOIKI_STATE_RUN] = {
                extMaterial = 'ryoiki/white',
                intMaterial = 'ryoiki/black',
    
                progress = 0
            }
        }

        self.shellFadeInSpeed = 1
        self.shellFadeOutSpeed = 1
    end
    
    
    self.state = RYOIKI_STATE_EXPAND
    self.radius = 0
    self.targetRadius = 500
    self.expandSpeed = GetConVar('ryoiki_expand_speed'):GetFloat() -- 展开速度

    -- 静态
    self.open = true -- 开放性
    self.offset = true -- 防御
    self.run = true -- 效果
    

    self:SetModel('models/dav0r/hoverball.mdl')
    self:DrawShadow(false)
end

function ENT:Draw()
    local dt = FrameTime()
    local scale = self.radius * 0.17 - 1
    self:SetModelScale(scale)

    for state, shell in pairs(self.shells) do
        local extEnt, intEnt = GetShellEnts(shell)
        extEnt:SetPos(self:GetPos())
        intEnt:SetPos(self:GetPos())

        extEnt:SetModelScale(scale + 0.1)
        intEnt:SetModelScale(scale)

        local progress = UpdateShellProgress(shell, self.state == state, dt)
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
            self:DrawShellExtEnt(state, shell)
            

            render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
            
            self:DrawShellIntEnt(state, shell)
            render.SetBlend(1)
        render.SetStencilEnable(false)

        if isfunction(shell.custom) then shell.custom(shell) end
    end
end


function ENT:DrawShellExtEnt(state, shell)
    -- 绘制领域外部
    local extEnt = shell.extEnt
    if not IsValid(extEnt) then return end
    extEnt:DrawModel()
end

function ENT:DrawShellIntEnt(state, shell)
    -- 绘制领域内部
    local intEnt = shell.intEnt
    if not IsValid(intEnt) then return end
    render.CullMode(MATERIAL_CULLMODE_CW)
        intEnt:DrawModel()
    render.CullMode(MATERIAL_CULLMODE_CCW)
end

function ENT:BreakCondition()
    -- 领域消耗
    -- 返回true将解除领域
    local owner = self:GetOwner()
    if IsValid(owner) then 
        if owner:Health() <= 50 then return true end 
    end
end

function ENT:Run(ents)
    -- 领域效果
end

function ENT:Cost()
    -- 领域消耗
end

function ENT:Break()
    -- 领域解除
    if SERVER then
        timer.Simple(1, function() 
            if IsValid(self) then
                self:Remove() 
            end
        end) 
    end
end

function ENT:Think()
    -- 生命周期
    if self:BreakCondition() then self.state = RYOIKI_STATE_BREAK end
    if self.state == RYOIKI_STATE_EXPAND and self.radius >= self.targetRadius then 
        self.state = RYOIKI_STATE_RUN 
    end

    local dt = SERVER and 0.1 or FrameTime()
    if self.state == RYOIKI_STATE_EXPAND then
        self.radius = math.Clamp(self.radius + self.expandSpeed * dt, 0, self.targetRadius) 
    elseif self.state == RYOIKI_STATE_RUN then
        self:Cost()  
        if self.run then
            self:Run(ents.FindInSphere(self:GetPos(), self.radius))
        else
            local owner = self:GetOwner()
            self:SetPos(owner:GetPos())
        end
    elseif self.state == RYOIKI_STATE_BREAK then
        if !self.breakFlag then 
            self.breakFlag = true
            self:Break()
        end
    end

    self:NextThink(CurTime() + dt)
    return true
end

function ENT:OnRemove()
    if CLIENT then
        for state, shell in pairs(self.shells) do
            local extEnt, intEnt = GetShellEnts(shell)
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
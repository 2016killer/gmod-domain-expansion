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


function ENT:SetupDataTables()
    self:SetHealth(100)
    self:NetworkVar('Int', 0, 'Armor')
    self:NetworkVar('Int', 'State')
    self:NetworkVar('Float', 'TRadius')
end

function ENT:Armor() return self:GetArmor() end

function ENT:Initialize() 
    if CLIENT then 
        self:InitShells()
        self:InitShellEnts()
    end
    self:SetArmor(100)
    self:SetOwner(self)
    self:SetState(RYOIKI_STATE_EXPAND)
    self:SetTRadius(500)

    self.radius = 0
    self.expandSpeed = GetConVar('domain_expand_speed'):GetFloat() -- 展开速度

    self:SetModel('models/dav0r/hoverball.mdl')
    self:DrawShadow(false)
end

function ENT:Think()
    local state = self:GetState()
    local tRadius = self:GetTRadius()
    local dt = SERVER and 0.1 or FrameTime()
   
    if SERVER then
        -- 生命周期切换
        if self:BreakCondition() then 
            self:SetState(RYOIKI_STATE_BREAK) 
        end
        if state == RYOIKI_STATE_EXPAND and self.radius >= tRadius then 
            self:SetState(RYOIKI_STATE_RUN)
        end
    end

    -- 动作
    if state == RYOIKI_STATE_EXPAND then
        self.radius = math.Clamp(self.radius + self.expandSpeed * dt, 
            0, 
            tRadius) 
        self:SetScale(self.radius * 0.166)

        local owner = self:GetOwner()
        local center = owner:GetPos()

    elseif state == RYOIKI_STATE_RUN then
        local owner = self:GetOwner()
        local center = owner:GetPos()

        self:Cost(owner, dt)  
        if SERVER then
            local entsIn = {}
            for _, ent in pairs(ents.FindInSphere(center, self.radius)) do
                if ent == self or ent == owner then continue end
                table.insert(entsIn, ent)
            end
            self:Impact(owner, entsIn, dt) 
        else
            self:Impact(owner, dt) 
        end

        self:Run()
    elseif state == RYOIKI_STATE_BREAK then 
        self.radius = math.max(self.radius - 1000 * dt, 0)
        self:SetScale(self.radius * 0.166)
        if SERVER and self.radius <= 0 then self:Remove() end

        self:Break()
    end

    self:NextThink(CurTime() + dt)
    return true
end

function ENT:Move(pos)
    self:SetPos(pos)
    if CLIENT then
        for _, shell in pairs(self.shells) do
            if IsValid(shell.ent) then 
                shell.ent:SetPos(pos) 
            end
        end
    end
end

function ENT:SetScale(scale)
    if CLIENT then
        self:SetModelScale(scale)
        for _, shell in pairs(self.shells) do
            if IsValid(shell.ent) then 
                shell.ent:SetModelScale(scale) 
            end
        end
    end
end

function ENT:Cover(input)
    if isvector(input) then
        local dvec = input - self:GetPos()  
        return dvec:Dot(dvec) <= self.radius * self.radius
    elseif isentity(input) then
        return self:Cover(input:GetPos())
    else
        error('输入必须为向量或实体类型')
    end
end




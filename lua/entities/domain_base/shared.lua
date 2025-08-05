ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'

ENT.ClassName = 'domain_base'
ENT.PrintName = 'Domain Base'
ENT.Category = 'Domain'
ENT.Spawnable = true


-- 生命周期 BORN -> RUN -> BREAK
DOMAIN_STATE_BORN = 1
DOMAIN_STATE_RUN = 2
DOMAIN_STATE_BREAK = 3

local STATE_BORN = DOMAIN_STATE_BORN
local STATE_RUN = DOMAIN_STATE_RUN
local STATE_BREAK = DOMAIN_STATE_BREAK

function ENT:SetupDataTables()
    -- 调试变量, 用于无归属领域
    self:SetHealth(100)
    self:NetworkVar('Int', 0, 'Armor') 
    self:NetworkVar('Bool', 'Execute') 

    -- 主要变量
    self:NetworkVar('Int', 'State')
    self:NetworkVar('Float', 'TRadius')
end

function ENT:Armor() return self:GetArmor() end

function ENT:Initialize() 
    if CLIENT then 
        self:InitShells()
        self:InitShellEnts() 
    else
        table.insert(DOMAIN_ALL, self)
    end

    self:SetArmor(100)
    self:SetOwner(self)
    self:SetState(STATE_BORN)
    self:SetTRadius(2000)
    self:SetExecute(true)

    self.radius = 0
    self.expandSpeed = GetConVar('dm_expand_speed'):GetFloat() -- 展开速度

    self:SetModel('models/dav0r/hoverball.mdl')
    self:DrawShadow(false)

    self:Move(self:GetPos())
    self.impactEnts = {}
end


local dm_armor_condition = CreateConVar('dm_armor_condition', '20', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local dm_health_condition = CreateConVar('dm_health_condition', '20', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

local function BreakCondition(domain)
    local owner = domain:GetOwner()
    if not IsValid(owner) then 
        return true 
    elseif owner:Armor() <= dm_armor_condition:GetFloat() or owner:Health() < dm_health_condition:GetFloat() then 
        return true 
    end
end

function ENT:Think()
    local state = self:GetState()
    local tRadius = self:GetTRadius()
    local execute = self:GetExecute()
    local owner = self:GetOwner()
    local dt = SERVER and 0.1 or FrameTime()
   
    if SERVER then
        -- 生命周期切换
        if BreakCondition(self) then 
            self:SetState(STATE_BREAK) 
        end
        if state == STATE_BORN and self.radius >= tRadius then
            self:SetState(STATE_RUN)
        end
    end

    -- 动作
    if state == STATE_BORN then
        self.radius = math.Clamp(self.radius + self.expandSpeed * dt, 
            0, 
            tRadius) 
        self:SetScale(self.radius * 0.166)
        self:Born(dt)
    elseif state == STATE_RUN then 
        if SERVER and execute then 
            local owner = self:GetOwner()
    
            self:Impact(owner, self.impactEnts, dt) 
            local costArmor, costHealth = self:Cost(tRadius, dt)
            
            if costArmor ~= nil and costArmor > 0 then
                local armor = owner:Armor()
                if armor > 0 then
                    owner:SetArmor(math.max(1, armor - costArmor))
                end
            end
            if costHealth ~= nil and costHealth > 0 then
                local health = owner:Health()
                if health > 0 then
                    owner:SetHealth(math.max(1, health - costHealth))
                end
            end
        end
        self:Run(dt)
    elseif state == STATE_BREAK then 
        self.radius = math.max(self.radius - 1000 * dt, 0)
        self:SetScale(self.radius * 0.166)
        if SERVER and self.radius <= 0 then self:Remove() end

        self:Break(dt)
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

if SERVER then
    DOMAIN_ALL = {} -- 添加到此才能触发搜索
    local domainAll = DOMAIN_ALL
    local searchPeriod = 0.05
    local searchTimer = 0
    hook.Add('Think', 'domain_search', function()
        -- 筛选领域包含的实体集合
        -- 自身范围内并不被其他领域包含的实体 (不包含自身)
        -- 计数法筛选
        
        searchTimer = searchTimer + FrameTime()
        if searchTimer < searchPeriod then return end
        searchTimer = 0

        if #domainAll < 1 then return end

        local allSphereEntities = {}
        local inSphereCount = {}

        for i = #domainAll, 1, -1 do
            local domain = domainAll[i]
            
            if not IsValid(domain) then
                table.remove(domainAll, i)
                continue
            end
                
            -- 获取球体内的实体
            local sphereEnts = ents.FindInSphere(domain:GetPos(), domain.radius)
            local validEnts = {}
            
            -- 记录有效实体并计数
            for _, ent in ipairs(sphereEnts) do
                if not IsValid(ent) or ent == domain or ent:IsWorld() then continue end
                if ent:IsPlayer() and not ent:Alive() then continue end
                local entIndex = ent:EntIndex()
                table.insert(validEnts, ent)
                inSphereCount[entIndex] = (inSphereCount[entIndex] or 0) + 1
            end
            
            allSphereEntities[i] = {
                domain = domain,
                entities = validEnts
            }
        end

        
        for _, data in pairs(allSphereEntities) do
            local uniqueEntities = {}
            
            for _, ent in ipairs(data.entities) do
                local entIndex = ent:EntIndex()
                if inSphereCount[entIndex] == 1 then
                    table.insert(uniqueEntities, ent)
                end
            end
            
            data.domain.impactEnts = uniqueEntities
        end

        -- 领域对抗
        for _, domain in pairs(domainAll) do

 
        end
    end)

end



ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'

ENT.ClassName = 'domain_base'
ENT.PrintName = 'Domain Base'
ENT.Category = 'Domain'
ENT.Spawnable = true

ENT.AllInstance = {}
ENT.STATE_BORN = 1
ENT.STATE_RUN = 2
ENT.STATE_BREAK = 3

-- 生命周期 BORN -> RUN -> BREAK
local AllInstance = ENT.AllInstance
local STATE_BORN = ENT.STATE_BORN
local STATE_RUN = ENT.STATE_RUN
local STATE_BREAK = ENT.STATE_BREAK

function ENT:Born() 
    self:SetState(STATE_BORN) 
end

function ENT:Run()
    self:SetState(STATE_RUN)
end

function ENT:Break()
    self:SetState(STATE_BREAK)
end

function ENT:IsBorn() 
    return self:GetState() == STATE_BORN
end

function ENT:IsRun()
    return self:GetState() == STATE_RUN
end

function ENT:IsBreak()
    return self:GetState() == STATE_BREAK
end

function ENT:Register()
    table.insert(AllInstance, self)
end

function ENT:SetupDataTables()
    -- 调试变量, 用于无归属领域
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
        self:Register()
    end

    self:SetHealth(100)
    self:SetArmor(100)
    self:SetState(STATE_BORN)
    if not IsValid(self:GetOwner()) then 
        self:SetOwner(self) 
        self:SetTRadius(500)
        self:SetExecute(true)
    end

    self.radius = 0
    self.expandSpeed = GetConVar('dm_expand_speed'):GetFloat() -- 展开速度

    self:SetModel('models/dav0r/hoverball.mdl')
    self:DrawShadow(false)

    self:Move(self:GetPos())
    self.impactEnts = {}
end


local dm_armor_condition = CreateConVar('dm_armor_condition', '20', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local dm_health_condition = CreateConVar('dm_health_condition', '20', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

local function BreakCondition(domain)
    local owner = domain:GetOwner()
    if not IsValid(owner) then 
        return true 
    elseif owner:IsPlayer() and not owner:Alive() then 
        return true 
    elseif owner:Armor() < dm_armor_condition:GetFloat() or owner:Health() < dm_health_condition:GetFloat() then 
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
        self:BornCall(dt)
    elseif state == STATE_RUN then 
        if SERVER and execute then 
            self:Impact(self:GetOwner(), self.impactEnts, dt)  
            self:CostAcc(self:Cost(tRadius, dt))
        end
        self:RunCall(dt)
    elseif state == STATE_BREAK then 
        self.radius = math.max(self.radius - 1000 * dt, 0)
        self:SetScale(self.radius * 0.166)
        if SERVER and self.radius <= 0 then self:Remove() end

        self:BreakCall(dt)
    end

    self.stateLast = state
    self:NextThink(CurTime() + dt)
    return true
end

function ENT:CostAcc(costArmor, costHealth)
    self.caAcc = (self.caAcc or 0) + (costArmor or 0)
    self.chAcc = (self.chAcc or 0) + (costHealth or 0)

    local caInt = math.floor(self.caAcc)
    local chInt = math.floor(self.chAcc)
    
    local owner = self:GetOwner()
    if caInt > 0 then
        self.caAcc = self.caAcc - caInt

        local armor = owner:Armor()
        if armor > 0 then
            owner:SetArmor(math.max(1, armor - caInt))
        end
    end

    if chInt > 0 then
        self.chAcc = self.chAcc - chInt

        local health = owner:Health()
        if health > 0 then
            owner:SetHealth(math.max(1, health - chInt))
        end
    end
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
    self:SetModelScale(scale) -- 确保外壳在可见集里以及能够被搜索到
    if CLIENT then
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

local dm_ft = CreateConVar('dm_ft', '60', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
function ENT:OnRemove()
    local owner = self:GetOwner()
    if CLIENT then
        for _, shell in pairs(self.shells) do
            if IsValid(shell.ent) then shell.ent:Remove() end
        end
        if IsValid(owner) and owner:IsPlayer() then
            owner:EmitSound('ambient/energy/newspark11.wav')
        end   
    else 
        if IsValid(owner) and owner:IsPlayer() then
            owner:SetNWFloat('FusingTime', CurTime() + dm_ft:GetFloat())
        end
    end
end

if SERVER then
    -- 搜索与碰撞逻辑
    local cdamage = CreateConVar('dm_cdamage', '5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
    local tickcount = 0
    local period = 2
    hook.Add('Think', 'domain_search', function()
        -- 筛选领域包含的实体集合
        -- 自身范围内并不被其他领域包含的实体 (不包含自身)
        -- 计数法筛选
    
        tickcount = tickcount + 1
        if tickcount < period then return end
        tickcount = 0
        if #AllInstance < 1 then return end

        local cdamageinfo = DamageInfo() -- 碰撞伤害
        cdamageinfo:SetDamage(cdamage:GetFloat() * FrameTime() * period)


        local allSphereEntities = {}
        local inSphereCount = {}

        for i = #AllInstance, 1, -1 do
            local domain = AllInstance[i]
            
            if not IsValid(domain) then
                table.remove(AllInstance, i)
                continue
            end
                
            -- 获取球体内的实体
            local sphereEnts = ents.FindInSphere(domain:GetPos(), domain.radius)
            local validEnts = {}
            
            -- 记录有效实体并计数
            for _, ent in ipairs(sphereEnts) do
                if ent == domain then continue end
                -- TODO 用全局哈希可能更快, 但是管理更麻烦
                if scripted_ents.IsBasedOn(ent:GetClass(), 'domain_base')then
                    ent:TakeDamageInfo(cdamageinfo)
                else
                    if not IsValid(ent) or ent:IsWorld() or not ent:IsSolid() then 
                        continue 
                    end
                    if ent:IsPlayer() and not ent:Alive() then 
                        continue 
                    end
            
                    local entIndex = ent:EntIndex()

                    table.insert(validEnts, ent)
                    inSphereCount[entIndex] = (inSphereCount[entIndex] or 0) + 1
                end
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
    end)

end



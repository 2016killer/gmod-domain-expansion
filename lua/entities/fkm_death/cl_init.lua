include('shared.lua')

domain_materialTable = {}

local zero = Vector()
local white = Color(255, 255, 255, 255)

function ENT:Initialize()
    self.timer = 0
    self.bornTime = CurTime()
    self.emitter = ParticleEmitter(self:GetPos())
    self:SetRenderClipPlaneEnabled(true)
end

function ENT:Think()
    if self.bornTime == nil then return end 

    -- 裁剪特效
	local n = self:LocalToWorld(self.clipDir) - self:GetPos()
	local p = self:LocalToWorld(self.clipPos + (CurTime() - self.bornTime) * self.speed * self.clipDir)
	self:SetRenderClipPlane(n, n:Dot(p))

    -- 粒子特效
    self.timer = self.timer + FrameTime()
    if self.timer >= self.period then
        self.timer = self.timer - self.period

        for i = 1, self.num do 
            local part = self.emitter:Add(self.mat, p) 
            local dir = VectorRand()
            if dir:Dot(n) < 0 then dir = -dir end
            if part then
                part:SetDieTime(self.dieTime) 

                part:SetStartAlpha(255) 
                part:SetEndAlpha(0)

                part:SetStartSize(self.width) 
                part:SetEndSize(0) 

                part:SetStartLength(self.length)
                part:SetEndLength(0)

                part:SetGravity(zero) 
                part:SetVelocity((n + dir) * self.vel)
            end
        end
    end
end

function ENT:InitRenderData(modelName, materialName, color, scale)
    -- 初始化渲染数据
    modelName = modelName or 'models/props_c17/FurnitureCouch002a.mdl'
    materialName = materialName or ''
    color = color or white
    scale = scale or 1

    self:SetModel(modelName)
    self:SetMaterial(materialName)
    self:SetColor(color)
    self:SetModel(scale)
end

function ENT:InitEffectData(clipDir, clipPos, speed)
    -- 初始化裁剪特效数据
    self.clipDir = self:WorldToLocal(clipDir + self:GetPos())
    self.clipPos = self:WorldToLocal(clipPos)
    self.speed = speed or 100
end

function ENT:InitParticleData(mat, num, period, dieTime, width, length, vel)
    -- 初始化粒子特效数据
    self.mat = mat or 'effects/bloodspray'
    self.num = num or 10
    self.period = period or 0.05
    self.dieTime = dieTime or 1
    self.width = width or 30
    self.length = length or 30
    self.vel = 100
end


function ENT:OnRemove()
    if self.emitter then self.emitter:Finish() end
end

concommand.Add('test', function(ply)
    local tr = ply:GetEyeTrace()
    local ent = tr.Entity


    local ent = ents.CreateClientside('fkm_death')
    ent:SetPos(tr.HitPos + tr.HitNormal * 100)
    ent:InitRenderData()
    ent:InitEffectData(Vector(0, 0, 1), tr.HitPos)
    ent:InitParticleData()
    ent:Spawn()
    
end)

concommand.Add('domain_clear_fkm_death', function()
    for _, ent in ipairs(ents.FindByClass('fkm_death')) do
        ent:Remove()
    end
end)

concommand.Add('test', function()
    local tr = LocalPlayer():GetEyeTrace()
    local ent = tr.Entity
    local dir = tr.Normal

    
end)




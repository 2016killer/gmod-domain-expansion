include('shared.lua')

local zero = Vector()
local zerof = 0.0000152587890625

local render = render
local math = math
local FastAABBSection = dm_FastAABBSection
local Points3D2Poly = dm_3DPoints2Poly
local UniformTriangle = dm_UniformTriangle
local GetAABBScanData = dm_GetAABBScanData
local SimpleMesh = dm_SimpleMesh
local Points3DGrahamScan = dm_3DPointsGrahamScan
local GetAABBVertexes = dm_GetAABBVertexes
local CurTime = CurTime
local FrameTime = FrameTime
local VectorRand = VectorRand
local SafeRemoveEntity = SafeRemoveEntity


local effectCount = fkmd_effectCount


function ENT:Initialize()
    self.bornTime = CurTime()
    self.emitter = ParticleEmitter(self:GetPos())
    self.effectTimer = 0
    self:SetRenderClipPlaneEnabled(true)
    // self:DrawShadow(false)

    local parent = self:GetParent()
    -- 线程安全? Yes
    if IsValid(parent) and parent:IsRagdoll() then
        effectCount.Ragdoll = effectCount.Ragdoll + 1
        self.isRagdoll = true
    else
        effectCount.Entity = effectCount.Entity + 1
    end
end

function ENT:UpdateClip(depth)
    depth = depth or self.currentDepth 
	local n = self:LocalToWorld(self.scanData.dir) - self:GetPos()
	local p = self:LocalToWorld(self.scanData.dir * depth)
    self:SetRenderClipPlane(n, n:Dot(p))
    // self.n = n
    // self.p = n:Dot(p)
    return n, p
end

function ENT:UpdateSection(depth)
    depth = depth or self.currentDepth
    local ipoints = FastAABBSection(self.scanData, depth)
    if #ipoints < 3 then return end
    self.currentSection = Points3D2Poly(
        ipoints, 
        self.scanData.u, 
        self.scanData.v
    ) 
end

function ENT:Think()
    if self.bornTime == nil then return end 
    local dt = 0.05
    local effectPeriod = 0.1

    self.currentDepth = self.currentDepth + self.speed * dt
    if self.currentDepth >= self.endDepth then self:Remove() end

    // 粒子特效
    self.effectTimer = self.effectTimer + dt
    if self.effectTimer >= effectPeriod then
        self.effectTimer = self.effectTimer - effectPeriod
        self:UpdateSection()
        self:ParticleEffect()
        self:SoundEffect()
    end

    self:SetNextClientThink(CurTime() + dt)
    return true
end

function ENT:InitModel(ent)
    -- 初始化渲染数据
    if not IsValid(ent) then return end
    local pos = ent:GetPos()
    local ang = ent:GetAngles()

    self:SetModel(ent:GetModel())
    self:SetMaterial(ent:GetMaterial())
    // self:SetColor(ent:GetColor())
    self:SetModelScale(ent:GetModelScale() or 1)

    self:SetPos(pos)
    self:SetAngles(ang)
    self:SetParent(ent)
    if ent:IsRagdoll() then self:AddEffects(EF_BONEMERGE) end
end

function ENT:InitClip(dir, start, matType, speed, mins, maxs)
    -- 初始化裁剪特效数据
    -- dir 裁剪方向 (非零向量)
    -- start 裁剪开始比例 (0-1)
    -- speed 裁剪速度 (单位/秒)
    -- mins=ModelBounds 模型最小边界 
    -- maxs=... 模型最大边界

    dir = dir:GetNormalized()
    start = math.Clamp(start or 0, 0, 1)
    speed = math.max(speed or 100, 0)
    if dir:Dot(dir) < zerof then error('dir为零向量') end
    if mins == nil then mins, maxs = self:GetModelBounds() end

    self.scanData = GetAABBScanData(mins, maxs, dir)
    self.currentDepth = start * (self.scanData.maxDepth - self.scanData.minDepth) + self.scanData.minDepth
    self.endDepth = self.scanData.maxDepth
    self.speed = speed

    -- 截面 (用于采样粒子坐标)
    self.currentSection = {}

    -- 特效数据
    self:SetEffectData(matType)

    -- 生成包络多边形 (投影多边形) (用于渲染截面)
    self.bounds2d = SimpleMesh(
        Points3DGrahamScan(
            GetAABBVertexes(mins, maxs),
            self.scanData.u,
            self.scanData.v
        ),
        -self.scanData.dir
    )
end

local fkmd_particle_level = CreateClientConVar('fkmd_particle_level', '0.5', true, false)
function ENT:ParticleEffect(depth)
    -- 粒子特效
    local emitter = self.emitter
    local ref, _ = self:UpdateClip()
    local tris = self.currentSection
    local matp = self.effectData.matp
    
    
    local numPer = 40 * math.Clamp(fkmd_particle_level:GetFloat(), 0, 1) / #tris
    for _, tri in pairs(tris) do 
        local p1 = tri[1]
        local l1 = tri[2] - p1
        local l2 = tri[3] - p1

        for i = 1, numPer do
            local dir = VectorRand()
            if dir:Dot(ref) < 0 then dir = -dir end

            local ptype = math.random() > 0.3
            local part = emitter:Add(
                matp, 
                self:LocalToWorld(p1 + UniformTriangle(l1, l2))
            )
            if part then
                part:SetDieTime(0.5)

                part:SetStartAlpha(255)
                part:SetEndAlpha(0)

                part:SetStartSize(ptype and 15 or 15)
                part:SetEndSize(0)

                part:SetStartLength(ptype and 50 or 15)
                part:SetEndLength(0)

                part:SetGravity(VectorRand() * 100)
                part:SetVelocity(ref * (ptype and 300 or 50))
                part:SetColor(255, 255, 0)
            end
        end
    end
end

function ENT:SetDuration(duration)
    self.speed = (self.endDepth - self.currentDepth) / duration
end

function ENT:SoundEffect()
    local sound = self.effectData.sound
    if sound then self:EmitSound(sound) end
end

function ENT:OnRemove()
    if IsValid(self.emitter) then self.emitter:Finish() end

    local parent = self:GetParent()
    if IsValid(parent) then
        if self.removeParent then 
            SafeRemoveEntity(self:GetParent()) 
        end
    end

    if self.isRagdoll then
        effectCount.Ragdoll = math.max(effectCount.Ragdoll - 1, 0)
    else
        effectCount.Entity = math.max(effectCount.Entity - 1, 0)
    end
end

function ENT:Draw() 
    -- source引擎优化好, 经得起这些操作
    local matrix = self:GetWorldTransformMatrix()
    local mat = self.effectData.mat
    local n, _ = self:UpdateClip() // 裁剪特效

    matrix:SetTranslation(matrix:GetTranslation() + n * (self.currentDepth + 0.5))

    render.OverrideDepthEnable(true, true)
        self:DrawModel()
    render.OverrideDepthEnable(false)

    render.ClearStencil() 
    render.SetStencilEnable(true)
        render.SetStencilTestMask(255)
        render.SetStencilWriteMask(255)
        render.SetStencilReferenceValue(2)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)

        render.CullMode(MATERIAL_CULLMODE_CW)
            self:DrawModel()
        render.CullMode(MATERIAL_CULLMODE_CCW)

        render.SetStencilCompareFunction(STENCIL_EQUAL)

        if mat then render.SetMaterial(mat) end
        cam.PushModelMatrix(matrix)
            self.bounds2d:Draw()
        cam.PopModelMatrix()
    render.SetStencilEnable(false)
end

local materialTypeTable = fkmd_materialTypeTable
local effectDataTable = fkmd_effectDataTable

function ENT:SetEffectData(matType)
    -- 默认为金属样式特效
    for tp, hash in pairs(materialTypeTable) do
        if hash[matType] and effectDataTable[tp] then
            self.effectData = effectDataTable[tp]
            return
        end
    end
    self.effectData = effectDataTable['Metal']
end
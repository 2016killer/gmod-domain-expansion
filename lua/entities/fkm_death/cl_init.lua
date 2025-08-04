include('shared.lua')

local zero = Vector()
local zerof = 0.0000152587890625
local white = Color(255, 255, 255, 255)

local render = render
local math = math
local FastAABBSection = domain_FastAABBSection
local Points3D2Poly = domain_3DPoints2Poly
local UniformTriangle = domain_UniformTriangle
local GetAABBScanData = domain_GetAABBScanData
local SimpleMesh = domain_SimpleMesh
local Points3DGrahamScan = domain_3DPointsGrahamScan
local GetAABBVertexes = domain_GetAABBVertexes

function ENT:Initialize()
    self.bornTime = CurTime()
    self.emitter = ParticleEmitter(self:GetPos())
    self.effectTimer = 0
    self:SetRenderClipPlaneEnabled(true)
end

function ENT:UpdateClip(depth)
    depth = depth or self.currentDepth 
	local n = self:LocalToWorld(self.scanData.dir) - self:GetPos()
	local p = self:LocalToWorld(self.scanData.dir * depth)
    self:SetRenderClipPlane(n, n:Dot(p))
    // self.n = n
    // self.p = n:Dot(p)
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
    // 裁剪特效
    self:UpdateClip()

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

function ENT:InitModel(modelName, materialName, color, scale, matType)
    -- 初始化渲染数据
    modelName = modelName or 'models/props_c17/FurnitureCouch002a.mdl'
    materialName = materialName or ''
    color = color or white
    scale = scale or 1

    self:SetModel(modelName)
    self:SetMaterial(materialName)
    self:SetModelScale(scale)
end

function ENT:InitClip(dir, start, speed, mins, maxs, matType)
    -- 初始化裁剪特效数据
    -- dir 裁剪方向 (非零向量)
    -- start 裁剪开始比例 (0-1)
    -- speed 裁剪速度 (单位/秒)
    -- mins=ModelBounds 模型最小边界 
    -- maxs=... 模型最大边界
    
    dir = (dir or -Vector(1, 1, 1)):GetNormalized()
    start = math.Clamp(start or 0, 0, 1)
    // speed = math.max(speed or 100, 0)
    if dir:Dot(dir) < zerof then error('dir为零向量') end
    if mins == nil then mins, maxs = self:GetModelBounds() end

    self.scanData = GetAABBScanData(mins, maxs, dir)
    self.currentDepth = start * (self.scanData.maxDepth - self.scanData.minDepth) + self.scanData.minDepth
    self.endDepth = self.scanData.maxDepth
    self.speed = math.max(speed or (self.endDepth - self.currentDepth) * 2, 0)

    -- 截面 (用于采样粒子坐标)
    self.currentSection = {}

    -- 特效数据
    self:SetEffectData(matType)

    -- 生成包络多边形 (用于渲染截面)
    self.bounds2d = SimpleMesh(
        Points3DGrahamScan(
            GetAABBVertexes(mins, maxs),
            self.scanData.u,
            self.scanData.v
        )
    )
end

local materialTypeTable = domain_materialTypeTable
local effectDataTable = domain_effectDataTable

function ENT:SetEffectData(matType)
    for tp, hash in pairs(materialTypeTable) do
        if hash[matType] and effectDataTable[tp] then
            self.effectData = effectDataTable[tp]
            return
        end
    end
    self.effectData = effectDataTable['Metal']
end


function ENT:ParticleEffect(depth)
    local emitter = self.emitter
    local ref = self.scanData.dir
    local tris = self.currentSection
    local matp = self.effectData.matp

    local numPer = 20 / #tris
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
                part:SetVelocity(-ref * (ptype and 300 or 50))
                part:SetColor(255, 255, 0)
            end
        end
    end
end

function ENT:SoundEffect()
    local sound = self.effectData.sound

    if sound then self:EmitSound(sound) end
end

function ENT:OnRemove()
    if self.emitter then self.emitter:Finish() end
end

function ENT:Draw() 
    -- source引擎优化好, 经得起这种操作
    local matrix = self:GetWorldTransformMatrix()
    local mat = self.effectData.mat
    local n = self:LocalToWorld(self.scanData.dir) - self:GetPos()
    
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

concommand.Add('domain_debug_fkm_death', function(ply)
    local tr = ply:GetEyeTrace()
    local ent = tr.Entity


    local ent = ents.CreateClientside('fkm_death')
    ent:SetPos(tr.HitPos + tr.HitNormal * 100)
    ent:InitModel('models/props_wasteland/cargo_container01.mdl')
    ent:InitClip(nil, nil, nil, nil, nil, 'flesh')
    ent:Spawn()
    // ent.bornTime = nil
end)

concommand.Add('domain_clear_fkm_death', function()
    for _, ent in ipairs(ents.FindByClass('fkm_death')) do
        ent:Remove()
    end
end)

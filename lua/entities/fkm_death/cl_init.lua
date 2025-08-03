include('shared.lua')

domain_materialTable = {}

local zero = Vector()
local zerof = 0.0000152587890625
local white = Color(255, 255, 255, 255)
local sectionNum = 5

function ENT:Initialize()
    self.bornTime = CurTime()
    self.emitter = ParticleEmitter(self:GetPos())
    self.emitterTimer = 0
    // self:SetRenderClipPlaneEnabled(true)
end

function ENT:UpdateClip(depth)
    depth = depth or self.currentDepth 
	local n = self:LocalToWorld(self.scanData.dir) - self:GetPos()
	local p = self:LocalToWorld(self.scanData.dir * depth)
    // self:SetRenderClipPlane(n, n:Dot(p))
    self.n = n
    self.p = n:Dot(p)
end

function ENT:UpdateSection(depth)
    depth = depth or self.currentDepth
    local ipoints = domain_FastAABBSection(self.scanData, depth)
    if #ipoints < 3 then return end
    self.currentSection = domain_3DPoints2ConvexPolygon(
        ipoints, 
        self.scanData.dir, 
        self.scanData.u, 
        self.scanData.v
    ) 
end

function ENT:ParticleEffect(depth)
    local num = 200
    local emitter = self.emitter
    local numPer = num / #self.currentSection
    local ref = self.scanData.dir
    for _, tri in pairs(self.currentSection) do 
        local p1 = tri[1]
        local l1 = tri[2] - p1
        local l2 = tri[3] - p1

        for i = 1, numPer do
            local dir = VectorRand()
            if dir:Dot(ref) < 0 then dir = -dir end

            local part = emitter:Add(
                'effects/spark', 
                self:LocalToWorld(p1 + domain_UniformTriangle(l1, l2))
            )
            if part then
                part:SetDieTime(1)

                part:SetStartAlpha(255)
                part:SetEndAlpha(0)

                part:SetStartSize(5)
                part:SetEndSize(0)

                part:SetStartLength(5)
                part:SetEndLength(0)

                part:SetGravity(VectorRand() * 100)
                part:SetVelocity(-ref * 100)
                // part:SetAngleVelocity(AngleRand() * 1)
                part:SetColor(255, 255, 255)
            end
        end
    end
end


function ENT:Think()
    if self.bornTime == nil then return end 
    local dt = 0.05
    local emitterPeriod = 0.1

    self.currentDepth = self.currentDepth + self.speed * dt
    if self.currentDepth >= self.endDepth then self:Remove() end
    // 裁剪特效
    self:UpdateClip()

    // 更新截面区域
    self:UpdateSection()

    // 粒子特效
    self.emitterTimer = self.emitterTimer + dt
    if self.emitterTimer >= emitterPeriod then
        self.emitterTimer = self.emitterTimer - emitterPeriod
        self:ParticleEffect()
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

function ENT:InitClip(dir, start, speed, mins, maxs)
    -- 初始化裁剪特效数据
    -- dir 裁剪方向 (非零向量)
    -- start 裁剪开始比例 (0-1)
    -- speed 裁剪速度 (单位/秒)
    -- mins=ModelBounds 模型最小边界 
    -- maxs=... 模型最大边界
    
    dir = (dir or -Vector(1, 1, 1)):GetNormalized()
    start = math.Clamp(start or 0, 0, 1)
    speed = math.max(speed or 100, 0)
    if dir:Dot(dir) < zerof then error('dir为零向量') end
    if mins == nil then mins, maxs = self:GetModelBounds() end

    self.scanData = domain_GetAABBScanData(mins, maxs, dir)
    self.currentDepth = start * (self.scanData.maxDepth - self.scanData.minDepth) + self.scanData.minDepth
    self.endDepth = self.scanData.maxDepth
    self.speed = speed

    self.currentSection = {}
end


local mat = CreateMaterial('phoenix_storms/wood_1', 'UnlitGeneric', {
    ['$basetexture'] = 'phoenix_storms/wood',
    ["$vertexalpha"] = 0,
    ["$vertexcolor"] = 1
})

function ENT:OnRemove()
    if self.emitter then self.emitter:Finish() end
end

function ENT:GetSectionToScreen()
    if self.currentSection == nil or #self.currentSection < 1 then return nil end
    local originPoint = self:LocalToWorld(self.currentSection[1][1]):ToScreen()
    originPoint.u = 0
    originPoint.v = 0

    local tri2d = {originPoint}
    for _, tri in pairs(self.currentSection) do
        for i = 1, 2 do
            local point = self:LocalToWorld(tri[i + 1]):ToScreen()
            point.u = math.min(1, bit.band(i, 0x01))
            point.v = math.min(1, bit.band(i, 0x02))
            tri2d[#tri2d + 1] = point
        end	
    end

    return tri2d
end

function ENT:Draw() 
    -- source引擎优化好, 经得起这种操作
    local section2D = self:GetSectionToScreen()
    // local section2D = nil
    local oldEC = render.EnableClipping(true)
    render.PushCustomClipPlane(self.n, self.p)

        render.OverrideDepthEnable(true, true)
            self:DrawModel()
        render.OverrideDepthEnable(false)

        if section2D != nil then
            render.ClearStencil() 
            render.SetStencilEnable(true)
            render.SetStencilReferenceValue(1)
            render.SetStencilCompareFunction(STENCIL_ALWAYS)
            render.SetStencilPassOperation(STENCIL_REPLACE)
            render.SetStencilFailOperation(STENCIL_KEEP)
            render.SetStencilZFailOperation(STENCIL_KEEP)

            render.CullMode(MATERIAL_CULLMODE_CW)
                self:DrawModel()
            render.CullMode(MATERIAL_CULLMODE_CCW)
        else
            render.CullMode(MATERIAL_CULLMODE_CW)
                self:DrawModel()
            render.CullMode(MATERIAL_CULLMODE_CCW)
        end

    render.PopCustomClipPlane()
    render.EnableClipping(oldEC)

    if section2D != nil then
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        cam.Start2D()
            surface.SetMaterial(mat)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawPoly(section2D)
        cam.End2D()
        render.SetStencilEnable(false)
    end
end

concommand.Add('domain_fkm_death', function(ply)
    local tr = ply:GetEyeTrace()
    local ent = tr.Entity


    local ent = ents.CreateClientside('fkm_death')
    ent:SetPos(tr.HitPos + tr.HitNormal * 50)
    ent:InitModel('models/hunter/blocks/cube2x2x2.mdl')
    ent:InitClip(nil, nil, 50)
    ent:Spawn()
    // ent.bornTime = nil
end)

concommand.Add('domain_clear_fkm_death', function()
    for _, ent in ipairs(ents.FindByClass('fkm_death')) do
        ent:Remove()
    end
end)


// local defaultEffectData = {
//     mat = 'effects/spark',
// }

// local effectDataTable = {
//     Wood = {
//         mat = 'effects/fleck_wood1',
//         sound = 'Wood.BulletImpact'
//     },

//     alienflesh = {
//         mat = 'effects/blood',
//         sound = 'fkm/gib.wav',
//         color = Color(255, 255, 0)
//     },

//     flesh = {
//         mat = 'effects/blood',
//         sound = 'fkm/gib.wav',
//         color = Color(255, 0, 0)
//     },

//     bloodyflesh = {
//         mat = 'effects/blood',
//         sound = 'fkm/gib.wav',
//         color = Color(255, 0, 0)
//     }
// }

// materialType = {
//     Special = {
//         default = true,
//         default_silent = true,
//         floatingstandable = true,
//         item = true,
//         ladder = true,
//         woodladder = true,
//         no_decal = true,
//         player = true,
//         player_control_clip = true
//     },

//     ConcreteRock = {
//         boulder = true,
//         brick = true,
//         concrete = true,
//         concrete_block = true,
//         gravel = true,
//         rock = true,
//     },

//     Metal = {
//         canister = true,
//         chain = true,
//         chainlink = true,
//         grenade = true,
//         metal = true,
//         metal_barrel = true,
//         floating_metal_barrel = true,
//         metal_bouncy = true,
//         metal_Box = true,
//         metalgrate = true,
//         metalpanel = true,
//         metalvent = true,
//         paintcan = true,
//         popcan = true,
//         roller = true,
//         slipperymetal = true,
//         solidmetal = true,
//         weapon = true,
//     },

//     Wood = {
//         wood = true,
//         wood_Box = true,
//         wood_Crate = true,
//         wood_Furniture = true,
//         wood_LowDensity = true,
//         wood_Plank = true,
//         wood_Panel = true,
//         wood_Solid = true,
//     },

//     Terrain = {
//         dirt = true,
//         grass = true,
//         mud = true,
//         quicksand = true,
//         sand = true,
//         slipperyslime = true,
//     },

//     Liquid = {
//         slime = true,
//         water = true,
//         wade = true,
//     },

//     Frozen = {
//         Ice = true,
//         Snow = true,
//     },

//     Organic = {
//         alienflesh = true,
//         armorflesh = true,
//         bloodyflesh = true,
//         flesh = true,
//         foliage = true,
//         watermelon = true,
//     },

//     Manufactured = {
//         glass = true,
//         glassbottle = true,
//         tile = true,
//         paper = true,
//         papercup = true,
//         cardboard = true,
//         plaster = true,
//         plastic_barrel = true,
//         plastic_barrel_buoyant = true,
//         plastic_Box = true,
//         plastic = true,
//         rubber = true,
//         rubbertire = true,
//         slidingrubbertire = true,
//         slidingrubbertire_front = true,
//         slidingrubbertire_rear = true,
//         jeeptire = true,
//         brakingrubbertire = true,
//         porcelain = true,
//     },

//     Miscellaneous = {
//         carpet = true,
//         ceiling_tile = true,
//         computer = true,
//         pottery = true,
//     }
// }





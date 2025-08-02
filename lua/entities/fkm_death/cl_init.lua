include('shared.lua')

domain_materialTable = {}

local zero = Vector()
local zerof = 0.0000152587890625
local white = Color(255, 255, 255, 255)
local sectionNum = 5

function ENT:Initialize()
    self.timer = 0
    self.bornTime = CurTime()
    self.emitter = ParticleEmitter(self:GetPos())
    self:SetRenderClipPlaneEnabled(true)
end

function ENT:UpdateClip(depth)
	local n = self:LocalToWorld(self.scanData.dir) - self:GetPos()
	local p = self:LocalToWorld(self.scanData.dir * depth)
    self:SetRenderClipPlane(n, n:Dot(p))
end

function ENT:ParticleEffect(depth)
    local ipoints = domain_FastAABBSection(self.scanData, depth)
    if #ipoints < 3 then return end
    local tris = domain_3DPoints2ConvexPolygon(
        ipoints, 
        self.scanData.dir, 
        self.scanData.u, 
        self.scanData.v
    ) 

    local num = 200
    local emitter = self.emitter
    local numPer = num / #tris
    local ref = self.scanData.dir
    for _, tri in pairs(tris) do 
        local p1 = tri[1]
        local l1 = tri[2] - p1
        local l2 = tri[3] - p1

        for i = 1, numPer do
            local dir = VectorRand()
            if dir:Dot(ref) < 0 then dir = -dir end

            local part = emitter:Add(
                'effects/fleck_wood1', 
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

function ENT:UpdateActiveObj(depth)
    local unit = self.depthRange / (sectionNum + 1)
    local progress = (depth - self.startDepth) / unit

    if progress > math.ceil(sectionNum * 0.5) then
        self.activeObj = self.sectionObjs[math.Clamp(math.floor(progress), 1, sectionNum)]
    else
        self.activeObj = self.sectionObjs[math.Clamp(math.ceil(progress), 1, sectionNum)]
    end
end

function ENT:Think()
    if self.bornTime == nil then return end 

    local lifetime = (CurTime() - self.bornTime) * self.speed
    local depth = self.startDepth + lifetime * self.depthRange
    if depth > self.scanData.maxDepth then self:Remove() end
    self.currentDepth = depth
    // 裁剪特效
    self:UpdateClip(depth)

    // 裁剪平面
    self:UpdateActiveObj(depth)

    // 粒子特效
    self.timer = self.timer + FrameTime()
    if self.timer >= 0.1 then
        self.timer = self.timer - 0.1
        self:ParticleEffect(depth)
    end
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
    dir = dir or -Vector(0.577, 0.577, 0.577)
    start = math.Clamp(start or 0, 0, 1)
    speed = math.max(speed or 1, 0.01)
    if dir:Dot(dir) < zerof then dir.x = 1 end
    if mins == nil then mins, maxs = self:GetModelBounds() end

    self.scanData = domain_GetAABBScanData(mins, maxs, dir)
    self.depthRange = self.scanData.maxDepth - self.scanData.minDepth
    self.startDepth = start * self.depthRange + self.scanData.minDepth
    self.speed = speed

    -- 初始化界面网格
    local unit = self.depthRange / (sectionNum + 1)
    local meshs = {}
    for i = 1, sectionNum do
        local tris = domain_GetAABBSectionTriangles(self.scanData, self.scanData.minDepth + unit * i)
        local obj = Mesh()
        local verts = {}

        for _, tri in ipairs(tris) do
            for i = 0, 2 do
                verts[#verts + 1] = {
                    pos = tri[i + 1],	
                    u = math.min(1, bit.band(i, 0x01)),
                    v = math.min(1, bit.band(i, 0x02))
                }
            end		
        end
        obj:BuildFromTriangles(verts)

        meshs[#meshs + 1] = obj
    end

    self.sectionObjs = meshs
end

local mat = CreateMaterial('phoenix_storms/stripes_1', 'UnlitGeneric', {
    ['$basetexture'] = 'phoenix_storms/stripes',
    ["$vertexalpha"] = 0,
    ["$vertexcolor"] = 1
})


function ENT:Draw()
    render.OverrideDepthEnable(true, true)
    self:DrawModel()
    render.OverrideDepthEnable(false)
    
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

        render.SetStencilCompareFunction(STENCIL_EQUAL)

        if IsValid(self.activeObj) then
            local matrix = self:GetWorldTransformMatrix()
            matrix:SetTranslation(matrix:GetTranslation() + self.scanData.dir * self.currentDepth)
            render.SetMaterial(mat)
            cam.PushModelMatrix(matrix)
            self.activeObj:Draw() 
            cam.PopModelMatrix()
        end
    render.SetStencilEnable(false)

end

function ENT:OnRemove()
    if self.emitter then self.emitter:Finish() end
end

concommand.Add('domain_fkm_death', function(ply)
    local tr = ply:GetEyeTrace()
    local ent = tr.Entity


    local ent = ents.CreateClientside('fkm_death')
    ent:SetPos(tr.HitPos + tr.HitNormal * 100)
    ent:InitModel('models/props_wasteland/cargo_container01.mdl')
    ent:InitClip(nil, nil, 0.1)
    ent:Spawn()
    // ent.bornTime = nil
end)

concommand.Add('domain_clear_fkm_death', function()
    for _, ent in ipairs(ents.FindByClass('fkm_death')) do
        ent:Remove()
    end
end)


local defaultEffectData = {
    mat = 'effects/spark',
}

local effectDataTable = {
    Wood = {
        mat = 'effects/spark',
        sound = 'Wood.BulletImpact'
    },

    alienflesh = {
        mat = 'effects/blood',
        sound = 'fkm/gib.wav',
        color = Color(255, 255, 0)
    },

    flesh = {
        mat = 'effects/blood',
        sound = 'fkm/gib.wav',
        color = Color(255, 0, 0)
    },

    bloodyflesh = {
        mat = 'effects/blood',
        sound = 'fkm/gib.wav',
        color = Color(255, 0, 0)
    }
}

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





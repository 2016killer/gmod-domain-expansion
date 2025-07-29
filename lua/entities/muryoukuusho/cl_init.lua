include('shared.lua')

function ENT:InitShells() 
    self.shells = {
        [RYOIKI_STATE_EXPAND] = {material = 'domain/white'},
        [RYOIKI_STATE_RUN] = {material = 'domain/black'},
        [RYOIKI_STATE_BREAK] = {material = 'domain/black', fadeInSpeed = 5}
    }
end

local zero = Vector()
local backgroundMat = Material('mryks/starlitsky')
local ballMat1 = Material('models/props_pipes/Pipesystem01a_skin3')
local ballMat2 = Material('models/props_foliage/tree_deciduous_01a_trunk')

function ENT:InitShellEnts()
    self.BaseClass.InitShellEnts(self)
    local shell = self.shells[RYOIKI_STATE_RUN]
    local ent = shell.ent
    ent.RenderOverride = function(self2)
        if !IsValid(self) then 
            self2:Remove()
            return
        end
        
        local progress = shell.progress or 0
        if progress < 0.05 then return end

        local ang = self.ang or 0
        ang = ang + 0.5 * FrameTime()
        self.ang = ang

        local sina = math.sin(ang)
        local cosa = math.cos(ang)

        local v1 = sina * Vector(1, 0, 0) + cosa * Vector(0, 1, 0)
        local v2 = sina * Vector(0.707, 0.707, 0) + cosa * Vector(-0.707, 0.707, 0)

        local steps = 16
        local vz = Vector(0, 0, 2)

        render.ClearStencil()
        render.SetStencilEnable(true)
            render.SetStencilWriteMask(255)
            render.SetStencilTestMask(255)
            render.SetStencilReferenceValue(2)
            render.SetStencilCompareFunction(STENCIL_ALWAYS)
            render.SetStencilPassOperation(STENCIL_REPLACE)
            render.SetStencilFailOperation(STENCIL_REPLACE)
            render.SetStencilZFailOperation(STENCIL_REPLACE)

            local oldBlend = render.GetBlend()
            render.SetBlend(progress)
            self2:DrawModel()
            

            render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
            render.SetStencilPassOperation(STENCIL_INCR)
            render.SetStencilFailOperation(STENCIL_KEEP)
            render.SetStencilZFailOperation(STENCIL_KEEP)

            render.CullMode(MATERIAL_CULLMODE_CW)
            self2:DrawModel()
            render.CullMode(MATERIAL_CULLMODE_CCW)
            
        
            render.SetStencilReferenceValue(1)
            render.SetStencilCompareFunction(STENCIL_EQUAL)
            render.SetStencilPassOperation(STENCIL_KEEP)
            render.SetStencilFailOperation(STENCIL_KEEP)
            render.SetStencilZFailOperation(STENCIL_KEEP)
    
            render.OverrideDepthEnable(true, false)
            cam.Start3D(zero, LocalPlayer():EyeAngles())
                render.SetMaterial(backgroundMat)
                render.DrawSphere(zero, 10, steps, steps)
                
                render.SetMaterial(ballMat1)
                render.DrawSphere(zero + 7 * v1, 1, steps, steps)
                render.DrawSphere(zero - 7 * v1, 1, steps, steps)
                
                render.SetMaterial(ballMat2)
                render.DrawSphere(zero + 7 * v2 + vz, 1, steps, steps)
                render.DrawSphere(zero - 7 * v2 + vz, 1, steps, steps)
            cam.End3D() 
            render.OverrideDepthEnable(false)

            render.SetBlend(oldBlend)

        
        render.SetStencilEnable(false)
    end
end

function ENT:Effect(owner, dt)
    local timer = (self.timerEffect or 0) + dt
    local emitter = IsValid(self.emitter) and self.emitter or ParticleEmitter(self:GetPos())
    local period = 0.5
    if timer >= period then
        timer = timer - period
        local radius = self.radius
        local center = self:GetPos()
        local num = math.min(500, math.max(1, math.floor(radius * 0.25)))
        local dieTime = 1

        emitter:domain_SphereSnow(
            'effects/spark', 
            radius,
            center,
            30,
            30, 
            num,
            dieTime
        )
    end
    self.emitter = emitter
    self.timerEffect = timer
end

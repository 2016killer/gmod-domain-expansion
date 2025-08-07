include('shared.lua')

local BaseClass = scripted_ents.Get(ENT.Base)
local STATE_BORN = BaseClass.STATE_BORN
local STATE_RUN = BaseClass.STATE_RUN
local STATE_BREAK = BaseClass.STATE_BREAK
BaseClass = nil
local FrameTime = FrameTime

function ENT:InitShells() 
    self.shells = {
        [STATE_BORN] = {material = 'dm/white', fadeOutSpeed = 0.5},
        [STATE_RUN] = {material = 'dm/black'},
        [STATE_BREAK] = {material = 'dm/black', fadeInSpeed = 5}
    }
end

function ENT:SetScale(scale)
    self:SetModelScale(scale) -- 确保外壳在可见集里以及能够被搜索到
    if CLIENT then
        for state, shell in pairs(self.shells) do
            if not IsValid(shell.ent) then continue end
            if state == STATE_RUN then
                shell.ent:SetModelScale(scale + 1)
            else
                shell.ent:SetModelScale(scale) 
            end
        end
    end
end

local zero = Vector()
local backgroundMat = Material('mryks/starlitsky')
local ballMat1 = Material('models/props_pipes/Pipesystem01a_skin3')
local ballMat2 = Material('models/props_foliage/tree_deciduous_01a_trunk')

function ENT:InitShellEnts()
    self.BaseClass.InitShellEnts(self)
    local shell = self.shells[STATE_RUN]
    local ent = shell.ent
    ent.RenderOverride = function(self2)
        if not IsValid(self) then 
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
            render.SetStencilReferenceValue(10)
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

function ENT:RunCall(dt)
    if not self:GetExecute() then return end
    local timer = (self.effectTimer or 0) + dt
    local emitter = IsValid(self.emitter) and self.emitter or ParticleEmitter(self:GetPos())
    local period = 0.5

    if timer >= period then
        timer = timer - period
        local radius = self.radius
        local center = self:GetPos()
        local num = math.min(200, math.max(1, math.floor(radius * 0.25)))
        local dieTime = 1

        emitter:dm_SphereSnow(
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
    self.effectTimer = timer
end

function ENT:OnRemove()
    self.BaseClass.OnRemove(self)
    if IsValid(self.emitter) then self.emitter:Finish() end
end

// ambient/energy/zap2.wav

function mryks_eyefx(action)
    if action then
        hook.Add('RenderScreenspaceEffects', 'mryks_eyefx', function()
            DrawMaterialOverlay("effects/tp_eyefx/tpeye", 0)
        end)

        local period = 0.5
        local timeCount = 0.5
        hook.Add('Think', 'mryks_eyefx', function()
            timeCount = timeCount + FrameTime()
            if timeCount >= period then
                timeCount = timeCount - period
                LocalPlayer():EmitSound('ambient/energy/zap'..math.floor(math.random(1, 3.999))..'.wav')
            end
        end)

    else
        hook.Remove('RenderScreenspaceEffects', 'mryks_eyefx')
        hook.Remove('Think', 'mryks_eyefx')
    end
end
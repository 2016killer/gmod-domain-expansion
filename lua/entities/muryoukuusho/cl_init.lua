include('shared.lua')

local zero = Vector()
local mat = Material('domain/starlitsky')

function ENT:InitShells() 
    self.shells = {
        [RYOIKI_STATE_EXPAND] = {material = 'domain/white'},
        [RYOIKI_STATE_RUN] = {material = 'domain/black'},
        [RYOIKI_STATE_BREAK] = {material = 'domain/black', fadeInSpeed = 5}
    }
end


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
        
            render.SetStencilReferenceValue(1)
            render.SetStencilCompareFunction(STENCIL_EQUAL)
            
            cam.Start3D(zero, LocalPlayer():EyeAngles())
            render.SetMaterial(mat)
            render.DrawSphere(zero, 5, 16, 16, Color(255, 255, 255))
            cam.End3D() 
            render.CullMode(MATERIAL_CULLMODE_CCW)

            render.SetBlend(oldBlend)
        render.SetStencilEnable(false)

    end
    shell.ent = ent

end

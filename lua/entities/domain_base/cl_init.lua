include('shared.lua')

function ENT:InitShells()
    -- (特性) 外壳
    -- material 材质
    -- fadeInSpeed 淡入速度
    -- fadeOutSpeed 淡出速度
    -- progress 进度
    self.shells = {
        [self.STATE_BORN] = {},
        [self.STATE_RUN] = {},
        [self.STATE_BREAK] = {}
    }
end

function ENT:InitShellEnts()
    -- (特性) 外壳渲染
    for state, shell in pairs(self.shells) do
        if IsValid(shell.ent) then continue end
        local ent = ClientsideModel('models/dav0r/hoverball.mdl')
        local material = isstring(shell.material) and shell.material or 'domain/black'
        local domain = self
        ent:SetMaterial(material)
        ent.RenderOverride = function(self)
            if not IsValid(domain) then 
                self:Remove()
                return
            end
            
            local progress = shell.progress or 0
            if progress < 0.05 then return end
            
            local oldBlend = render.GetBlend()
            render.SetBlend(progress)
            self:DrawModel()
            render.CullMode(MATERIAL_CULLMODE_CW)
            self:DrawModel()
            render.CullMode(MATERIAL_CULLMODE_CCW)
            render.SetBlend(oldBlend)
        end
        shell.ent = ent
    end
end

function ENT:Draw()
    local dt = FrameTime()
    self:SetModelScale(self.radius * 0.166)
    for state, shell in pairs(self.shells) do
        local fadeInSpeed = math.max(shell.fadeInSpeed or 1, 0)
        local fadeOutSpeed = math.max(shell.fadeOutSpeed or 1, 0)
        local progress = shell.progress or 0
        if self:GetState() == state then
            progress = progress + fadeInSpeed * dt
        else
            progress = progress - fadeOutSpeed * dt
        end
        progress = math.Clamp(progress, 0, 1)
        shell.progress = progress

        self:DrawCustomShell(state, shell, progress)
    end
end

function ENT:DrawCustomShell(state, shell, progress)
    -- (特性) 自定义外壳渲染
end

function ENT:BornCall(dt)
    -- (特性) 展开时执行
end

function ENT:RunCall(dt)
    -- (特性) 运行时执行
end

function ENT:BreakCall(dt)
    -- (特性) 失效时执行
end




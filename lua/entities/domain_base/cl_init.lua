include('shared.lua')

function ENT:InitShells()
    -- (特性) 外壳
    -- material 材质
    -- fadeInSpeed 淡入速度
    -- fadeOutSpeed 淡出速度
    -- progress 进度
    self.shells = {
        [RYOIKI_STATE_EXPAND] = {},
        [RYOIKI_STATE_RUN] = {},
        [RYOIKI_STATE_BREAK] = {}
    }
end

function ENT:InitShellEnts()
    -- (特性) 外壳渲染
    for state, shell in pairs(self.shells) do
        local ent = ClientsideModel('models/dav0r/hoverball.mdl')
        local material = isstring(shell.material) and shell.material or 'domain/black'
        ent:SetMaterial(material)
        ent:SetPos(self:GetPos())
        ent:SetAngles(Angle(-90, 0, 0))
        ent.RenderOverride = function(self2)
            if !IsValid(self) then 
                self2:Remove()
                return
            end
            
            local progress = shell.progress or 0
            if progress < 0.05 then return end
            
            local oldBlend = render.GetBlend()
            render.SetBlend(progress)
            self2:DrawModel()
            render.CullMode(MATERIAL_CULLMODE_CW)
            self2:DrawModel()
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

function ENT:OnRemove()
    for _, shell in pairs(self.shells) do
        if IsValid(shell.ent) then shell.ent:Remove() end
    end
end

function ENT:DrawCustomShell(state, shell, progress)
    -- (特性) 自定义外壳渲染
end

function ENT:Effect(owner, dt)
    -- (特性) 效果
end

function ENT:Cost(owner, dt)
    -- (特性) 消耗
end


function ENT:Expand()
    -- (特性) 展开时执行
end

function ENT:Run()
    -- (特性) 运行时执行
end

function ENT:Break()
    -- (特性) 失效时执行
end



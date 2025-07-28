include('shared.lua')

function ENT:InitShells() 
    self.shells = {
        [RYOIKI_STATE_EXPAND] = {material = 'domain/black'},
        [RYOIKI_STATE_RUN] = {material = 'Models/effects/comball_sphere', fadeOutSpeed=5},
        [RYOIKI_STATE_BREAK] = {material = 'domain/black'}
    }
end

function ENT:Effect(owner, dt)
    local timer = (self.timerEffect or 0) + dt
    local emitter = IsValid(self.emitter) and self.emitter or ParticleEmitter(self:GetPos())
    if timer >= 0.05 then
        timer = timer - 0.05
        local diameter = self.radius * 2
        local center = self:GetPos()
        local width = 30
        local unitLen = math.max(1, diameter * 0.1)
        local num = math.min(30, math.max(1, math.floor(diameter / 100)))
        local dieTime = 0.1

        fkm_LineTrailSphere(
            diameter, 
            center, 
            emitter, 
            'fkm/laserblack', 
            width, 
            unitLen, 
            num,
            dieTime
        )

        fkm_LineTrailSphere(
            diameter, 
            center, 
            emitter, 
            'fkm/laserblack2', 
            width, 
            unitLen, 
            num,
            dieTime
        )
    end
    self.emitter = emitter
    self.timerEffect = timer
end

function ENT:Run()
    local dt = FrameTime()
    local shellEnt = self.shells[RYOIKI_STATE_RUN].ent
    if IsValid(shellEnt) then shellEnt:SetAngles(shellEnt:GetAngles() + Angle(1000, 1000, 0) * dt) end
end

function ENT:Break()
    local dt = FrameTime()
    local shellEnt = self.shells[RYOIKI_STATE_RUN].ent
    if IsValid(shellEnt) then shellEnt:SetAngles(shellEnt:GetAngles() + Angle(1000, 1000, 0) * dt) end
end
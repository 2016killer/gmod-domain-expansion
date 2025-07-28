include('shared.lua')

function ENT:InitShells() 
    self.shells = {
        [RYOIKI_STATE_EXPAND] = {material = 'domain/black'},
        [RYOIKI_STATE_RUN] = {material = 'Models/effects/comball_sphere', fadeOutSpeed=5},
        [RYOIKI_STATE_BREAK] = {material = 'domain/black', fadeInSpeed = 5}
    }
end

function ENT:Effect(owner, dt)
    local timer = (self.timerEffect or 0) + dt
    local emitter = IsValid(self.emitter) and self.emitter or ParticleEmitter(self:GetPos())
    if timer >= 0.05 then
        timer = timer - 0.05
        h2d_LineTrailSphere(
            self.radius * 2, 
            self:GetPos(), 
            emitter, 
            'h2d/laserblack', 
            30, 
            math.max(1, self.radius * 0.2), 
            10,
            0.1
        )

        h2d_LineTrailSphere(
            self.radius * 2, 
            self:GetPos(), 
            emitter, 
            'h2d/laserblack2', 
            30, 
            math.max(1, self.radius * 0.2), 
            10,
            0.1
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
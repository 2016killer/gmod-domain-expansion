include('shared.lua')

function ENT:InitShells() 
    self.shells = {
        [RYOIKI_STATE_EXPAND] = {material = 'domain/black'},
        [RYOIKI_STATE_RUN] = {material = 'Models/effects/comball_sphere', fadeOutSpeed=5},
        [RYOIKI_STATE_BREAK] = {material = 'domain/black'}
    }
end

local function LaserStorm(emitter, mat, radius, center, width, unitLen, num, dieTime) 
    -- 视觉特效
    for i = 1, num do
        local dirSample = AngleRand()
        // local radiusSample = radius * math.pow(math.random(), 0.333) 
        local radiusSample = radius * math.sqrt(math.random())
        local radSample = math.random() * 6.28

        local sin = math.sin(radSample)
        local cos = math.cos(radSample)

        local lineCenter = center + dirSample:Forward() * radiusSample
        local lineDir = dirSample:Up() * sin + dirSample:Right() * cos
        local lineLen = math.sqrt(radius * radius - radiusSample * radiusSample)

        emitter:domain_LaserTrail(
                mat, 
                lineCenter + lineDir * lineLen,
                lineCenter - lineDir * lineLen,
                width,
                unitLen,
                dieTime
        )

    end
end

function ENT:Impact(owner, dt)
    local timer = (self.effectTimer or 0) + dt
    local emitter = IsValid(self.emitter) and self.emitter or ParticleEmitter(self:GetPos())
    local period = 0.05

    if timer >= period then
        timer = timer - period
        local radius = self.radius
        local center = self:GetPos()
        local unitLen = math.max(1, radius * 0.1)
        local num = math.min(30, math.max(1, math.floor(radius / 10)))
        local dieTime = 0.1

        LaserStorm(
            emitter, 
            'fkm/laserblack',
            radius, 
            center, 
            30,
            unitLen, 
            num, 
            dieTime
        )

        LaserStorm(
            emitter, 
            'fkm/laserblack2',
            radius, 
            center, 
            30,
            unitLen, 
            num, 
            dieTime
        )

        if self:Cover(LocalPlayer()) then
            self.soundID = LocalPlayer():StartLoopingSound('fkm/laserstorm.wav')
        else
            if self.soundID then LocalPlayer():StopLoopingSound(self.soundID) end
        end
    end

    self.emitter = emitter
    self.effectTimer = timer
end



concommand.Add('fkm_debug_laser_storm', function(ply)
    local tr = ply:GetEyeTrace()
    local radius = 5000
    local center = tr.HitPos

    local emitter = ParticleEmitter(Vector())
    
    LaserStorm(
        emitter, 
        'fkm/laserblack',
        radius, 
        center, 
        30,
        radius * 0.1, 
        100, 
        5
    )

    emitter:Finish()
end)


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

function ENT:OnRemove()
    self.BaseClass.OnRemove(self)
    if IsValid(self.emitter) then self.emitter:Finish() end
    if self.soundID then LocalPlayer():StopLoopingSound(self.soundID) end
end
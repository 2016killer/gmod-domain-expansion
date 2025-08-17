include('shared.lua')

local BaseClass = scripted_ents.Get(ENT.Base)
local STATE_BORN = BaseClass.STATE_BORN
local STATE_RUN = BaseClass.STATE_RUN
local STATE_BREAK = BaseClass.STATE_BREAK
BaseClass = nil

function ENT:InitShells() 
    self.shells = {
        [STATE_BORN] = {material = 'dm/black'},
        [STATE_RUN] = {material = 'Models/effects/comball_sphere', fadeOutSpeed=5},
        [STATE_BREAK] = {material = 'dm/black'}
    }
end

function ENT:RunCall(dt)
    if self:GetExecute() then 
        self:LaserStormEffect(dt)
        self:flashEffect(dt)
        self:SoundEffect(dt, true)
        self:ShellRotate(dt)
    else
        self:SoundEffect(dt, false)
    end
end

local fkm_particle_level = CreateClientConVar('fkm_particle_level', '0.5', true, false)
function ENT:LaserStormEffect(dt)
   -- 激光雨特效
   local period = 0.05
    self.effectTimer = (self.effectTimer or 0) + dt
    if self.effectTimer >= period then
        self.effectTimer = self.effectTimer - period

        local radius = self.radius
        local center = self:GetPos()
        local unitLen = math.max(1, radius * math.Clamp(1 - fkm_particle_level:GetFloat(), 0.1, 1))
        local num = 40
        local width = 30
        local dieTime = 0.1

        self.emitter = self.emitter or ParticleEmitter(center)
        local emitter = self.emitter

        for i = 1, num do
            local dirSample = AngleRand()
            // local radiusSample = radius * math.pow(math.random(), 0.333) 
            local radiusSample = radius * math.sqrt(math.random())
            local radSample = math.random() * 6.28

            local sin = math.sin(radSample)
            local cos = math.sqrt(1 - sin * sin) * (math.random() > 0.5 and 1 or -1)

            local lineCenter = center + dirSample:Forward() * radiusSample
            local lineDir = dirSample:Up() * sin + dirSample:Right() * cos
            local lineLen = math.sqrt(radius * radius - radiusSample * radiusSample)

            self.emitter:dm_LaserTrail(
                    math.random() > 0.5 and 'fkm/laserblack' or 'fkm/laserblack2', 
                    lineCenter + lineDir * lineLen,
                    lineCenter - lineDir * lineLen,
                    width,
                    unitLen,
                    dieTime
            )

        end
    end
end

local fkm_flash = CreateClientConVar('fkm_flash', '0', true, false)
function ENT:flashEffect(dt)
   -- 闪光特效
    local period = 1

    self.flashTimer = (self.flashTimer or 0.5) + dt
    if self.flashTimer >= period then
        self.flashTimer = self.flashTimer - period
        if not fkm_flash:GetBool() then return end

        local radius = self.radius * 4
        local center = self:GetPos()
        local dieTime = 1

        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = center
            dlight.r = 255
            dlight.g = 255
            dlight.b = 255
            dlight.brightness = 2
            dlight.decay = 1000
            dlight.size = radius
            dlight.dietime = CurTime() + dieTime
        end
    end
end

local soundDuration = SoundDuration('fkm/laserstorm.wav')
function ENT:SoundEffect(dt, play)
   -- 音效
    if play then
        self.soundTimer = (self.soundTimer or soundDuration) + dt
        if self.soundTimer >= soundDuration then
            self.soundTimer = self.soundTimer - soundDuration
            self:EmitSound('fkm/laserstorm.wav', 511)
        end
    else
        self:StopSound('fkm/laserstorm.wav')
        self.soundTimer = soundDuration
    end
end

function ENT:ShellRotate(dt)
    local shellEnt = self.shells[STATE_RUN].ent
    if IsValid(shellEnt) then shellEnt:SetAngles(shellEnt:GetAngles() + Angle(1000, 1000, 0) * dt) end
end

function ENT:OnRemove()
    self.BaseClass.OnRemove(self)
    if IsValid(self.emitter) then self.emitter:Finish() end
    self:SoundEffect(0, false)
end

function ENT:PlayShell(matType, duration)
    self.shells[STATE_RUN].ent = self:CreateShell(matType, duration)
end
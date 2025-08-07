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
        self:SoundEffect(dt, true)
        self:ShellRotate(dt)
    else
        self:SoundEffect(dt, false)
    end
end

function ENT:LaserStormEffect(dt)
   -- 激光雨特效
    local period = 0.05
    local radius = self.radius
    local center = self:GetPos()
    local unitLen = math.max(1, radius * 0.2)
    local num = 40
    local width = 30
    local dieTime = 0.1
    self.effectTimer = (self.effectTimer or 0) + dt
    self.emitter = self.emitter or ParticleEmitter(center)
    local emitter = self.emitter

    if self.effectTimer >= period then
        self.effectTimer = self.effectTimer - period

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


hook.Add('CreateClientsideRagdoll', 'fkm_kill_anim', function(entity, ragdoll)

    // for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
    //     local phy = ragdoll:GetPhysicsObjectNum(i)
    //     phy:EnableGravity(false)
    // end

    // ragdoll:SetRenderMode(RENDERMODE_TRANSCOLOR)
    // ragdoll:SetColor(Color(0, 0, 0, 0))
    // ragdoll:fkmd_Play('flesh', true)
end)
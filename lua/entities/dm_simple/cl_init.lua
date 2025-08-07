include('shared.lua')

local BaseClass = scripted_ents.Get(ENT.Base)
local STATE_BORN = BaseClass.STATE_BORN
local STATE_RUN = BaseClass.STATE_RUN
local STATE_BREAK = BaseClass.STATE_BREAK
BaseClass = nil

function ENT:InitShells()
    self.shells = {
        [STATE_BORN] = {material = 'dm/white'},
        [STATE_RUN] = {material = 'Models/effects/comball_tape'},
        [STATE_BREAK] = {material = 'dm/white'}
    }
end

function ENT:InitShellEnts()
    self.BaseClass.InitShellEnts(self)
    self.shells[STATE_RUN].ent:SetAngles(Angle(-90, 0, 0))
end


function ENT:RunCall(dt)
    if self:GetExecute() then 
        self:SoundEffect(dt, true)
    else
        self:SoundEffect(dt, false)
    end
end

local soundDuration = SoundDuration('items/smallmedkit1.wav')
function ENT:SoundEffect(dt, play)
   -- 音效
    if play then
        self.soundTimer = (self.soundTimer or soundDuration) + dt
        if self.soundTimer >= soundDuration then
            self.soundTimer = self.soundTimer - soundDuration
            self:EmitSound('items/smallmedkit1.wav')
        end
    else
        self:StopSound('items/smallmedkit1.wav')
        self.soundTimer = soundDuration
    end
end



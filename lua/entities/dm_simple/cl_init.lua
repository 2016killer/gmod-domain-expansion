include('shared.lua')

local BaseClass = scripted_ents.Get(ENT.Base)
local STATE_BORN = BaseClass.STATE_BORN
local STATE_RUN = BaseClass.STATE_RUN
local STATE_BREAK = BaseClass.STATE_BREAK
BaseClass = nil

function ENT:InitShells()
    self.shells = {
        [STATE_BORN] = {material = 'dm/white', fadeOutSpeed = 2},
        [STATE_RUN] = {material = 'Models/effects/comball_tape'},
        [STATE_BREAK] = {material = 'dm/white'}
    }
end




include('shared.lua')

function ENT:InitShells()
    self.shells = {
        [RYOIKI_STATE_EXPAND] = {material = 'domain/white'},
        [RYOIKI_STATE_RUN] = {material = 'models/props_combine/portalball001_sheet'},
        [RYOIKI_STATE_BREAK] = {material = 'domain/white'}
    }
end


function ENT:Impact(owner, dt)
    local timer = self.effectTimer or 0
    local period = 1
    timer = timer + dt
    if timer > period then
        timer = timer - period
        if self:Cover(LocalPlayer()) then 
            LocalPlayer():EmitSound('items/smallmedkit1.wav')
        end
    end
    self.effectTimer = timer
end

include('shared.lua')

function ENT:InitShells()
    self.shells = {
        [DOMAIN_STATE_BORN] = {material = 'domain/white'},
        [DOMAIN_STATE_RUN] = {material = 'models/props_combine/portalball001_sheet'},
        [DOMAIN_STATE_BREAK] = {material = 'domain/white'}
    }
end

function ENT:InitShellEnts()
    self.BaseClass.InitShellEnts(self)
    self.shells[DOMAIN_STATE_RUN].ent:SetAngles(Angle(-90, 0, 0))
end


function ENT:Run(dt)
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

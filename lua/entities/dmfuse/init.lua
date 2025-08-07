AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Use(activator, caller)
    if activator:IsPlayer() then
        local fusingTime = activator:GetNWFloat('FusingTime')
        if fusingTime > CurTime() then
            activator:SetNWFloat('FusingTime', CurTime())
            self:EmitSound('hl1/fvox/bell.wav')
            self:Remove()
        else
            self:EmitSound('hl1/fvox/blip.wav')
        end
    end
end

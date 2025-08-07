ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'

ENT.PrintName = 'Fuse'
ENT.Category = 'Domain'
ENT.Author = 'Zack'
ENT.Spawnable = true



function ENT:Initialize()
    self:SetModel('models/props_lab/jar01a.mdl')
    
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if (IsValid(phys)) then
        phys:Wake()
    end
end



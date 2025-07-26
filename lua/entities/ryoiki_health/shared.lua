ENT.Type = 'anim'
ENT.Base = 'ryoiki_base'

ENT.ClassName = 'ryoiki_health'
ENT.PrintName = 'Ryoiki Health'
ENT.Category = 'ryoiki'
ENT.Spawnable = true

function ENT:Run(ents)
    -- 领域效果
    if SERVER then
        for _, ent in ipairs(ents) do
            if ent:IsPlayer() or ent:IsNPC() then
                ent:SetHealth(ent:Health() + 30)
                ent:EmitSound("items/smallmedkit1.wav")
            end
        end
    end
end




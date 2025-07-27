ENT.Type = 'anim'
ENT.Base = 'domain_base'

ENT.ClassName = 'domain_health'
ENT.PrintName = 'Domain Health'
ENT.Category = 'domain'
ENT.Spawnable = true

function ENT:Run(owner, ents, dt)
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


function ENT:Initialize() 
    self.BaseClass.Initialize(self)
    if CLIENT then
        self.shells = {
            [RYOIKI_STATE_EXPAND] = {
                extMaterial = 'domain/black',
                intMaterial = 'domain/black',
    
                progress = 0
            },
            [RYOIKI_STATE_RUN] = {
                extMaterial = 'models/props_combine/tprings_globe',
                intMaterial = 'models/props_combine/portalball001_sheet',
    
                progress = 0
            }
            ,
            [RYOIKI_STATE_BREAK] = {
                extMaterial = 'domain/black',
                intMaterial = 'domain/black',
                fadeInSpeed = 5,
                progress = 0
            }
        }
    end
end




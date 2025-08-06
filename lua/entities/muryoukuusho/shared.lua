ENT.Type = 'anim'
ENT.Base = 'domain_base'

ENT.ClassName = 'muryoukuusho'
ENT.PrintName = 'Muryoukuusho' 
ENT.Category = 'Domain'
ENT.Spawnable = true


if CLIENT then
    local phrase = language.GetPhrase

    hook.Add('PopulateToolMenu', 'fkm', function()
        spawnmenu.AddToolMenuOption('Utilities', 
            phrase('fkm.menu.category'),
            'fkm', 
            phrase('fkm.menu.name'), '', '', 
            function(panel)
                panel:Clear()
   
                panel:NumSlider(phrase('fkm.var.ka'), 'fkm_ka', 0, 50, 3)
                panel:Help(phrase('fkm.help.ka'))
                panel:NumSlider(phrase('fkm.var.kh'), 'fkm_kh', 0, 50, 3)
                panel:Help(phrase('fkm.help.kh'))
            end
        )
    end)
end

local fkm_ka = CreateConVar('fkm_ka', '2.5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local fkm_kh = CreateConVar('fkm_kh', '5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

if SERVER then
    function ENT:Cost(radius, dt)
        return fkm_ka:GetFloat() * radius * radius * 0.00390625 * dt, fkm_kh:GetFloat() * dt
    end

end
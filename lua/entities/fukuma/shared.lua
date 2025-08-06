ENT.Type = 'anim'
ENT.Base = 'domain_base'

ENT.ClassName = 'fukuma'
ENT.PrintName = 'Fukuma' 
ENT.Category = 'Domain'
ENT.Spawnable = true

CreateConVar('fkm_ka', '2.5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('fkm_kh', '5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('fkm_damage', '100', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

if CLIENT then
    local phrase = language.GetPhrase

    hook.Add('PopulateToolMenu', 'fkm_menu', function()
        spawnmenu.AddToolMenuOption('Utilities', 
            phrase('fkm.menu.category'),
            'fkm_menu', 
            phrase('fkm.menu.name'), '', '', 
            function(panel)
                panel:Clear()
   
                panel:NumSlider(phrase('fkm.var.ka'), 'fkm_ka', 0, 50, 3)
                panel:Help(phrase('fkm.help.ka'))
                panel:NumSlider(phrase('fkm.var.kh'), 'fkm_kh', 0, 50, 3)
                panel:Help(phrase('fkm.help.kh'))
                panel:NumSlider(phrase('fkm.var.damage'), 'fkm_damage', 0, 5000, 3)
        
            end
        )
    end)
end



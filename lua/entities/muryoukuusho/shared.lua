ENT.Type = 'anim'
ENT.Base = 'domain_base'

ENT.ClassName = 'muryoukuusho'
ENT.PrintName = 'Muryoukuusho' 
ENT.Category = 'Domain'
ENT.Spawnable = true


CreateConVar('mryks_ka', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('mryks_damage', '200', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('mryks_damage_brain', '10', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('mryks_sleep_max', '60', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })


if CLIENT then
    local phrase = language.GetPhrase

    hook.Add('PopulateToolMenu', 'mryks_menu', function()
        spawnmenu.AddToolMenuOption('Utilities', 
            phrase('mryks.menu.category'),
            'mryks_menu', 
            phrase('mryks.menu.name'), '', '', 
            function(panel)
                panel:Clear()
   
                panel:NumSlider(phrase('mryks.var.ka'), 'mryks_ka', 0, 50, 3)
                panel:Help(phrase('mryks.help.ka'))
                panel:NumSlider(phrase('mryks.var.damage'), 'mryks_damage', 0, 5000, 3)
                panel:Help(phrase('mryks.help.damage'))
                panel:NumSlider(phrase('mryks.var.damage_brain'), 'mryks_damage_brain', 0, 50, 3)
                panel:Help(phrase('mryks.help.damage_brain'))
                panel:NumSlider(phrase('mryks.var.sleep_max'), 'mryks_sleep_max', 0, 120, 3)
            end
        )
    end)
end


if SERVER then

end
ENT.Type = 'anim'
ENT.Base = 'dm_base'

ENT.ClassName = 'dm_health'
ENT.PrintName = 'Health'
ENT.Category = 'Domain'
ENT.Author = 'Zack'
ENT.Spawnable = true

CreateConVar('dm_health_ka', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_health_damage', '10', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

if CLIENT then
    local phrase = language.GetPhrase

    hook.Add('PopulateToolMenu', 'dm_health_menu', function()
        spawnmenu.AddToolMenuOption('Utilities', 
            phrase('dm.menu.category'),
            'dm_health_menu', 
            phrase('dm.menu.health.name'), '', '', 
            function(panel)
                panel:Clear()
                local ctrl = vgui.Create('ControlPresets', panel)
			    ctrl:SetPreset('dm_health_menu')
                    ctrl:AddConVar('dm_health_ka')
                    ctrl:AddConVar('dm_health_damage')
                panel:AddPanel(ctrl)

                panel:NumSlider(phrase('dm.var.health_ka'), 'dm_health_ka', 0, 10, 0)
                panel:Help(phrase('dm.help.health_ka'))
                panel:NumSlider(phrase('dm.var.health_damage'), 'dm_health_damage', 0, 100, 0)
            end
        )
    end)
end
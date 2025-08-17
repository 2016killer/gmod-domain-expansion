CreateConVar('dm_armor_condition', '20', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_health_condition', '20', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_expand_speed', '500', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_threat', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_threat_range', '1000', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_minr', '200', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_ft', '60', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_cdamage', '20', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_rcost', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateClientConVar('dm_sensitivity', '500', true, false)
CreateClientConVar('dm_start_anim', 'dhblink', true, false)
CreateClientConVar('dm_execute_anim', 'dhblink', true, false)
CreateClientConVar('dm_break_anim', 'dhwindblast', true, false)

local version = '1.0.4'

if CLIENT then
	local phrase = language.GetPhrase

	hook.Add('PopulateToolMenu', 'dm_menu_base', function()
		spawnmenu.AddToolMenuOption('Utilities', 
			phrase('dm.menu.category'),
			'dm_menu_base', 
			phrase('dm.menu.name'), '', '', 
			function(panel)
				panel:Clear()
                local ctrl = vgui.Create('ControlPresets', panel)
			    ctrl:SetPreset('dm_menu_base')
				    ctrl:AddConVar('dm_armor_condition')
                    ctrl:AddConVar('dm_health_condition')
                    ctrl:AddConVar('dm_expand_speed')
                    ctrl:AddConVar('dm_threat')
                    ctrl:AddConVar('dm_threat_range')
					ctrl:AddConVar('dm_minr')
					ctrl:AddConVar('dm_ft')
					ctrl:AddConVar('dm_cdamage')
					ctrl:AddConVar('dm_rcost')
				panel:AddPanel(ctrl)
				
				panel:Help('---------'..phrase('dm.server')..'---------')
				panel:NumSlider(phrase('dm.var.armor_condition'), 'dm_armor_condition', 0, 200, 0)
				panel:NumSlider(phrase('dm.var.health_condition'), 'dm_health_condition', 0, 200, 0)
				panel:NumSlider(phrase('dm.var.expand_speed'), 'dm_expand_speed', 50, 5000, 0)
				panel:NumSlider(phrase('dm.var.minr'), 'dm_minr', 0, 500, 0)
				panel:NumSlider(phrase('dm.var.ft'), 'dm_ft', 0, 360, 0)
				panel:NumSlider(phrase('dm.var.cdamage'), 'dm_cdamage', 0, 100, 0)
				panel:NumSlider(phrase('dm.var.rcost'), 'dm_rcost', 0, 10, 0)

				panel:CheckBox(phrase('dm.var.threat'), 'dm_threat')
				panel:NumSlider(phrase('dm.var.threat_range'), 'dm_threat_range', 0, 5000, 0)
				panel:Help('---------'..phrase('dm.client')..'---------')
				panel:NumSlider(phrase('dm.var.sensitivity'), 'dm_sensitivity', 50, 500, 0)
				panel:TextEntry(phrase('dm.var.start_anim'), 'dm_start_anim')
				panel:TextEntry(phrase('dm.var.execute_anim'), 'dm_execute_anim')
				panel:TextEntry(phrase('dm.var.break_anim'), 'dm_break_anim')
			end
		)
	end)

	concommand.Add('dm_version', function()
		print('版本:'..version)
	end)
end





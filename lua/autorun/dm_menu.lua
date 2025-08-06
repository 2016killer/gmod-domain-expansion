
CreateConVar('dm_armor_condition', '20', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_health_condition', '20', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_expand_speed', '500', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_threat', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_threat_range', '1000', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_minr', '200', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_ft', '60', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_cdamage', '5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_rcost', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateClientConVar('dm_sensitivity', '500', true, false)

if CLIENT then
	local phrase = language.GetPhrase

	hook.Add('PopulateToolMenu', 'dm_menu_base', function()
		spawnmenu.AddToolMenuOption('Utilities', 
			phrase('dm.menu.category'),
			'dm_menu_base', 
			phrase('dm.menu.name'), '', '', 
			function(panel)
				panel:Clear()
				panel:Help('---------'..phrase('dm.server')..'---------')
				panel:NumSlider(phrase('dm.var.armor_condition'), 'dm_armor_condition', 0, 200, 0)
				panel:NumSlider(phrase('dm.var.health_condition'), 'dm_health_condition', 0, 200, 0)
				panel:NumSlider(phrase('dm.var.expand_speed'), 'dm_expand_speed', 50, 2000, 3)
				panel:NumSlider(phrase('dm.var.minr'), 'dm_minr', 0, 500, 0)
				panel:NumSlider(phrase('dm.var.ft'), 'dm_ft', 0, 360, 0)
				panel:NumSlider(phrase('dm.var.cdamage'), 'dm_cdamage', 0, 10, 0)
				panel:NumSlider(phrase('dm.var.rcost'), 'dm_rcost', 0, 10, 0)

				panel:CheckBox(phrase('dm.var.threat'), 'dm_threat')
				panel:NumSlider(phrase('dm.var.threat_range'), 'dm_threat_range', 0, 5000, 0)
				panel:Help('---------'..phrase('dm.client')..'---------')
				panel:NumSlider(phrase('dm.var.sensitivity'), 'dm_sensitivity', 50, 500, 0)
			end
		)
	end)
end





CreateConVar('fkmd_nogravity', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateClientConVar('fkmd_ragdoll_limit', '20', true, false)
CreateClientConVar('fkmd_ent_limit', '20', true, false)

if CLIENT then
	local phrase = language.GetPhrase
	hook.Add('PopulateToolMenu', 'fkmd_menu', function()
		spawnmenu.AddToolMenuOption('Utilities', 
			phrase('fkmd.menu.category'),
			'fkmd_menu', 
			phrase('fkmd.menu.name'), '', '', 
			function(panel)
				panel:Clear()
				panel:CheckBox(phrase('fkmd.var.nogravity'), 'fkmd_nogravity')
				panel:NumSlider(phrase('fkmd.var.ragdoll_limit'), 'fkmd_ragdoll_limit', 0, 100, 0)
                panel:NumSlider(phrase('fkmd.var.ent_limit'), 'fkmd_ent_limit', 0, 100, 0)
            end
		)
	end)
end

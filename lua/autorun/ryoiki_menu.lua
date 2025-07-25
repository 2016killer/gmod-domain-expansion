CreateConVar('ryoiki_ke', '0.1', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('ryoiki_kd', '0.1', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('ryoiki_prethreat', '1', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('ryoiki_threat', '1', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateClientConVar('ryoiki_measure_sensitivity', '200', true, true)

if CLIENT then
	local lang = {
		category = {'Jujutsu Ryoiki', '领域'},
		name = {'base', '基础'},
		ke = {'energy cost factor', '能量消耗系数'},
		kd = {'health decay factor', '血量衰减系数'},
		prethreat = {'pre start threat', '预启动威胁'},
		threat = {'start threat', '启动威胁'},
		measure_sensitivity = {'measurer sensitivity', '测量灵敏度'},
		client = {'client', '客户端'},
		server = {'server', '服务器'}
	}
	
	local lang_type = GetConVar('cl_language'):GetString() == 'schinese' and 2 or 1
	local lang_parse = function(key)
		local value = lang[key]
		if value then
			return type(value) ~= "table" and value or lang[key][lang_type]
		else
			return 'err:'..key
		end
	end

	hook.Add('PopulateToolMenu', 'ryoiki', function()
		spawnmenu.AddToolMenuOption('Utilities', lang_parse('category'), 'ryoiki', lang_parse('name'), '', '', function(panel)
			panel:Clear()
			panel:Help('---------'..lang_parse('server')..'---------')
			panel:NumSlider(lang_parse('ke'), 'ryoiki_ke', 1, 20, 3)
			panel:NumSlider(lang_parse('kd'), 'ryoiki_kd', 1, 20, 3)
			panel:CheckBox(lang_parse('prethreat'), 'ryoiki_prethreat')
			panel:CheckBox(lang_parse('threat'), 'ryoiki_threat')
			panel:Help('---------'..lang_parse('client')..'---------')
			panel:NumSlider(lang_parse('measure_sensitivity'), 'ryoiki_measure_sensitivity', 50, 500, 0)
		end)
	end)
end





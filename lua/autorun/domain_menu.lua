CreateConVar('domain_ke', '0.1', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('domain_kd', '0.1', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('domain_expand_speed', '500', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('domain_prethreat', '1', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('domain_threat', '1', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateClientConVar('domain_measure_sensitivity', '200', true, true)

if CLIENT then
	local lang = {
		category = {'Jujutsu Domain', '领域'},
		name = {'base', '基础'},
		ke = {'energy cost factor', '能量消耗系数'},
		kd = {'health decay factor', '血量衰减系数'},
		expand_speed = {'expand speed', '扩展速度'},
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

	hook.Add('PopulateToolMenu', 'domain', function()
		spawnmenu.AddToolMenuOption('Utilities', lang_parse('category'), 'domain', lang_parse('name'), '', '', function(panel)
			panel:Clear()
			panel:Help('---------'..lang_parse('server')..'---------')
			panel:NumSlider(lang_parse('ke'), 'domain_ke', 1, 20, 3)
			panel:NumSlider(lang_parse('kd'), 'domain_kd', 1, 20, 3)
			panel:NumSlider(lang_parse('expand_speed'), 'domain_expand_speed', 50, 2000, 3)
			panel:CheckBox(lang_parse('prethreat'), 'domain_prethreat')
			panel:CheckBox(lang_parse('threat'), 'domain_threat')
			panel:Help('---------'..lang_parse('client')..'---------')
			panel:NumSlider(lang_parse('measure_sensitivity'), 'domain_measure_sensitivity', 50, 500, 0)
		end)
	end)
end





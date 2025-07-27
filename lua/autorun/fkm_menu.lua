if CLIENT then
	local lang = {
		category = {'Jujutsu Domain', '咒术回战-领域'},
		name = {'fukuma mizushi', '伏魔御厨子'}
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


end





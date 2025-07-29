if CLIENT then
    local EMITTER = FindMetaTable('CLuaEmitter')
	local zero = Vector()
	local function IsZero(v) return v.x == 0 and v.y == 0 and v.z == 0 end

    EMITTER.domain_LaserTrail = function(self, mat, startPos, endPos, width, unitLen, dieTime)
		-- 创建激光尾迹
		-- mat 材质名
		-- startPos 起点
		-- endPos 终点
		-- width 宽度
		-- unitLen 单位长度
		-- dieTime 存活时间
		if width == 0 or unitLen == 0 or dieTime == 0 then return end
    
		local dvec = endPos - startPos
		if IsZero(dvec) then return end

		local num = dvec:Length() / unitLen
        local dieTimeUnit = math.min(dieTime / num, dieTime)
        local step = dvec / num
        
        local offset = Vector()
        local vel = dvec:GetNormalized()
        local range = math.floor(num) + 1
		for i = 1, range do 
            if i == range then unitLen = unitLen * (num - math.floor(num)) end

			local part = self:Add(mat, startPos + offset) 	
			if part then
				part:SetDieTime(math.max(i * dieTimeUnit, 0.01)) 

				part:SetStartAlpha(255) 
				part:SetEndAlpha(255)

				part:SetStartSize(width) 
				part:SetEndSize(0) 

				part:SetStartLength(unitLen)
				part:SetEndLength(unitLen)

				part:SetGravity(zero) 
				part:SetVelocity(vel)		
			end

            offset = offset + step

		end
    end

    local temp
	concommand.Add('domain_debug_laser_trail', function(ply)
		local pos = ply:GetEyeTrace().HitPos
		if isvector(temp) then
			local emitter = ParticleEmitter(zero)
            
            emitter:domain_LaserTrail(
                'models/wireframe', 
                temp,
                pos,
                30,
                100,
                1
            )

			print((temp - pos):Length())
			debugoverlay.Line(temp, pos, 5, Color(255, 0, 0), true)
			temp = nil
			emitter:Finish()
		else
            temp = pos
		end
	end)

    EMITTER.domain_SphereSnow = function(self, mat, radius, center, width, lenth, num, dieTime)
		-- 在指定球体内创建雪花
		-- radius 半径
		-- center 中心
		-- mat 材质
		-- width 宽度
        -- lenth 长度
		-- num 数量
		-- dieTime 消亡时间
	
		for i = 1, num do 
			local dirSample = VectorRand()
			local radiusSample = radius * math.pow(math.random(), 0.333) 
			local part = self:Add(mat, center + dirSample * radiusSample) 
			if part then
				part:SetDieTime(dieTime) 

				part:SetStartAlpha(255) 
				part:SetEndAlpha(0)

				part:SetStartSize(width) 
				part:SetEndSize(0) 

                part:SetStartLength(lenth)
				part:SetEndLength(0)

				part:SetGravity(zero) 
				part:SetVelocity(VectorRand() * 50)	
				
				part:SetAngleVelocity(AngleRand() * 0.1)
			end
		end
	end

	concommand.Add('domain_debug_sphere_snow', function(ply)
		local tr = ply:GetEyeTrace()
		local radius = 500
		local center = tr.HitPos + tr.HitNormal * radius
   
        local emitter = ParticleEmitter(zero)
        
        emitter:domain_SphereSnow(
            'models/wireframe', 
            radius,
            center,
            30,
            30, 
            500,
            5
        )
        
		emitter:Finish()
	end)
end


if SERVER then
    util.AddNetworkString('domain_expand')

    net.Receive('domain_expand', function(len, ply)
        print(ply)
        // local center = ply:GetPos()
        // local entity = ents.Create('fukuma_mizushi')
        // entity:SetPos(center)
        // entity:SetAngles(Angle(0, 0, 0))
        // entity:Spawn()
        // entity:SetOwner(ply)
        // print(entity:GetOwner())
        // print(entity:GetNWEntity('owner'))
        // return self:GetNWEntity('owner')
    end)
end




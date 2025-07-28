if CLIENT then
	local zero = Vector()

	local function IsZero(v) return v.x == 0 and v.y == 0 and v.z == 0 end

	function fkm_LineTrail(emitter, mat, startPos, endPos, width, unitLen, dieTime)
		-- 创建直线尾迹
		-- mat 材质名
		-- startPos 起点
		-- endPos 终点
		-- width 宽度
		-- unitLen 单位长度

		-- dieTime 死亡时间
		-- emitter 发射器

		// 边界
		if width <= 0 or unitLen <= 0 or dieTime <= 0 then 
			return 
		end
		local lineDir = endPos - startPos
		if IsZero(lineDir)then return end


		local range = math.floor(lineDir:Length() / unitLen) + 1
		local dieTimeUnit = dieTime / range
		
		lineDir:Normalize()
		for i = 1, range do 
			local part = emitter:Add(mat, startPos + lineDir * unitLen * i) 	
			if part then
				part:SetDieTime(math.max((i * dieTimeUnit), 0.01)) 

				part:SetStartAlpha(255) 
				part:SetEndAlpha(255)

				part:SetStartSize(width) 
				part:SetEndSize(0) 

				part:SetStartLength(unitLen)
				part:SetEndLength(unitLen)

				part:SetGravity(zero) 
				part:SetVelocity(lineDir)		
			end
		end
	end


	function fkm_LineTrailSphere(diameter, center, emitter, mat, width, unitLen, num, dieTime)
		-- 在指定区域创建随机直线尾迹
		-- diameter, center 直径，中心
		-- emitter=ParticleEmitter(zero) 发射器
		-- mat 材质
		-- width 宽度
		-- unitLen 单位长度
		-- num 数量
		
		local needFinish = emitter == nil
		emitter = emitter or ParticleEmitter(zero)
		dieTime = dieTime or 0.25

		local lineLen = diameter * 0.5
		for i = 1, num do
			local lineCenter = center + VectorRand() * diameter * 0.25
			local lineDir = VectorRand()


			fkm_LineTrail(emitter, mat, 
				lineCenter - lineDir * lineLen, 
				lineCenter + lineDir * lineLen, 
				width, 
				unitLen, 
				dieTime)
		end

		if needFinish then emitter:Finish() end
	end


	local startPos
	concommand.Add('fkm_debug_line_trail', function(ply)
		local pos = ply:GetEyeTrace().HitPos
		if startPos == nil then
			startPos = pos
		else
			local emitter = ParticleEmitter(Vector())
			fkm_LineTrail(emitter, 'models/wireframe', startPos, pos, 30, 10, 0.5)
			print((startPos - pos):Length())
			debugoverlay.Line(startPos, pos, 5, Color(255, 0, 0), true)
			startPos = nil
			emitter:Finish()
		end
	end)

	concommand.Add('fkm_debug_line_trail_sphere', function(ply)
		local tr = ply:GetEyeTrace()
		local radius = 5000
		local center = tr.HitPos + tr.HitNormal * 125

		fkm_LineTrailSphere(radius, center, nil, 'fkm/laserblack', 30, 500, 50)
		fkm_LineTrailSphere(radius, center, nil, 'fkm/laserblack2', 30, 500, 50)
	end)




end








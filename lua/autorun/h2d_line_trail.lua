if CLIENT then
	local zero = Vector()

	local function IsZero(v) return v.x == 0 and v.y == 0 and v.z == 0 end

	function h2d_LineTrail(emitter, mat, startPos, endPos, width, unitLen, dieTime)
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


	function h2d_LineTrailSphere(diameter, center, emitter, mat, width, unitLen, num, dieTime)
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

			h2d_LineTrail(emitter, mat, lineCenter - lineDir * lineLen, lineCenter + lineDir * lineLen, 
				width, 
				unitLen, 
				dieTime)
		end
		

		if needFinish then emitter:Finish() end
	end

	local bladestorm_data = {}

	
	function h2d_bladestorm_effect(diameter, center, mat, width, unitLen, duration, period, numPer)
		-- 创建剑刃风暴特效	
		mat = mat or 'h2d/laserblack'
		width = width or 30
		unitLen = unitLen or 15
		duration = duration or 5
		period = period or 0.01
		numPer = numPer or 1

		// 边界条件
		if !isnumber(diameter) then error('diameter invalid') end 
		if !isvector(center) then error('center invalid') end 
		if !isstring(mat) then error('mat invalid') end
		if !isnumber(width) then error('width invalid') end
		if !isnumber(unitLen) then error('unitLen invalid') end
		if !isnumber(duration) then error('duration invalid') end
		if !isnumber(period) then error('period invalid') end
		if !isnumber(numPer) then error('numPer invalid') end

		table.insert(bladestorm_data, {
			emitter = ParticleEmitter(zero),
			diameter = diameter,
			center = center,
			mat = mat,
			width = width,
			unitLen = unitLen,
			duration = duration,
			period = period,
			numPer = numPer,
			timerDuration = 0,
			timerPeriod = 0
		})
	end


	hook.Add('Think', 'h2d_bladestorm_effect', function()
		-- 事件调度 剑刃风暴特效 
		local dt = FrameTime()
		
		for i = #bladestorm_data, 1, -1 do
			local data = bladestorm_data[i]
			
			data.timerDuration = data.timerDuration + dt
			if data.timerDuration > data.duration then
				data.emitter:Finish()
				table.remove(bladestorm_data, i)
				continue
			end
			
			data.timerPeriod = data.timerPeriod + dt
			if data.timerPeriod >= data.period then
				data.timerPeriod = data.timerPeriod - data.period
				h2d_LineTrailSphere(
					data.diameter, 
					data.center, 
					data.emitter, 
					data.mat, 
					data.width, 
					data.unitLen, 
					data.numPer)
			end
		end
	end)



	local startPos
	concommand.Add('h2d_debug_line_trail', function(ply)
		local pos = ply:GetEyeTrace().HitPos
		if startPos == nil then
			startPos = pos
		else
			local emitter = ParticleEmitter(Vector())
			h2d_LineTrail(emitter, 'models/wireframe', startPos, pos, 30, 10, 0.5)
			print((startPos - pos):Length())
			debugoverlay.Line(startPos, pos, 5, Color(255, 0, 0), true)
			startPos = nil
			emitter:Finish()
		end
	end)

	concommand.Add('h2d_debug_line_trail_sphere', function(ply)
		local tr = ply:GetEyeTrace()
		local diameter = 5000
		local center = tr.HitPos + tr.HitNormal * 125

		h2d_LineTrailSphere(diameter, center, nil, 'h2d/laserblack', 30, 500, 50)
		h2d_LineTrailSphere(diameter, center, nil, 'h2d/laserblack2', 30, 500, 50)
	end)


	concommand.Add('h2d_debug_bladestorm_effect', function(ply)
		local tr = ply:GetEyeTrace()
		local diameter = 1000
		local center = tr.HitPos + tr.HitNormal * 125 
		h2d_bladestorm_effect(diameter, center, 'h2d/laserblack', 30, 100)
		h2d_bladestorm_effect(diameter, center, 'h2d/laserblack2', 30, 100)
	end)


end








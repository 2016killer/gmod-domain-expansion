if CLIENT then
    local EMITTER = FindMetaTable('CLuaEmitter')
	local zero = Vector()
	local function IsZero(v) return v.x == 0 and v.y == 0 and v.z == 0 end

	function domain_UniformTriangle(v1, v2)
		-- 三角形内均匀采样点
        local x = math.random()
        local y = math.random()
        if x + y > 1 then
            x = 1 - x
            y = 1 - y
        end
		return v1 * x + v2 * y
	end

	function domain_UniformSphere(radius)
		-- 球体内均匀采样点
		return VectorRand() * radius * math.pow(math.random(), 0.333) 
	end

	function domain_UniformSphereSurface(radius)
		-- 球面均匀采样点
		return VectorRand() * radius * math.sqrt(math.random())
	end

	function domain_LinearSphere(radius)
		-- 球体内径向线性采样点
		return VectorRand() * radius * math.random()
	end

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
			local part = self:Add(mat, center + domain_UniformSphereSurface(radius)) 
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

	function domain_GetAABBScanData(min, max, dir)
    	-- 获取长方体的切面扫描数据
		-- 获取12条棱的深度区间
		-- 可根据深度区间快速计算相交或交点

		// 获取12棱的位置、深度和全局深度极值
		local dimensions = max - min
		local axes = {
			Vector(0, 0, dimensions.z), 
			Vector(0, -dimensions.y, 0), 
			Vector(dimensions.x, 0, 0)
		}

		local edgeData = {}
		local minDepth, maxDepth = -math.huge, math.huge
		for _ = 0, 2 do
			for i = 0, 3 do
				local reference = min
				if bit.band(i, 0x01) != 0 then reference = reference + axes[1] end
				if bit.band(i, 0x02) != 0 then reference = reference + axes[2] end

				local lineAxis = axes[3]
				local linePos1 = reference
				local linePos2 = reference + lineAxis

				local depth1 = linePos1:Dot(dir)
				local depth2 = linePos2:Dot(dir)

				if math.abs(depth1 - depth2) < 0.0000152587890625 then
					continue
				end

				if depth1 > depth2 then
					linePos1, linePos2 = linePos2, linePos1
					depth1, depth2 = depth2, depth1
					lineAxis = -lineAxis
				end

				if depth1 < minDepth then minDepth = depth1 end
				if depth2 > maxDepth then maxDepth = depth2 end

				edgeData[#edgeData + 1] = {
					lineStart = linePos1,
					lineAxis = lineAxis,

					depthMin = depth1,
					depthMax = depth2
				}
			end
			axes[1], axes[3] = axes[3], axes[1]
		end

		return {
			edgeData = edgeData, 
			minDepth = minDepth,
			maxDepth = maxDepth,
			dir = dir
		}
	end

	function domain_FastAABBSection(scanData, depth)
		-- 快速计算AABB与深度区间的相交或交点
		-- 返回截面点列表

		local minDepth = scanData.minDepth
		local maxDepth = scanData.maxDepth
		if depth < minDepth or depth > maxDepth then
			return nil
		end

		local iPoints = {}
		for _, edge in ipairs(scanData.edgeData) do
			if depth >= edge.depthMin and depth <= edge.depthMax then
				iPoints[#iPoints + 1] = edge.lineStart + edge.lineAxis * (depth - edge.depthMin) / (edge.depthMax - edge.depthMin)
			end
		end

		if #iPoints < 2 then
			return nil
		else
			return iPoints
		end
	end

end


if SERVER then
    util.AddNetworkString('domain_expand')

    net.Receive('domain_expand', function(len, ply)
        print(ply)
        // local center = ply:GetPos()
        // local entity = ents.Create('fukuma')
        // entity:SetPos(center)
        // entity:SetAngles(Angle(0, 0, 0))
        // entity:Spawn()
        // entity:SetOwner(ply)
        // print(entity:GetOwner())
        // print(entity:GetNWEntity('owner'))
        // return self:GetNWEntity('owner')
    end)
end




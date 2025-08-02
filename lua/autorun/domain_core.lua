if CLIENT then
    local EMITTER = FindMetaTable('CLuaEmitter')
	local zero = Vector()
	local zerof = 0.0000152587890625

	local function IsZero(v) return v.x == 0 and v.y == 0 and v.z == 0 end

	function domain_UniformTriangle(l1, l2)
		-- 三角形内均匀采样点
        local x = math.random()
        local y = math.random()
        if x + y > 1 then
            x = 1 - x
            y = 1 - y
        end
		return l1 * x + l2 * y
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

	function domain_GetAABBScanData(mins, maxs, dir)
    	-- 获取长方体的切面扫描数据
		-- 获取12条棱的深度区间
		-- 可根据深度区间快速计算相交或交点
		-- dir 扫描方向, 必须是单位向量

		// 获取12棱的位置、深度和全局深度极值
		local dimensions = maxs - mins
		local axes = {
			Vector(0, 0, dimensions.z), 
			Vector(0, dimensions.y, 0), 
			Vector(dimensions.x, 0, 0)
		}

		local edgeData = {}
		local minDepth, maxDepth = math.huge, -math.huge
		for i = 1, 3 do
			for j = 0, 3 do
				local ref = mins
				if bit.band(j, 0x01) != 0 then ref = ref + axes[1] end
				if bit.band(j, 0x02) != 0 then ref = ref + axes[2] end

				local lineAxis = axes[3]
				local linePos1 = ref
				local linePos2 = ref + lineAxis

				local depth1 = linePos1:Dot(dir)
				local depth2 = linePos2:Dot(dir)

				if math.abs(depth1 - depth2) < zerof then
					-- 平行
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
			axes[i], axes[3] = axes[3], axes[i]
		end

		local temp = dir:Angle()
		local u = temp:Up()
		local v = temp:Right()
		return {
			edgeData = edgeData, 
			minDepth = minDepth,
			maxDepth = maxDepth,
			dir = dir,
			u = u,
			v = v
		}
	end

	function domain_FastAABBSection(scanData, depth)
		-- 快速计算AABB与深度区间的相交或交点
		-- 返回截面点列表

		local minDepth = scanData.minDepth
		local maxDepth = scanData.maxDepth
		if depth < minDepth or depth > maxDepth then
			return {}
		end

		local iPoints = {}
		for _, edge in ipairs(scanData.edgeData) do
			if depth >= edge.depthMin and depth <= edge.depthMax then
				iPoints[#iPoints + 1] = edge.lineStart + edge.lineAxis * (depth - edge.depthMin) / (edge.depthMax - edge.depthMin)
			end
		end

		return iPoints
	end

	function domain_3DPoints2ConvexPolygon(points, dir, u, v)
		-- 点集转凸多边形 (三角形集合)
		-- dir 方向
		-- u, v dir的正交基
		if #points < 3 then return {} end

		if u == nil then
			local ref = Vector(1, 0, 0)
			if math.abs(dir:Dot(ref)) + zerof > 1 then ref = Vector(0, 1, 0) end

			u = dir:Cross(ref):GetNormalized()
			v = dir:Cross(u):GetNormalized()
		end

		-- 以均值中心逆时针排序点
		local centroid = Vector(0, 0, 0)
		local points2D = {}
		for _, p in ipairs(points) do
			centroid = centroid + p
			table.insert(points2D, {
				x = p:Dot(u),
				y = p:Dot(v),
				orig = p -- 保留原3D点
			})
		end
		centroid = centroid / #points
		local cx, cy = centroid:Dot(u), centroid:Dot(v)
		
		// 排序
		table.sort(points2D, function(a, b)
			local angleA = math.atan2(a.y - cy, a.x - cx)
			local angleB = math.atan2(b.y - cy, b.x - cx)
			return angleA < angleB
		end)
		
		local sortedPoints = {}
		for _, p in ipairs(points2D) do table.insert(sortedPoints, p.orig) end

	
		-- 生成三角形集合
		local tris = {}
		for i = 2, #sortedPoints - 1 do
			table.insert(tris, {
				sortedPoints[1],
				sortedPoints[i],
				sortedPoints[i + 1]
			})
		end
		return tris
	end


	function domain_GetAABBSectionTriangles(scanData, depth)
		local iPoints = domain_FastAABBSection(scanData, depth)

		if #iPoints < 3 then return {} end
		-- 剖分三角形
		return domain_3DPoints2ConvexPolygon(iPoints, scanData.dir, scanData.u, scanData.v)
	end


	concommand.Add('domain_debug_aabb_section', function(ply)
		-- 正六面体对角线方向4等分
		local pos = LocalPlayer():GetEyeTrace().HitPos
		local mins, maxs = zero, Vector(125, 125, 125)
		local dir = Vector(1, 2, 1):GetNormalized()
		local scanData = domain_GetAABBScanData(mins, maxs, dir)
		local unit = (scanData.maxDepth - scanData.minDepth) / 4
	
		-- 生成网格
		local meshs = {}
		for i = 1, 3 do
			local tris = domain_GetAABBSectionTriangles(scanData, scanData.minDepth + unit * i)
			local obj = Mesh()
			local verts = {}

			for _, tri in ipairs(tris) do
				for i = 0, 2 do
					verts[#verts + 1] = {
						pos = tri[i + 1] + pos,	
						u = math.min(1, bit.band(i, 0x01)),
						v = math.min(1, bit.band(i, 0x02))
					}
				end		
			end
			obj:BuildFromTriangles(verts)

			meshs[#meshs + 1] = obj
		end

		local curTime = CurTime()
		hook.Add('PostDrawOpaqueRenderables', 'domain_debug_aabb_section', function()
			render.SetColorMaterial()
			render.CullMode(MATERIAL_CULLMODE_CW)
			for _, obj in pairs(meshs) do obj:Draw() end
			render.CullMode(MATERIAL_CULLMODE_CCW)
			for _, obj in pairs(meshs) do obj:Draw() end

			render.DrawWireframeBox(pos, Angle(), mins, maxs, Color(255, 255, 0), true)

			if CurTime() - curTime > 20 then 
				hook.Remove('PostDrawOpaqueRenderables', 'domain_debug_aabb_section')
			end
		end)

		timer.Simple(30, function()
			for _, obj in pairs(meshs) do obj:Destroy() end
		end)
	end)





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




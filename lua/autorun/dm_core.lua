-- 作者: Zack
-- 创建日期：2025年8月7日
-- 功能说明：主要与特效相关的函数

if CLIENT then
	local math = math
	local bit = bit
	local table = table
	local Vector = Vector
	local Angle = Angle
	local VectorRand = VectorRand
	
    local EMITTER = FindMetaTable('CLuaEmitter')
	local zero = Vector()
	local zerof = 0.000030517578125

	local function IsZero(v) return v.x == 0 and v.y == 0 and v.z == 0 end

	function dm_UniformTriangle(l1, l2)
		-- 三角形内均匀采样点
        local x = math.random()
        local y = math.random()
        if x + y > 1 then
            x = 1 - x
            y = 1 - y
        end
		return l1 * x + l2 * y
	end

	function dm_UniformSphere(radius)
		-- 球体内均匀采样点
		return VectorRand() * radius * math.pow(math.random(), 0.333) 
	end

	function dm_UniformSphereSurface(radius)
		-- 球面均匀采样点
		return VectorRand() * radius * math.sqrt(math.random())
	end

	function dm_LinearSphere(radius)
		-- 球体内径向线性采样点
		return VectorRand() * radius * math.random()
	end

    EMITTER.dm_LaserTrail = function(self, mat, startPos, endPos, width, unitLen, dieTime)
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

	local UniformSphereSurface = dm_UniformSphereSurface
    EMITTER.dm_SphereSnow = function(self, mat, radius, center, width, lenth, num, dieTime)
		-- 在指定球体内创建雪花
		-- radius 半径
		-- center 中心
		-- mat 材质
		-- width 宽度
        -- lenth 长度
		-- num 数量
		-- dieTime 消亡时间
	
		for i = 1, num do 
			local part = self:Add(mat, center + UniformSphereSurface(radius)) 
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
 
	local sv_gravity = GetConVar('sv_gravity')
	EMITTER.dm_Blast = function(self, mat, vel, center, width, lenth, num, dieTime)
		-- 在指定球体内创建爆炸
		-- mat 材质
		-- vel 速度
		-- center 中心
		-- width 宽度
        -- lenth 长度
		-- num 数量
		-- dieTime 消亡时间
		local gravity = Vector(0, 0, -sv_gravity:GetFloat())
		for i = 1, num do 
			local part = self:Add(mat, center) 
			if part then
				local dir = VectorRand()
				part:SetDieTime(dieTime) 

				part:SetStartAlpha(255) 
				part:SetEndAlpha(0)

				part:SetStartSize(width) 
				part:SetEndSize(0) 

                part:SetStartLength(lenth)
				part:SetEndLength(0)

				part:SetGravity(gravity) 
				part:SetVelocity(dir * vel)	
			end
		end
	end


	function dm_GetAABBVertexes(mins, maxs)
    	-- 获取长方体顶点
		local dimensions = maxs - mins
		local axes = {
			Vector(0, 0, dimensions.z), 
			Vector(0, dimensions.y, 0), 
			Vector(dimensions.x, 0, 0)
		}

		local verts = {}
		for i = 0, 7 do
			local ref = mins
			for j = 0, 2 do
				if bit.band(i, bit.lshift(1, j)) ~= 0 then
					ref = ref + axes[j + 1]
				end
			end
			verts[#verts + 1] = ref
		end
		return verts
	end

	function dm_GetAABBScanData(mins, maxs, dir)
    	-- 获取长方体的切面扫描数据
		-- 获取12条棱的深度区间
		-- 可根据深度区间快速计算相交或交点
		-- dir 扫描方向 (非零向量)
		if dir:Dot(dir) < zerof then error('dir为零向量') end
		dir = dir:GetNormalized()
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
				if bit.band(j, 0x01) ~= 0 then ref = ref + axes[1] end
				if bit.band(j, 0x02) ~= 0 then ref = ref + axes[2] end

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
			v = v,
			mins = Vector(mins),
			maxs = Vector(maxs)
		}
	end

	function dm_FastAABBSection(scanData, depth)
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

	function dm_PASort(points, origin)
		-- 极角排序
		if #points < 2 then return end

		if origin == nil then
			origin = points[1]
			for _, p in ipairs(points) do
				if p.y < origin.y or (p.y == origin.y and p.x < origin.x) then
					origin = p
				end
			end
		end

		local ox, oy = origin.x, origin.y
		table.sort(points, function(a, b)
			local ax, ay = a.x - ox, a.y - oy
			local bx, by = b.x - ox, b.y - oy
			local cross = ax * by - ay * bx

			if cross ~= 0 then
				return cross > 0
			else
				-- 共线时距离近的优先
				local distA = ax * ax + ay * ay
				local distB = bx * bx + by * by
				return distA < distB
			end
		end)
	end

	local PASort = dm_PASort
	function dm_3DPoints2Poly(points3D, u, v)
		-- 3D点集转多边形
		-- u, v 平面的轴

		if #points3D < 3 then return {} end

		-- 转到平面坐标
		local points = {}
		local center = {x = 0, y = 0}
		for _, p in ipairs(points3D) do
			local p2D = {
				x = p:Dot(u),
				y = p:Dot(v),
				orig = p -- 保留原3D点
			}
			center.x, center.y = center.x + p2D.x, center.y + p2D.y
			points[#points + 1] = p2D
		end
		center.x, center.y = center.x / #points, center.y / #points

		-- 极角排序
		PASort(points, center)

		-- 使用3D点生成三角形集合
		local tris = {}
		for i = 2, #points - 1 do
			tris[#tris + 1] = {
				points[1].orig,
				points[i].orig,
				points[i + 1].orig
			}
		end

		return tris
	end

	function dm_3DPointsGrahamScan(points3D, u, v)
		-- 凸包构建
		-- 将对原数组排序
		if #points3D < 3 then return {} end

		-- 转到平面坐标
		local points = {}
		for _, p in ipairs(points3D) do
			local p2D = {
				x = p:Dot(u),
				y = p:Dot(v),
			}
			points[#points + 1] = p2D
		end
	
		PASort(points)

		// 筛选凸包点
		local stack = {points[1], points[2]}
		for i = 3, #points do
			local p = points[i]
			while #stack >= 2 do
				local topIdx = #stack
				local a = stack[topIdx - 1]  -- 栈顶前一点
				local b = stack[topIdx]      -- 栈顶点
			
				local abx, aby = b.x - a.x, b.y - a.y
				local apx, apy = p.x - a.x, p.y - a.y
	
				local cross = abx * apy - aby * apx
				if cross <= 0 then
					table.remove(stack)  
				else
					break
				end
			end
			table.insert(stack, p) 
		end

		-- 使用3D点生成三角形集合
		local tris = {}
		for i = 2, #stack - 1 do
			tris[#tris + 1] = {
				stack[1].x * u + stack[1].y * v,
				stack[i].x * u + stack[i].y * v,
				stack[i + 1].x * u + stack[i + 1].y * v
			}
		end

		return tris
	end

	function dm_SimpleMesh(tris)
		-- 生成简易网格 (固定uv)
		local obj = Mesh()
		local verts = {}
		for _, tri in ipairs(tris) do
			for i = 0, 2 do
				verts[#verts + 1] = {
					pos = tri[i + 1],	
					u = math.min(1, bit.band(i, 0x01)),
					v = math.min(1, bit.band(i, 0x02))
				}
			end		
		end
		obj:BuildFromTriangles(verts)

		return obj
	end


	EMITTER = nil
end


local dm_armor_condition = CreateConVar('dm_armor_condition', '20', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local dm_health_condition = CreateConVar('dm_health_condition', '20', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })


function dm_ExpandCondition(ply, dotype)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	if not ply:Alive() then return false end
	if ply:InVehicle() then return false end

	if not scripted_ents.Get(dotype) then 
		if CLIENT then 
			ply:EmitSound('Trainyard.sodamachine_empty') 
			print('未知的类型领域:'..dotype)
		end
		return false 
	end

	if ply:GetNWFloat('FusingTime', 0) > CurTime() then 
		if CLIENT then ply:EmitSound('ambient/energy/newspark09.wav') end
		return false 
	end
	
	local armor_condition = dm_armor_condition:GetFloat()
	local health_condition = dm_health_condition:GetFloat()

	if ply:Armor() < armor_condition then
		if CLIENT then ply:EmitSound('TriggerSuperArmor.DoneCharging') end
		return false
	end
	if ply:Health() < health_condition then
		if CLIENT then ply:EmitSound('WallHealth.Deny') end
		return false
	end

	return not hook.Run('PreDomainExpand', ply, dotype)
end





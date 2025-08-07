if CLIENT then
	local zero = Vector()
	concommand.Add('dm_debug_aabb_section', function(ply)
		-- 正六面体对角线方向4等分
		local pos = LocalPlayer():GetEyeTrace().HitPos
		local mins, maxs = zero, Vector(125, 125, 125)
		local dir = Vector(1, 2, 1):GetNormalized()
		local scanData = dm_GetAABBScanData(mins, maxs, dir)
		local unit = (scanData.maxDepth - scanData.minDepth) / 10
	
		-- 生成网格
		local meshs = {}
		for i = 1, 9 do
			local obj = dm_SimpleMesh(
				dm_3DPoints2Poly(
					dm_FastAABBSection(scanData, scanData.minDepth + unit * i), 
					scanData.u, 
					scanData.v)
			)
	
			meshs[#meshs + 1] = obj
		end

		local curTime = CurTime()
		hook.Add('PostDrawOpaqueRenderables', 'dm_debug_draw', function()
			local matrix = Matrix()
			matrix:SetTranslation(pos)
			cam.PushModelMatrix(matrix)
				render.SetColorMaterial()
				render.CullMode(MATERIAL_CULLMODE_CW)
				for _, obj in pairs(meshs) do obj:Draw() end
				render.CullMode(MATERIAL_CULLMODE_CCW)
				for _, obj in pairs(meshs) do obj:Draw() end

				render.DrawWireframeBox(zero, Angle(), mins, maxs, Color(255, 255, 0), true)
			cam.PopModelMatrix()

			if CurTime() - curTime > 20 then 
				hook.Remove('PostDrawOpaqueRenderables', 'dm_debug_draw')
			end
		end)

		timer.Simple(30, function()
			for _, obj in pairs(meshs) do obj:Destroy() end
		end)
	end)

	concommand.Add('dm_debug_aabb_bounds2d', function(ply)
		-- 正六面体对角线方向4等分
		local pos = LocalPlayer():GetEyeTrace().HitPos
		local mins, maxs = zero, Vector(125, 125, 125)
		local dir = Vector(1, 2, 1):GetNormalized()
		local scanData = dm_GetAABBScanData(mins, maxs, dir)

		local tris = dm_3DPointsGrahamScan(
			dm_GetAABBVertexes(mins, maxs), 
			scanData.u, 
			scanData.v
		)

		-- 生成网格
		local obj = dm_SimpleMesh(tris)

		local curTime = CurTime()
		hook.Add('PostDrawOpaqueRenderables', 'dm_debug_draw', function()
			local matrix = Matrix()
			matrix:SetTranslation(pos)
			cam.PushModelMatrix(matrix)
				render.SetColorMaterial()
				render.CullMode(MATERIAL_CULLMODE_CW)
				obj:Draw()
				render.CullMode(MATERIAL_CULLMODE_CCW)
				obj:Draw()
				render.DrawWireframeBox(zero, Angle(), mins, maxs, Color(255, 255, 0), true)
			cam.PopModelMatrix()

			if CurTime() - curTime > 20 then 
				hook.Remove('PostDrawOpaqueRenderables', 'dm_debug_draw')
			end
		end)

		timer.Simple(30, function() obj:Destroy() end)

	end)

	concommand.Add('dm_debug_draw', function(ply, cmd, args)
		local mat = Material(args[1])
		local curTime = CurTime()

		hook.Add('HUDPaint', 'dm_debug_draw', function()
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(mat)
			surface.DrawTexturedRect(0, 0, 512, 512)

			if CurTime() - curTime > 5 then 
				hook.Remove('HUDPaint', 'dm_debug_draw')
			end
		end)
	end)

	concommand.Add('dm_debug_setmaterial', function(ply, cmd, args)
		// effects/ar2_altfire1
		local ent = ply:GetEyeTrace().Entity
		ent:SetMaterial(args[1])
	end)

    local temp
	concommand.Add('dm_debug_laser_trail', function(ply)
		local pos = ply:GetEyeTrace().HitPos
		if isvector(temp) then
			local emitter = ParticleEmitter(zero)
            
            emitter:dm_LaserTrail(
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

	concommand.Add('dm_debug_sphere_snow', function(ply)
		local tr = ply:GetEyeTrace()
		local radius = 500
		local center = tr.HitPos + tr.HitNormal * radius
   
        local emitter = ParticleEmitter(zero)
        
        emitter:dm_SphereSnow(
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
else
	concommand.Add('dm_debug_material_type', function(ply)
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		local phy = ent:GetPhysicsObject()
		print(phy:GetMaterial())
	end)
end




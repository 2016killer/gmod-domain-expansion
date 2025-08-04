if CLIENT then
	-- 测量
    local measureState = false
	local measureResult = 0

	local measureEnts // 特效模型
	local function getMeasureEnts()
		if not istable(measureEnts) then measureEnts = {} end
		for i = 1, 2 do
			if not IsValid(measureEnts[i]) then 
				measureEnts[i] = ClientsideModel('models/dav0r/hoverball.mdl')
				measureEnts[i]:SetMaterial('Models/effects/vol_light001') 
			end
		end	
		return measureEnts
	end

	local dm_sensitivity = CreateClientConVar('dm_sensitivity', '500', true, false)
	hook.Add('Think', 'domain_measure', function()
		-- 测量逻辑
		if measureState then 
			local dt = FrameTime() / game.GetTimeScale()
			measureResult = measureResult + dt * dm_sensitivity:GetFloat()
		else
			measureResult = 0 
		end
	end)

	hook.Add('PostDrawOpaqueRenderables', 'domain_measure', function()
        -- 特效
		if not measureState then return end

		local measureEnts = getMeasureEnts()

		measureEnts[1]:SetModelScale(measureResult * 0.166 + 2)
		measureEnts[1]:SetPos(LocalPlayer():GetPos())
		measureEnts[2]:SetModelScale(measureResult * 0.166)
		measureEnts[2]:SetPos(LocalPlayer():GetPos())

		// render.DrawWireframeSphere(LocalPlayer():GetPos(), measureResult, 32, 32, Color(255, 255, 0, 100), true)

		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SuppressEngineLighting(true)
			// 全屏
			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)
			render.SetStencilReferenceValue(1)
			render.SetStencilCompareFunction(STENCIL_ALWAYS)
			render.SetStencilPassOperation(STENCIL_REPLACE)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)

			render.PerformFullScreenStencilOperation()

			// 遮罩
			render.SetStencilCompareFunction(STENCIL_ALWAYS)
			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_INCR)
			// 使用特殊材质便捷双面渲染
			measureEnts[2]:DrawModel()


			render.SetStencilReferenceValue(0)
			render.SetStencilCompareFunction(STENCIL_EQUAL)
			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			cam.Start2D()
				surface.SetDrawColor(0, 0, 0, 150)
				surface.DrawRect(0, 0, ScrW(), ScrH())
			cam.End2D()

			// 遮罩
			render.SetStencilCompareFunction(STENCIL_ALWAYS)
			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_INCR)
			measureEnts[1]:DrawModel()
	

			render.SetStencilReferenceValue(0)
			render.SetStencilCompareFunction(STENCIL_EQUAL)
			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)

			render.ClearBuffersObeyStencil(255, 255, 255, 255, false)
	
		render.SetStencilEnable(false)
		render.SuppressEngineLighting(false)
	end)
	
	
	concommand.Add('+domain_run', function(ply, args)
		// if ply:GetNWBool('fusing') then 
		if not domain_ExpandCondition(ply) then return end
		// hook.Run('domain_run', ply, args[1])
			


		
		measureState = true
		// if not VManip then return end
		// if VManip:PlayAnim("exedrop") then exedrop = true net.Start('exedrop') owner:EmitSound(Sound('Pistol.ItemPickupExtend')) net.WriteBool(true) net.SendToServer()  end
	end)

	concommand.Add('-domain_run', function(ply)
		measureState = false
		// net.Start('domain_expand')
		// net.SendToServer()
	end)

	concommand.Add('domain_break', function(ply, args)
		measureState = false
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


	concommand.Add('domain_debug_material_type', function(ply)
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity
		local phy = ent:GetPhysicsObject()
		print(phy:GetMaterial())
	end)

end
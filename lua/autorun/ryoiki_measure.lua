if CLIENT then
	local t2Mat = Material('Models/effects/vol_light001')
    local measureState = false
	local measureResult = 0

	local measureEnts // 特效模型
	local function getMeasureEnts()
		if !istable(measureEnts) then measureEnts = {} end
		for i = 1, 2 do
			if !IsValid(measureEnts[i]) then measureEnts[i] = ClientsideModel('models/dav0r/hoverball.mdl') end
			if !measureEnts[i]:GetNoDraw() then measureEnts[i]:SetNoDraw(true) end
			// measureEnts[i]:SetMaterial('models/wireframe')
		end	
		return measureEnts
	end

	hook.Add('PostDrawOpaqueRenderables', 'ryoiki_measure', function()
        -- 测量特效
		local measureSensitivity = GetConVar('ryoiki_measure_sensitivity'):GetFloat()
		if measureState then
			measureResult = measureResult + FrameTime() * measureSensitivity
		else
			measureResult = math.max(measureResult - FrameTime() * measureSensitivity * 3, 0) 
		end

		if measureResult == 0 then return end

		local measureEnts = getMeasureEnts()
		for i = 1, 2 do
			measureEnts[i]:SetModelScale(measureResult * 0.17 - i)
			measureEnts[i]:SetPos(LocalPlayer():GetPos())
		end

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
			render.OverrideColorWriteEnable(true, false)
			render.MaterialOverride(t2Mat)
				measureEnts[2]:DrawModel()
			render.MaterialOverride()
			render.OverrideColorWriteEnable(false)

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

			render.MaterialOverride(t2Mat)
				measureEnts[1]:DrawModel()
			render.MaterialOverride()

			render.SetStencilReferenceValue(0)
			render.SetStencilCompareFunction(STENCIL_EQUAL)
			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)

			render.ClearBuffersObeyStencil(255, 255, 255, 255, false)
	
		render.SetStencilEnable(false)
		render.SuppressEngineLighting(false)
	end)


	concommand.Add('+ryoiki_tenkai', function(ply, args)
		measureState = true
		hook.Run('ryoiki_measure', ply, args[1])
		// local ammo = owner:GetAmmoCount('EKATANA')
		// if ammo < 1 then owner:EmitSound(Sound('noEnergy'),100,100) return end
		// if !VManip then return end
		// if VManip:PlayAnim("exedrop") then exedrop = true net.Start('exedrop') owner:EmitSound(Sound('Pistol.ItemPickupExtend')) net.WriteBool(true) net.SendToServer()  end
	end)

	concommand.Add('-ryoiki_tenkai', function(ply)
		measureState = false
	end)


end








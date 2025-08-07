-- 作者: Zack
-- 创建日期：2025年8月7日
-- 功能说明：主要逻辑, 玩家与领域实体对象的交互处理

local FrameTime = FrameTime
local RealFrameTime = RealFrameTime

if CLIENT then
	-- 测量
	local dm_minr = CreateConVar('dm_minr', '200', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
    local measureState = false
	local measureResult = dm_minr:GetFloat()

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
	hook.Add('Think', 'dm_measure', function()
		-- 测量逻辑
		if measureState then 
			local dt = FrameTime()
			measureResult = measureResult + dt * dm_sensitivity:GetFloat() 
		end
	end)

	hook.Add('PostDrawOpaqueRenderables', 'dm_measure', function()
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
	
	local dm_threat = CreateConVar('dm_threat', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
	local dm_start_anim = CreateClientConVar('dm_start_anim', 'dhblink', true, false)
	local dm_execute_anim = CreateClientConVar('dm_execute_anim', 'dhblink', true, false)
	local dm_break_anim = CreateClientConVar('dm_break_anim', 'dhwindblast', true, false)
	
	local threatNextTime = 0
	concommand.Add('+dm_start', function(ply, cmd, args)
		local domain = ply:GetNWEntity('domain')
		if IsValid(domain) then
			net.Start('dm_execute')
				net.WriteBool(true)
			net.SendToServer()

			if VManip then VManip:PlayAnim(dm_start_anim:GetString()) end
		else
			if not dm_ExpandCondition(ply, args[1]) then return end
			measureState = true

			-- 威胁
			local curTime = CurTime()
			if dm_threat:GetBool() and curTime > threatNextTime then
				threatNextTime = curTime + 2
				net.Start('dm_threat')
					net.WriteVector(ply:GetPos())
				net.SendToServer()
			end

			if VManip then VManip:PlayAnim(dm_execute_anim:GetString()) end
		end
	end)

	concommand.Add('-dm_start', function(ply, cmd, args)
		if not gui.IsGameUIVisible() then
			local domain = ply:GetNWEntity('domain')
			if IsValid(domain) then
				net.Start('dm_execute')
					net.WriteBool(false)
				net.SendToServer()
			else
				if measureState then
					net.Start('dm_expand')
						net.WriteString(args[1])
						net.WriteFloat(measureResult)
					net.SendToServer()
				end
			end
		end

		measureState = false
		measureResult = dm_minr:GetFloat()
		if VManip then 
			VManip:QuitHolding(dm_start_anim:GetString())
			VManip:QuitHolding(dm_execute_anim:GetString())
			// VManip:QuitHolding(dm_break_anim:GetString()) 
		end
	end)

	concommand.Add('dm_break', function(ply, args)
		measureState = false
		measureResult = dm_minr:GetFloat()

		local domain = ply:GetNWEntity('domain')
		if IsValid(domain) then  
			net.Start('dm_break')
			net.SendToServer()
			if VManip then 
				VManip:QuitHolding(dm_start_anim:GetString())
				VManip:QuitHolding(dm_execute_anim:GetString())
				VManip:PlayAnim(dm_break_anim:GetString()) 
			end
		else
			if VManip then 
				VManip:QuitHolding(dm_start_anim:GetString())
				VManip:QuitHolding(dm_execute_anim:GetString())
			end
		end
	end)


	local warningMat = Material('dm/warning.png')
	local warningPosList = {}
	hook.Add('HUDPaint', 'dm_threat', function()
        -- 危险预警
		if #warningPosList > 0 then
			local cx, cy = ScrW() * 0.5, ScrH() * 0.5
			local dt = RealFrameTime()

			surface.SetMaterial(warningMat)
			for i = #warningPosList, 1, -1 do
				local data = warningPosList[i]

				local progress = data.progress
				if progress > 1 then
					table.remove(warningPosList, i)
					continue
				end

				local pos = data.pos:ToScreen()
				local scale = (progress < 0.5 and progress or (1 - progress)) * 4
				local alpha = 255 * scale
				local width = 100 * scale
	
				surface.SetDrawColor(255, 255, 255, alpha)
				surface.DrawTexturedRect(
					pos.x - 0.5 * width, 
					pos.y - 0.5 * width, 
					width, 
					width
				)

				data.progress = data.progress + dt * 0.8
			end
		end
	end)

	local dm_threat_range = CreateConVar('dm_threat_range', '1000', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
	net.Receive('dm_threat', function()
		local ply = net.ReadEntity()
		local pos = net.ReadVector()

		local lply = LocalPlayer()
	
		if lply ~= ply and dm_threat:GetBool() then  
			if pos:Distance(lply:GetPos()) < dm_threat_range:GetFloat() then
				lply:EmitSound('dm/warning.wav')
				table.insert(warningPosList, {pos = pos, progress = 0})
			end
		end
    end)

	function dm_GetMeasureResult()
		return measureResult
	end

	function dm_GetMeasureState()
		return measureState
	end

end

if SERVER then
    net.Receive('dm_expand', function(len, ply)
		local dotype = net.ReadString()
		local tRadius = net.ReadFloat()

		if not dm_ExpandCondition(ply, dotype) then return end

        local ent = ents.Create(dotype)
        ent:SetPos(ply:GetPos())
		ent:SetOwner(ply)
		ent:SetTRadius(tRadius)
        ent:Spawn()

		ply:SetNWEntity('domain', ent)

		ent:EmitSound('k_lab.teleport_sound', 511)
    end)

	net.Receive('dm_execute', function(len, ply)
		local execute = net.ReadBool()
		
		local domain = ply:GetNWEntity('domain')
		if IsValid(domain) then  
			domain:SetExecute(execute)
		end
    end)

	net.Receive('dm_break', function(len, ply)
		local domain = ply:GetNWEntity('domain')
		if IsValid(domain) then 
			domain:Break()
		end
    end)

	net.Receive('dm_threat', function(len, ply)
		local pos = net.ReadVector()
		net.Start('dm_threat')
			net.WriteEntity(ply)
			net.WriteVector(pos)
		net.Broadcast()
    end)

end
-- 作者: Zack
-- 创建日期：2025年8月7日
-- 功能说明：伏魔神龛击杀特效马甲

local FrameTime = FrameTime
local transparent = Color(0, 0, 0, 0)

if SERVER then
    local fkmd_nogravity = CreateConVar('fkmd_nogravity', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

    local entQueue = {}
    function fkmd_PlayInServer(ent, duration)
        -- 将实体加入动画队列
        -- ent 目标
        -- duration 动画时长 
        if ent.fkmd_flag or ent:IsWorld() then return end
        ent.fkmd_flag = true

        entQueue[#entQueue + 1] = {
            ent = ent,
            duration = duration
        }
    end

    local timeCount, period, batch = 0, 1, 20
    hook.Add('Think', 'fkmd_ent_remove', function()
        -- 批处理动画队列
        -- 每秒处理20个实体
        -- 标记实体开启动画, 并启动延时删除
        timeCount = timeCount + FrameTime()
        if timeCount < period then return end
        timeCount = 0

        local netData = {}
        for i = #entQueue, math.max(#entQueue - batch, 1), -1 do
            local data = entQueue[i]
            local ent = data.ent

            if IsValid(ent) then
                local matType = ent:GetPhysicsObject():GetMaterial()

                -- 关闭重力
                if fkmd_nogravity:GetBool() then 
                    for i = 0, ent:GetPhysicsObjectCount() - 1 do
                        local phy = ent:GetPhysicsObjectNum(i)
                        phy:EnableGravity(false)
                        // phy:EnableCollisions(false)
                    end
                end

                -- 修改透明度
                ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
                ent:SetColor(transparent)

                -- 启动延时删除
                SafeRemoveEntityDelayed(ent, data.duration)
                netData[#netData + 1] = {ent, matType, data.duration}
                table.remove(entQueue, i)
            else
                table.remove(entQueue, i)
            end
        end

        -- 广播标记
        net.Start('fkmd_play')
            net.WriteTable(netData)
        net.Broadcast()
    end)


    concommand.Add('fkmd_debug_play_sv', function(ply)
        local ent = ply:GetEyeTrace().Entity
        fkmd_PlayInServer(ent, 1)
    end)
end

if CLIENT then  
    include('fkmd_effect_data.lua')

    local fkmd_nogravity = CreateConVar('fkmd_nogravity', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
    local fkmd_ragdoll_limit = CreateClientConVar('fkmd_ragdoll_limit', '20', true, false)
    local fkmd_ent_limit = CreateClientConVar('fkmd_ent_limit', '20', true, false)

    local effectCount = fkmd_effectCount
    local effectDataTable = fkmd_effectDataTable
    local materialTypeTable = fkmd_materialTypeTable
    local zero = Vector()
    
    local ENTITY = FindMetaTable('Entity')
        ENTITY.fkmd_Play = function(self, matType, remove, duration)
            -- 根据限制选择动画类型
            local animType
            if self:IsRagdoll() then
                animType = effectCount.Ragdoll >= fkmd_ragdoll_limit:GetInt()
            else
                animType = effectCount.Entity >= fkmd_ent_limit:GetInt()
            end
            
            if animType then
                self:SetRenderMode(RENDERMODE_TRANSCOLOR)
                self:SetColor(transparent)

                -- 查询粒子特效贴图
                local effectData = effectDataTable['Metal']
                for tp, hash in pairs(materialTypeTable) do
                    if hash[matType] and effectDataTable[tp] then
                        effectData = effectDataTable[tp]
                    end
                end

                local emitter = ParticleEmitter(zero)
                local mins, maxs = self:GetModelBounds()
                
                emitter:dm_Blast(
                    effectData.matp, 
                    2000, 
                    self:GetPos(), 
                    15, 
                    50, 
                    50, 
                    0.5
                )

                emitter:Finish()

                self:EmitSound(effectData.sound)
            else
                self:SetRenderMode(RENDERMODE_TRANSCOLOR)
                self:SetColor(transparent)

                if fkmd_nogravity:GetBool() then
                    for i = 0, self:GetPhysicsObjectCount() - 1 do
                        local phy = self:GetPhysicsObjectNum(i)
                        phy:EnableGravity(false)
                    end
                end

                duration = duration or 1
                self:SetRenderMode(RENDERMODE_TRANSCOLOR)
                self:SetColor(Color(0, 0, 0, 0))

                local dir = VectorRand()
                local fkmdEnt1 = ents.CreateClientside('fkmd')
                local fkmdEnt2 = ents.CreateClientside('fkmd')

                fkmdEnt1:InitModel(self)
                fkmdEnt1:InitClip(dir, 0.5, matType)
                fkmdEnt1:SetDuration(duration)
                fkmdEnt1:Spawn()

                fkmdEnt2:InitModel(self)
                fkmdEnt2:InitClip(-dir, 0.5, matType)
                fkmdEnt2:SetDuration(duration)
                fkmdEnt2:Spawn()

                fkmdEnt1.removeParent = remove
            end
        end
    ENTITY = nil

    net.Receive('fkmd_play', function()
        local netData = net.ReadTable()
        
        for _, data in ipairs(netData) do
            local ent = data[1]
            local matType = data[2]
            local duration = data[3]

            -- 延迟可能导致的同步问题
            if IsValid(ent) then
                ent:fkmd_Play(matType, false, duration)
            end
        end
    end)

    concommand.Add('fkmd_debug_play', function()
        local ent = LocalPlayer():GetEyeTrace().Entity
        ent:fkmd_Play('Metal')
    end)

    concommand.Add('fkmd_clear', function()
        for _, ent in ipairs(ents.FindByClass('fkm_death')) do
            ent:Remove()
        end
    end)

end
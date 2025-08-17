-- 作者: Zack
-- 创建日期：2025年8月7日
-- 功能说明：伏魔神龛击杀特效马甲

local FrameTime = FrameTime
local transparent = Color(0, 0, 0, 0)

if SERVER then
    local fkmd_nogravity = CreateConVar('fkmd_nogravity', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

    function fkmd_PlayInServer(entlist, duration)
        -- 广播实体组动画, 并启动延时删除 
        local validlist = {}
        for _, ent in pairs(entlist) do
            if IsValid(ent) then
                -- 排除刷模型及地图基础实体
                local class = ent:GetClass()
                if string.StartWith(class, 'func_') or string.StartWith(class, 'trigger_') or string.StartWith(class, 'brush_') then
                    continue
                end
                

                local phy = ent:GetPhysicsObject()
                local matType = IsValid(phy) and phy:GetMaterial() or 'metal'
                
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

                -- 关闭阴影
                // ent:DrawShadow(false)

                validlist[#validlist + 1] = {ent, matType}
            end
        end
 
        if #validlist > 0 then
            -- 广播标记
            net.Start('fkmd_play')
                net.WriteTable(validlist)
                net.WriteFloat(duration)
            net.Broadcast()

            -- 启动延时删除
            timer.Simple(duration, function()      
                for _, data in pairs(validlist) do
                    if IsValid(data[1]) then 
                        SafeRemoveEntity(data[1]) 
                    end
                end
            end)
        end
    end

end

if CLIENT then  
    fkmd_effectCount = fkmd_effectCount or {}
    fkmd_effectDataTable = fkmd_effectDataTable or {}
    fkmd_materialTypeTable = fkmd_materialTypeTable or {}

    local fkmd_nogravity = CreateConVar('fkmd_nogravity', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
    local fkmd_ragdoll_limit = CreateClientConVar('fkmd_ragdoll_limit', '50', true, false)
    local fkmd_ent_limit = CreateClientConVar('fkmd_ent_limit', '50', true, false)

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
                
                if IsValid(emitter) then 
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
                end
                self:EmitSound(effectData.sound)
                if remove then SafeRemoveEntity(self) end
            else
                duration = duration or 1

                self:SetRenderMode(RENDERMODE_TRANSCOLOR)
                self:SetColor(transparent)

                if fkmd_nogravity:GetBool() then
                    for i = 0, self:GetPhysicsObjectCount() - 1 do
                        local phy = self:GetPhysicsObjectNum(i)
                        phy:EnableGravity(false)
                    end
                end

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
        local duration = net.ReadFloat()

        for _, data in ipairs(netData) do
            local ent = data[1]
            local matType = data[2]

            -- 延迟可能导致的同步问题
            if IsValid(ent) then
                ent:fkmd_Play(matType, false, duration)
            end
        end
    end)

    concommand.Add('fkmd_clear', function()
        fkmd_effectCount.Ragdoll = 0
        fkmd_effectCount.Entity = 0
        for _, ent in ipairs(ents.FindByClass('fkmd')) do
            ent:Remove()
        end
    end)
end
ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'

ENT.ClassName = 'fkm_death'
ENT.PrintName = 'Fkm Death' 
ENT.Category = 'Domain'
ENT.Spawnable = false

-- 实体的fkm死亡逻辑
if SERVER then
    util.AddNetworkString('fkmd_entity_die')

    local fkmDieQueue = {} 
    function fkmd_EntityDie(ent, duration)
        -- ent 目标实体
        -- duration 动画时长
        
        local matType = ent:GetPhysicsObject():GetMaterial()
        for i = 0, ent:GetPhysicsObjectCount() - 1 do
            local phy = ent:GetPhysicsObjectNum(i)
            phy:EnableGravity(false)
            // phy:EnableCollisions(false)
        end
 
        ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
        ent:SetColor(Color(0, 0, 0, 0))

        fkmDieQueue[#fkmDieQueue + 1] = {
            ent = ent,
            dietime = CurTime() + duration
        }

        net.Start('fkmd_entity_die')
            net.WriteEntity(ent)
            net.WriteFloat(duration)
            net.WriteString(matType)
        net.Broadcast()
    end

    hook.Add('Think', 'fkmd_entity_die', function()
        -- 移除逻辑
        for i = #fkmDieQueue, 1, -1 do
            local data = fkmDieQueue[i]
            if not IsValid(data.ent) then
                table.remove(fkmDieQueue, i)
            elseif data.dietime <= CurTime() then
                data.ent:Remove()
                table.remove(fkmDieQueue, i)
            end
        end
    end)

    concommand.Add('fkmd_debug_entity_die', function(ply, cmd, args)

        local ent = ply:GetEyeTrace().Entity
        if not IsValid(ent) then return end
        domain_fkm_die(ent, 1, true)
    end)
end

if CLIENT then
    net.Receive('domain_fkm_die', function()
        local ent = net.ReadEntity()
        local duration = net.ReadFloat()
        local matType = net.ReadString()

        local pos = ent:GetPos()
        local ang = ent:GetAngles()

  
        local dir = VectorRand()
        
        local animation1 = ents.CreateClientside('fkm_death')
        local animation2 = ents.CreateClientside('fkm_death')

        animation1:InitModel(ent)
        animation1:InitClip(dir, 0.5, nil, nil, nil, matType)
        animation1:SetDuration(duration)
        animation1:Spawn()

        animation2:InitModel(ent)
        animation2:InitClip(-dir, 0.5, nil, nil, nil, matType)
        animation2:SetDuration(duration)
        animation2:Spawn()
    end)
end

-- 特效数据
if CLIENT then
    domain_materialTypeTable = {
        Metal = {
            canister = true,
            chain = true,
            chainlink = true,
            grenade = true,
            metal = true,
            metal_barrel = true,
            floating_metal_barrel = true,
            metal_bouncy = true,
            metal_Box = true,
            metalgrate = true,
            metalpanel = true,
            metalvent = true,
            paintcan = true,
            popcan = true,
            roller = true,
            slipperymetal = true,
            solidmetal = true,
            weapon = true,
            strider = true
        },

        Wood = {
            wood = true,
            wood_Box = true,
            wood_Crate = true,
            wood_Furniture = true,
            wood_LowDensity = true,
            wood_Plank = true,
            wood_Panel = true,
            wood_Solid = true,
        },

        Rock = {
            boulder = true,
            brick = true,
            concrete = true,
            concrete_block = true,
            gravel = true,
            rock = true,

            tile = true,
            paper = true,
            papercup = true,
            cardboard = true,
            plaster = true,
            plastic_barrel = true,
            plastic_barrel_buoyant = true,
            plastic_Box = true,
            plastic = true,
            rubber = true,
            rubbertire = true,
            slidingrubbertire = true,
            slidingrubbertire_front = true,
            slidingrubbertire_rear = true,
            jeeptire = true,
            brakingrubbertire = true,
            porcelain = true,
        },

        Glass = {
            glass = true,
            glassbottle = true,
            Ice = true,
            Snow = true,
            slime = true,
            water = true,
            wade = true,
        },

        Flesh = {
            zombieflesh = true,
            bloodyflesh = true,
            watermelon = true,
            flesh = true
        },

        Alienflesh = {
            alienflesh = true,
            antlion = true
        }
    }

    domain_effectDataTable = {
        Metal = {
            mat = Material('fkm_death/metal'),
            matp = 'fkm_death/metalp',
            sound = 'SolidMetal.BulletImpact'
        },

        Wood = {
            mat = Material('fkm_death/wood'),
            matp = 'fkm_death/woodp',
            sound = 'Wood.Break'
        },

        Rock = {
            matp = 'fkm_death/rockp',
            sound = 'Weapon_Crowbar.Melee_Hit'
        },

        Glass = {
            matp = 'fkm_death/glassp',
            sound = 'Glass.BulletImpact'
        },

        Alienflesh = {
            mat = Material('fkm_death/alienflesh'),
            matp = 'fkm_death/alienfleshp',
            sound = 'Flesh.Break'
        },

        Flesh = {
            mat = Material('fkm_death/flesh'),
            matp = 'fkm_death/fleshp',
            sound = 'Flesh.Break'
        }
    }
end


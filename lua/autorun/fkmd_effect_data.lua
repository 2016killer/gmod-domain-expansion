if CLIENT then
    -- 特效数据
    fkmd_effectCount = {
        Entity = 0,
        Ragdoll = 0,
    }

    -- 分类表
    fkmd_materialTypeTable = {
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

    -- 特效表
    fkmd_effectDataTable = {
        Metal = {
            mat = Material('fkmd/metal'),
            matp = 'fkmd/metalp',
            sound = 'SolidMetal.BulletImpact'
        },

        Wood = {
            mat = Material('fkmd/wood'),
            matp = 'fkmd/woodp',
            sound = 'Wood.Break'
        },

        Rock = {
            matp = 'fkmd/rockp',
            sound = 'Weapon_Crowbar.Melee_Hit'
        },

        Glass = {
            matp = 'fkmd/glassp',
            sound = 'Glass.BulletImpact'
        },

        Alienflesh = {
            mat = Material('fkmd/alienflesh'),
            matp = 'fkmd/alienfleshp',
            sound = 'Flesh.Break'
        },

        Flesh = {
            mat = Material('fkmd/flesh'),
            matp = 'fkmd/fleshp',
            sound = 'Flesh.Break'
        }
    }
end
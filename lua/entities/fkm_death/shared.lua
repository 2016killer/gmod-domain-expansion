ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'

ENT.ClassName = 'fkm_death'
ENT.PrintName = 'Fkm Death' 
ENT.Category = 'domain'
ENT.Spawnable = false


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


ENT.Type = 'anim'
ENT.Base = 'dm_base'

ENT.ClassName = 'fukuma'
ENT.PrintName = 'Fukuma' 
ENT.Category = 'Domain'
ENT.Author = 'Zack'
ENT.Spawnable = true
ENT.AllInstance = {} -- 并非实时更新，仅用于播放动画


CreateConVar('fkm_ka', '2.5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('fkm_kh', '5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('fkm_damage', '20', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateClientConVar('fkm_particle_level', '0.5', true, false)

local fkm_expand_speed = CreateConVar('fkm_expand_speed', '700', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

if CLIENT then
    local phrase = language.GetPhrase

    hook.Add('PopulateToolMenu', 'fkm_menu', function()
        spawnmenu.AddToolMenuOption('Utilities', 
            phrase('fkm.menu.category'),
            'fkm_menu', 
            phrase('fkm.menu.name'), '', '', 
            function(panel)
                panel:Clear()
   
                panel:NumSlider(phrase('fkm.var.ka'), 'fkm_ka', 0, 50, 0)
                panel:Help(phrase('fkm.help.ka'))
                panel:NumSlider(phrase('fkm.var.kh'), 'fkm_kh', 0, 50, 0)
                panel:Help(phrase('fkm.help.kh'))
                panel:NumSlider(phrase('fkm.var.damage'), 'fkm_damage', 0, 5000, 0)
                panel:Help(phrase('fkm.help.damage'))
                panel:NumSlider(phrase('fkm.var.expand_speed'), 'fkm_expand_speed', 0, 5000, 0)
                panel:Help(phrase('fkm.help.expand_speed'))
                panel:NumSlider(phrase('fkm.var.particle_level'), 'fkm_particle_level', 0, 1, 3)

            end
        )
    end)
end

local AllInstance = ENT.AllInstance
function ENT:Initialize()
    self.BaseClass.Initialize(self)
    local expandSpeed = fkm_expand_speed:GetFloat()
    if expandSpeed > 0 then
        self.expandSpeed = expandSpeed
    end
    table.insert(AllInstance, self)
end


hook.Add('PreDomainExpand', 'fkm_condition', function(ply, dotype)
    if dotype == 'fukuma' and not IsValid(ply:GetWeapon('w_fukuma')) then
        if CLIENT then ply:EmitSound('Weapon_AR2.Empty') end
        return true
    end
end)

if CLIENT then
    hook.Add('CreateClientsideRagdoll', 'fkm_kill_anim', function(entity, ragdoll)
        for i = #AllInstance, 1, -1 do
            local fkm = AllInstance[i]
            if IsValid(fkm) then
                if fkm:IsRun() and fkm:GetExecute() and fkm:Cover(ragdoll) then
                    ragdoll:fkmd_Play('flesh', true, 0.5)
                    return
                end
            else
                table.remove(AllInstance, i)
            end
        end
    end)
end

if SERVER then 
    local KillAnimPlayInServer = fkmd_PlayInServer
    hook.Add('CreateEntityRagdoll', 'fkm_kill_anim', function(entity, ragdoll)
        for i = #AllInstance, 1, -1 do
            local fkm = AllInstance[i]
            if IsValid(fkm) then
                if fkm:IsRun() and fkm:GetExecute() and fkm:Cover(ragdoll) then
                    KillAnimPlayInServer(ragdoll, 0.5)
                    return
                end
            else
                table.remove(AllInstance, i)
            end
        end
    end)
end

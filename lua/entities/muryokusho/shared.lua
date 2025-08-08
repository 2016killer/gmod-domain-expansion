ENT.Type = 'anim'
ENT.Base = 'dm_base'

ENT.ClassName = 'muryokusho'
ENT.PrintName = 'Muryokusho' 
ENT.Category = 'Domain'
ENT.Author = 'Zack'
ENT.Spawnable = true


CreateConVar('mryks_ka', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('mryks_damage', '200', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('mryks_damage_brain', '10', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('mryks_sleep_max', '60', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateClientConVar('mryks_particle_level', '0.5', true, false)

local mryks_expand_speed = CreateConVar('mryks_expand_speed', '2000', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })


if CLIENT then
    local phrase = language.GetPhrase

    hook.Add('PopulateToolMenu', 'mryks_menu', function()
        spawnmenu.AddToolMenuOption('Utilities', 
            phrase('mryks.menu.category'),
            'mryks_menu', 
            phrase('mryks.menu.name'), '', '', 
            function(panel)
                panel:Clear()
                local ctrl = vgui.Create('ControlPresets', panel)
			    ctrl:SetPreset('mryks_menu')
                    ctrl:AddConVar('mryks_ka')
                    ctrl:AddConVar('mryks_damage')
                    ctrl:AddConVar('mryks_damage_brain')
                    ctrl:AddConVar('mryks_sleep_max')
                    ctrl:AddConVar('mryks_expand_speed')
                panel:AddPanel(ctrl)

                panel:NumSlider(phrase('mryks.var.ka'), 'mryks_ka', 0, 50, 0)
                panel:Help(phrase('mryks.help.ka'))
                panel:NumSlider(phrase('mryks.var.damage'), 'mryks_damage', 0, 5000, 0)
                panel:Help(phrase('mryks.help.damage'))
                panel:NumSlider(phrase('mryks.var.damage_brain'), 'mryks_damage_brain', 0, 50, 0)
                panel:Help(phrase('mryks.help.damage_brain'))
                panel:NumSlider(phrase('mryks.var.sleep_max'), 'mryks_sleep_max', 0, 120, 0)
                panel:NumSlider(phrase('mryks.var.expand_speed'), 'mryks_expand_speed', 0, 5000, 0)
                panel:Help(phrase('mryks.help.expand_speed'))
                panel:NumSlider(phrase('mryks.var.particle_level'), 'mryks_particle_level', 0, 1, 3)

            end
        )
    end)
end

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    local expandSpeed = mryks_expand_speed:GetFloat()
    if expandSpeed > 0 then
        self.expandSpeed = expandSpeed
    end
end

hook.Add('PreDomainExpand', 'mryks_condition', function(ply, dotype)
    if dotype == 'muryokusho' and not IsValid(ply:GetWeapon('w_muryokusho')) then
        if CLIENT then ply:EmitSound('Weapon_AR2.Empty') end
        return true
    end
end)
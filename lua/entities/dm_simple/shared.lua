ENT.Type = 'anim'
ENT.Base = 'dm_base'

ENT.ClassName = 'dm_simple'
ENT.PrintName = 'Simple'
ENT.Category = 'Domain'
ENT.Author = 'Zack'
ENT.Spawnable = true

CreateConVar('dm_simple_rcost', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
CreateConVar('dm_simple_radius', '250', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

if CLIENT then
    local phrase = language.GetPhrase

    hook.Add('PopulateToolMenu', 'dm_simple_menu', function()
        spawnmenu.AddToolMenuOption('Utilities', 
            phrase('dm.menu.category'),
            'dm_simple_menu', 
            phrase('dm.menu.simple.name'), '', '', 
            function(panel)
                panel:Clear()
                local ctrl = vgui.Create('ControlPresets', panel)
			    ctrl:SetPreset('dm_simple_menu')
                    ctrl:AddConVar('dm_simple_rcost')
                    ctrl:AddConVar('dm_simple_radius')
                panel:AddPanel(ctrl)
                
                panel:NumSlider(phrase('dm.var.simple_rcost'), 'dm_simple_rcost', 0, 10, 0)
                panel:NumSlider(phrase('dm.var.simple_radius'), 'dm_simple_radius', 0, 1000, 0)
            end
        )
    end)
end

function ENT:RunCall(dt)
    local owner = self:GetOwner()
    if IsValid(owner) then self:Move(owner:GetPos()) end
end

ENT.BornCall, ENT.BreakCall = ENT.RunCall, ENT.RunCall


function ENT:OnRemove()
    -- 不产生熔断
    -- 外壳移除
    if CLIENT then
        for _, shell in pairs(self.shells) do
            if IsValid(shell.ent) then shell.ent:Remove() end
        end
    end
end

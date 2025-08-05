ENT.Type = 'anim'
ENT.Base = 'domain_base'

ENT.ClassName = 'fukuma'
ENT.PrintName = 'Fukuma' 
ENT.Category = 'Domain'
ENT.Spawnable = true


if CLIENT then
    local phrase = language.GetPhrase

    hook.Add('PopulateToolMenu', 'fkm', function()
        spawnmenu.AddToolMenuOption('Utilities', 
            phrase('fkm.menu.category'),
            'fkm', 
            phrase('fkm.menu.name'), '', '', 
            function(panel)
                panel:Clear()
   
                panel:NumSlider(phrase('fkm.var.ka'), 'fkm_ka', 0, 50, 3)
                panel:Help(phrase('fkm.help.ka'))
                panel:NumSlider(phrase('fkm.var.kh'), 'fkm_kh', 0, 50, 3)
                panel:Help(phrase('fkm.help.kh'))
            end
        )
    end)
end

local fkm_ka = CreateConVar('fkm_ka', '2.5', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local fkm_kh = CreateConVar('fkm_kh', '5', { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

if SERVER then
    function ENT:Cost(radius, dt)
        local owner = self:GetOwner()
        if self.caAcc == nil then self.caAcc = 0 end
        if self.chAcc == nil then self.chAcc = 0 end

        self.caAcc = self.caAcc + fkm_ka:GetFloat() * radius * 0.00390625 * dt 
        self.chAcc = self.chAcc + fkm_kh:GetFloat() * dt

        local costArmor = math.floor(self.caAcc)
        local costHealth = math.floor(self.chAcc)
        if costArmor > 0 then
            self.caAcc = self.caAcc - costArmor
        end
        if costHealth > 0 then
            self.chAcc = self.chAcc - costHealth
        end

        return costArmor, costHealth
    end

end
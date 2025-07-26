ENT.Type = 'anim'
ENT.Base = 'ryoiki_base'

ENT.ClassName = 'fukuma_mizushi'
ENT.PrintName = 'Fukuma Mizushi' 
ENT.Category = 'ryoiki'
ENT.Spawnable = true

// weapons/crossbow/bolt_fly4.wav
// weapons/flashbang/flashbang_explode2.wav
// weapons/fx/nearmiss/bulletltor03.wav
function ENT:Run(ents)
    -- 领域效果
    if SERVER then
        local dmginfo = DamageInfo()
        dmginfo:SetDamage(10)
        dmginfo:SetAttacker(self) 
        dmginfo:SetInflictor(self) 
        dmginfo:SetDamageType(DMG_BULLET)
        dmginfo:SetDamageForce(VectorRand() * 500)

        for _, ent in ipairs(ents) do  
            ent:TakeDamageInfo(dmginfo)
            ent:TakeDamageInfo(dmginfo)
            ent:TakeDamageInfo(dmginfo)
            ent:TakeDamageInfo(dmginfo)
        end
    end

    if CLIENT then
        local dt = FrameTime()
        local timer = (self.timerEffect or 0) + dt
        local emitter = IsValid(self.emitter) and self.emitter or ParticleEmitter(self:GetPos())
        if timer >= 0.05 then
            timer = timer - 0.05
            h2d_LineTrailSphere(
                self.radius * 2, 
                self:GetPos(), 
                emitter, 
                'h2d/laserblack', 
                30, 
                math.max(1, self.radius * 0.2), 
                10,
                0.1
            )

            h2d_LineTrailSphere(
                self.radius * 2, 
                self:GetPos(), 
                emitter, 
                'h2d/laserblack2', 
                30, 
                math.max(1, self.radius * 0.2), 
                10,
                0.1
            )
        end
        self.emitter = emitter
        self.timerEffect = timer
		
    end
end

function ShellRotate(shell) 
    local extEnt, intEnt = shell.extEnt, shell.intEnt
    extEnt:SetAngles(extEnt:GetAngles() + Angle(0, 500 * FrameTime()))
    intEnt:SetAngles(intEnt:GetAngles() + Angle(0, 500 * FrameTime()))
end

function ENT:Initialize() 
    self.BaseClass.Initialize(self)
    if CLIENT then
        self.shells = {
            [RYOIKI_STATE_EXPAND] = {
                extMaterial = 'ryoiki/black',
                intMaterial = 'ryoiki/black',
    
                progress = 0
            },
            [RYOIKI_STATE_RUN] = {
                extMaterial = 'models/shadertest/shader3',
                intMaterial = 'models/shadertest/shader3',
    
                progress = 0,
                custom = ShellRotate
            }
        }

        self.shellFadeInSpeed = 1
        self.shellFadeOutSpeed = 1
    end
end



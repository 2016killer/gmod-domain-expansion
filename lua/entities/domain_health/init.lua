AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')


function ENT:Effect(owner, entsIn, dt)
    -- 领域效果
    local flag = false
    table.insert(entsIn, owner)
    for _, ent in pairs(entsIn) do
        if ent:IsPlayer() or ent:IsNPC() then
            ent:SetHealth(ent:Health() + 30)
            flag = true
        end
    end
    if flag then self:EmitSound("items/smallmedkit1.wav") end
end

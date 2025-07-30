AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')


function ENT:Impact(owner, entsIn, dt)
    table.insert(entsIn, owner)
    for _, ent in pairs(entsIn) do
        if ent:IsPlayer() or ent:IsNPC() then
            ent:SetHealth(ent:Health() + 30)
        end
    end
end

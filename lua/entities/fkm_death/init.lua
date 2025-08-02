AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
concommand.Add('test', function(ply)
    local tr = ply:GetEyeTrace()
    local ent = tr.Entity
    local phy = ent:GetPhysicsObject()
    print(phy:GetMaterial())
    
end)



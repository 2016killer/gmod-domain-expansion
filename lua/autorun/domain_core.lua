if SERVER then
    util.AddNetworkString('domain_expand')

    net.Receive('domain_expand', function(len, ply)

        local center = ply:GetPos()
        local entity = ents.Create('fukuma_mizushi')
        entity:SetPos(center)
        entity:SetAngles(Angle(0, 0, 0))
        entity:Spawn()
        entity:SetOwner(ply)
        print(entity:GetOwner())
        print(entity:GetNWEntity('owner'))
        // return self:GetNWEntity('owner')
    end)
end
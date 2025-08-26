if SERVER then

    concommand.Add('fkmd_debug_play_sv', function(ply)
        local ent = ply:GetEyeTrace().Entity
        fkmd_PlayInServer({ent}, 1)
    end)

    concommand.Add('fkmd_debug_play_sv', function(ply, cmd, args)
        local duration = args[1] or 1
        local ent = ply:GetEyeTrace().Entity
        fkmd_PlayInServer({ent}, duration)
    end)
end

if CLIENT then  

    concommand.Add('fkmd_debug_play', function(ply, cmd, args)
        local matType = args[1] or 'Metal'
        local duration = args[2] or 1
        local ent = LocalPlayer():GetEyeTrace().Entity
        ent:fkmd_Play(matType, true, duration)
    end)
end
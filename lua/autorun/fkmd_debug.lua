if SERVER then

    concommand.Add('fkmd_debug_play_sv', function(ply)
        local ent = ply:GetEyeTrace().Entity
        fkmd_PlayInServer({ent}, 1)
    end)

    concommand.Add('fkmd_debug_play_sv', function(ply)
        local ent = ply:GetEyeTrace().Entity
        fkmd_PlayInServer(ent, 1)
    end)
end

if CLIENT then  

    concommand.Add('fkmd_debug_play', function()
        local ent = LocalPlayer():GetEyeTrace().Entity
        ent:fkmd_Play('Metal')
    end)
end
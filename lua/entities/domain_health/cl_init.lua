include('shared.lua')

function ENT:InitShells()
    -- (特性) 领域外壳
    -- material 材质
    -- fadeInSpeed 淡入速度
    -- fadeOutSpeed 淡出速度
    -- progress 进度
    self.shells = {
        [RYOIKI_STATE_EXPAND] = {material = 'domain/white'},
        [RYOIKI_STATE_RUN] = {material = 'models/props_combine/portalball001_sheet'},
        [RYOIKI_STATE_BREAK] = {material = 'domain/white'}
    }
end
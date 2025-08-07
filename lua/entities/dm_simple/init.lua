AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')


local dm_simple_rcost = CreateConVar('dm_simple_rcost', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local dm_simple_radius = CreateConVar('dm_simple_radius', '250', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

local function donothing() end

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self:SetExecute(false)
    self.SetExecute = donothing
    self:SetTRadius(math.max(dm_simple_radius:GetFloat(), 1))
    self.SetTRadius = donothing
    self.restingCost = math.max(dm_simple_rcost:GetFloat(), 0)
end

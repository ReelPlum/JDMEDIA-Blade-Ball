--[[
EquipmentController
2023, 10, 31
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local EquipmentController = knit.CreateController({
  Name = 'EquipmentController', 
  Signals = {
  }
})

function EquipmentController:KnitStart()
  
end

function EquipmentController:KnitInit()
  
end

return EquipmentController
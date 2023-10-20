--[[
ClientController
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local ClientController = knit.CreateController({
  Name = 'ClientController', 
  Signals = {
  }
})

function ClientController:KnitStart()
  
end

function ClientController:KnitInit()
  
end

return ClientController
--[[
GamePassAd
2023, 11, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local GamePassAd = {}
GamePassAd.ClassName = 'GamePassAd'
GamePassAd.__index = GamePassAd

function GamePassAd.new(itemsPage)
  local self = setmetatable({}, GamePassAd)
  
  self.Janitor = janitor.new()
  
  self.itemsPage = itemsPage
  
  self.Signals = {
    Destroying = self.Janitor:Add(signal.new())
  }
  
  return self
end

function GamePassAd:Destroy()
  self.Signals.Destroying:Fire()
  self.Janitor:Destroy()
  self = nil
end

return GamePassAd
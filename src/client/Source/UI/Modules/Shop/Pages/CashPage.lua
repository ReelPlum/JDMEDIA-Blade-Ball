--[[
CashPage
2023, 11, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local CashPage = {}
CashPage.ClassName = 'CashPage'
CashPage.__index = CashPage

function CashPage.new()
  local self = setmetatable({}, CashPage)
  
  self.Janitor = janitor.new()
  
  
  
  self.Signals = {
    Destroying = self.Janitor:Add(signal.new())
  }
  
  return self
end

function CashPage:SetVisible(bool)
  
end

function CashPage:Destroy()
  self.Signals.Destroying:Fire()
  self.Janitor:Destroy()
  self = nil
end

return CashPage
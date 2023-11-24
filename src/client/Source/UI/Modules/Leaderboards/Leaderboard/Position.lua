--[[
Position
24, 11, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Position = {}
Position.ClassName = 'Position'
Position.__index = Position

function Position.new(leaderboardClass, index)
    local self = setmetatable({}, Position)
    
    self.Janitor = janitor.new()
    
    self.Leaderboard = leaderboardClass
    self.Index = index

    self.Signals = {
        Destroying = self.Janitor:Add(signal.new()),
    }
    
    
    return self
end

function Position:Init()
    --Create UI
end

function Position:Update(userId, value)
    --Update with new data
end

function Position:Destroy()
    self.Signals.Destroying:Fire()
    self.Janitor:Destroy()
    self = nil
end

return Position
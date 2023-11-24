--[[
Leaderboard
24, 11, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local PositionClass = require(script.Position)

local Leaderboard = {}
Leaderboard.ClassName = 'Leaderboard'
Leaderboard.__index = Leaderboard

function Leaderboard.new(instance, leaderboard)
    local self = setmetatable({}, Leaderboard)
    
    self.Janitor = janitor.new()
    
    self.Instance = instance
    self.Leaderboard = leaderboard

    self.Signals = {
        Destroying = self.Janitor:Add(signal.new()),
    }
    
    
    return self
end

function Leaderboard:Init()
    --Base UI

    --Listen for updates
end

function Leaderboard:Update()
    --Updates leaderboard with up to date data
end

function Leaderboard:Destroy()
    self.Signals.Destroying:Fire()
    self.Janitor:Destroy()
    self = nil
end

return Leaderboard
--[[
CharacterService
07, 01, 2024
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local CharacterService = knit.CreateService({
    Name = 'CharacterService',
    Client = {
        ShareLookAt = knit.CreateUnreliableSignal()
    },
    Signals = {
    },
})

function CharacterService:KnitStart()
    CharacterService.Client.ShareLookAt:Connect(function(player, vector)
        vector = Vector3.new(vector.X, vector.Y, math.min(vector.Z, 0))

        CharacterService.Client.ShareLookAt:FireAll(player, vector)
    end)
end

function CharacterService:KnitInit()
end

return CharacterService
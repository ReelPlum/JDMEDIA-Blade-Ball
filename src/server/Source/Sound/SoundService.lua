--[[
SoundService
2023, 10, 22
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local SoundService = knit.CreateService({
	Name = "SoundService",
	Client = {},
	Signals = {},
})

function SoundService:PlaySoundOnPart(sound, part)
	local clone = sound:Clone()

	clone.Parent = part

	clone.Ended:Connect(function()
		task.wait(0.5)
		clone:Destroy()
	end)

	clone:Play()
end

function SoundService:KnitStart() end

function SoundService:KnitInit() end

return SoundService

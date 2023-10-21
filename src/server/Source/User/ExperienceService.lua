--[[
ExperienceService
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ExperienceLevelsData = require(ReplicatedStorage.Data.ExperienceLevels)

local ExperienceService = knit.CreateService({
	Name = "ExperienceService",
	Client = {
		Level = knit.CreateProperty(nil),
	},
	Signals = {},
})

local function GetMatchingLevel(experience)
	local current = 0
	for requiredExperience, data in ExperienceLevelsData do
		if experience > requiredExperience then
			current = requiredExperience
			continue
		end

		break
	end

	return current
end

function ExperienceService:GetUsersExperienceLevel(user)
	--Gets users experience level
	local CurrencyService = knit.GetService("CurrencyService")
	local experience = CurrencyService:GetCurrency(user, "Experience")
end

function ExperienceService:KnitStart() end

function ExperienceService:KnitInit() end

return ExperienceService

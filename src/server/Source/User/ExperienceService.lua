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
		Level = knit.CreateProperty({}),
	},
	Signals = {
		UserLevelledUp = signal.new(),
	},
})

function ExperienceService:CheckUserForRankup(user)
	--
	local exp = ExperienceService:GetUsersExperience(user)
	local nextLvl = ExperienceService:GetNextLevel(user)

	if not nextLvl then
		return
	end

	local CurrencyService = knit.GetService("CurrencyService")
	if exp >= nextLvl.RequiredExperience then
		--Rank up
		local StatsService = knit.GetService("StatsService")
		StatsService:IncrementStat(user, "Level", 1)

		ExperienceService.Signals.UserLevelledUp:Fire(user)
		CurrencyService:TakeCurrency(user, "Experience", nextLvl.RequiredExperience, true)
		ExperienceService:SyncUsersLevel(user)
		return
	end
end

function ExperienceService:SetLevel(user, level)
	local CurrencyService = knit.GetService("CurrencyService")
	CurrencyService:WipeCurrency(user, "Experience")

	local StatsService = knit.GetService("StatsService")
	StatsService:SetStat(user, "Level", level)

	ExperienceService:SyncUsersLevel(user)

	ExperienceService.Signals.UserLevelledUp:Fire(user)
end

function ExperienceService:GetNextLevel(user)
	return ExperienceLevelsData[ExperienceService:GetUsersLevel(user) + 1]
end

function ExperienceService:GetUsersExperience(user)
	local CurrencyService = knit.GetService("CurrencyService")

	return CurrencyService:GetCurrency(user, "Experience")
end

function ExperienceService:GetUsersLevel(user)
	user:WaitForDataLoaded()

	local StatsService = knit.GetService("StatsService")
	return StatsService:GetStat(user, "Level")
end

function ExperienceService:SyncUsersLevel(user)
	local levels = ExperienceService.Client.Level:Get()

	levels[user.Player.UserId] = ExperienceService:GetUsersLevel(user)

	ExperienceService.Client.Level:Set(levels)
end

function ExperienceService:KnitStart()
	local CurrencyService = knit.GetService("CurrencyService")
	local UserService = knit.GetService("UserService")

	CurrencyService.Signals.UsersCurrenciesChanged:Connect(function(user, currency)
		if currency == "Experience" then
			self:CheckUserForRankup(user)
		end
	end)

	for _, user in UserService:GetUsers() do
		ExperienceService:SyncUsersLevel(user)
	end

	UserService.Signals.UserAdded:Connect(function(user)
		--	ExperienceService:CheckUserForRankup(user)
		ExperienceService:SyncUsersLevel(user)
	end)

	UserService.Signals.UserRemoving:Connect(function(user)
		local levels = ExperienceService.Client.Level:Get()
		levels[user.Player.UserId] = nil
		ExperienceService.Client.Level:Set(levels)
	end)
end

function ExperienceService:KnitInit() end

return ExperienceService

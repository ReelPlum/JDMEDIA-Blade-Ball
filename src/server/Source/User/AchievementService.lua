--[[
AchievementService
2023, 12, 10
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local AchievementData = ReplicatedStorage.Data.Achievements

local AchievementService = knit.CreateService({
	Name = "AchievementService",
	Client = {
		AchievementCompleted = knit.CreateSignal(),
		AchievementIncremented = knit.CreateSignal(),
	},
	Signals = {
		AchievementCompleted = signal.new(),
	},
})

local AvailableAchievementCache = {}

function AchievementService.Client:GetAchievements(player)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	return AchievementService:GetUsersAchievements(user)
end

function AchievementService:GetAchievementData(achievement)
	if not achievement then
		return nil
	end
	local data = AchievementData:FindFirstChild(achievement)

	if not data then
		return nil
	end
	if not data:IsA("ModuleScript") then
		return nil
	end
	return require(data)
end

function AchievementService:GetUsersAchievements(user)
	--Return completed achievements, and current progress
	user:WaitForDataLoaded()

	return user.Data.Achievements.Progress, user.Data.Achievements.Completed
end

function AchievementService:HasUserCompletedAchievement(user, achievement)
	user:WaitForDataLoaded()

	if not table.find(user.Data.Achievements.Completed, achievement) then
		return false
	end

	return true
end

function AchievementService:GetAvailableAchiementsForUser(user)
	local available = {}

	for _, module in AchievementData:GetChildren() do
		if not module:IsA("ModuleScript") then
			continue
		end

		local data = require(module)

		if AchievementService:HasUserCompletedAchievement(user, module.Name) then
			continue
		end

		local isAvailable = true

		for _, requiredAchievement in data.RequiredAchievements do
			if not AchievementService:HasUserCompletedAchievement(user, requiredAchievement) then
				isAvailable = false
				break
			end
		end

		if not isAvailable then
			continue
		end

		available[module.Name] = data
	end

	return available
end

function AchievementService:IncrementAchievementsWithStat(user, stat, amount)
	if not AvailableAchievementCache[user] then
		AvailableAchievementCache[user] = AchievementService:GetAvailableAchiementsForUser(user)
	end

	user:WaitForDataLoaded()

	local changed = false
	for name, data in AvailableAchievementCache[user] do
		local completed = true
		local incremented = false

		for statIndex, goal in data.Goals do
			if goal.Stat == stat then
				--Increment stat
				local progress = {}
				if user.Data.Achievements.Progress[name] then
					progress = user.Data.Achievements.Progress[name]
				end

				if not progress[statIndex] then
					progress[statIndex] = 0
				end

				progress[statIndex] += amount
				incremented = true
			end

			if not user.Data.Achievements.Progress[name] then
				completed = false
				continue
			end
			if not user.Data.Achievements.Progress[name][statIndex] then
				completed = false
				continue
			end
			if not (user.Data.Achievements.Progress[name][statIndex] >= goal.Amount) then
				completed = false
				continue
			end
		end

		if completed then
			--Give items
			for _, reward in data.Rewards do
				if reward.Type == "Item" then
					local ItemService = knit.GetService("ItemService")

					ItemService:GiveUserItem(user, reward.Item, 1, reward.Metadata)
				elseif reward.Type == "Currency" then
					local CurrencyService = knit.GetService("CurrencyService")
					CurrencyService:GiveCurrency(user, reward.Currency, reward.Amount)
				else
					warn("Did not find achievement reward type " .. reward.Type)
					return nil
				end
			end

			--Save completion
			table.insert(user.Data.Achievements.Completed, name)
			AchievementService.Client.AchievementCompleted:Fire(user.Player, name)

			changed = true
		elseif incremented then
			AchievementService.Client.AchievementIncremented:Fire(
				user.Player,
				name,
				user.Data.Achievements.Progress[name]
			)
		end
	end

	if changed then
		AvailableAchievementCache[user] = AchievementService:GetAvailableAchiementsForUser(user)
	end
end

function AchievementService:KnitStart()
	local StatsService = knit.GetService("StatsService")

	StatsService.Signals.StatIncremented:Connect(function(user, stat, amount)
		AchievementService:IncrementAchievementsWithStat(user, stat, amount)
	end)
end

function AchievementService:KnitInit() end

return AchievementService

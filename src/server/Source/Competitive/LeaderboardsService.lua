--[[
LeaderboardsService
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStoreService = game:GetService("DataStoreService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local LocalLeaderboard = require(script.Parent.LocalLeaderboard)

local LeaderboardsData = require(ReplicatedStorage.Data.LeaderboardsData)

local LeaderboardsService = knit.CreateService({
	Name = "LeaderboardsService",
	Client = {
		Leaderboards = knit.CreateProperty({}),
	},
	Signals = {},
})

local LocalLeaderboards = {}

function LeaderboardsService:GetTimeTillExpiration(leaderboard)
	local data = LeaderboardsData[leaderboard]
	if not data then
		return
	end

	if data.Type == "Daily" then
		--Get daily datastore
		local date = os.date("!*t")
		local dayTime = date.hour * 60 * 60 + date.min * 60 + date.sec

		print(date.hour, date.min, date.sec)

		return (24 * 60 * 60 + 60 * 60 + 60) - dayTime
	elseif data.Type == "Weekly" then
		--Get weekly datastore
		local date = os.date("!*t")
		local dayTime = date.hour * 60 * 60 + date.min * 60 + date.sec

		local timeLeftOfDay = 24 * 60 * 60 + 60 * 60 + 60 - dayTime

		local dayLeftOfWeek = 7 - (date.wday + 1)

		return math.max(dayLeftOfWeek, 0) * (24 * 60 * 60 + 60 * 60 + 60) + timeLeftOfDay
	end
end

function LeaderboardsService:GetLeaderboard(leaderboard)
	local data = LeaderboardsData[leaderboard]
	if not data then
		return
	end

	local datastore
	local t

	if data.Type == "Daily" then
		--Get daily datastore
		datastore = MemoryStoreService:GetSortedMap(leaderboard .. "-Daily")
		t = "Memory"
	elseif data.Type == "Weekly" then
		--Get weekly datastore
		datastore = MemoryStoreService:GetSortedMap(leaderboard .. "-Weekly")
		t = "Memory"
	elseif data.Type == "Monthly" then
		--Get monthly datastore
		local date = os.date("!*t")
		local id = date.year .. "/" .. date.month

		datastore = DataStoreService:GetOrderedDataStore(leaderboard .. "-Monthly" .. id)
		t = "DataStore"
	elseif data.Type == "AllTime" then
		--Get alltime data store
		datastore = DataStoreService:GetOrderedDataStore(leaderboard .. "-AllTime")
		t = "DataStore"
	elseif data.Type == "ServerOnly" then
		--Return server local leaderboard

		datastore = LocalLeaderboards[leaderboard]
		t = "Local"
	end

	return datastore, t
end

function LeaderboardsService:GetLeaderboardTop(leaderboard)
	--Gets the leaderboard top
	local datastore, Type = LeaderboardsService:GetLeaderboard(leaderboard)

	if Type == "Memory" then
		--Memory store
		local success, range = pcall(function()
			return datastore:GetRangeAsync(Enum.SortDirection.Descending, 50)
		end)
		if not success then
			return warn("Something went wrong while getting top for leaderboard " .. range)
		end

		local items = {}
		for i, item in range do
			items[i] = {
				Value = item.value,
				Key = item.key,
			}
		end

		return items
	elseif Type == "DataStore" then
		--Datastore
		local success, pages = pcall(function()
			return datastore:GetSortedAsync(false, 50)
		end)
		if not success then
			return warn("Something went wrong while getting top for leaderboard " .. pages)
		end

		local items = {}

		for i, item in pages:GetCurrentPage() do
			items[i] = {
				Value = item.value,
				Key = item.key,
			}
		end

		return items
	elseif Type == "Local" then
		local top = datastore:GetTop()

		local items = {}
		for i, item in top do
			items[i] = {
				Value = item.value,
				Key = item.key,
			}
		end

		return items
	end
end

function LeaderboardsService:SyncLeaderboard(leaderboard)
	--Syncs leaderboard
	local cache = LeaderboardsService.Client.Leaderboards:Get()

	cache[leaderboard] = LeaderboardsService:GetLeaderboardTop(leaderboard)

	LeaderboardsService.Client.Leaderboards:Set(cache)
end

function LeaderboardsService:IncrementLeaderboard(leaderboard, user, increment)
	local datastore, Type = LeaderboardsService:GetLeaderboard(leaderboard)

	if not datastore then
		return warn("No datastore found")
	end

	if Type == "DataStore" then
		local success, msg = pcall(function()
			datastore:IncrementAsync(user.Player.UserId, increment)
		end)
		if not success then
			warn("Failed to write to leaderboard " .. msg)
		end
	elseif Type == "Memory" then
		local timeLeft = LeaderboardsService:GetTimeTillExpiration(leaderboard)

		local success, msg = pcall(function()
			datastore:UpdateAsync(user.Player.UserId, function(data)
				if not data then
					data = 0
				end
				data += increment

				return data, data
			end, timeLeft)
		end)

		if not success then
			warn("Failed to write to leaderboard " .. msg)
		end
	end
end

function LeaderboardsService:WriteToLeaderboard(leaderboard, user, value)
	local datastore, Type = LeaderboardsService:GetLeaderboard(leaderboard)

	if not datastore then
		return
	end

	if Type == "DataStore" then
		local success, msg = pcall(function()
			datastore:UpdateAsync(user.Player.UserId, function(data)
				return value
			end)
		end)

		if not success then
			warn("Failed to write to leaderboard " .. msg)
		end
	elseif Type == "Memory" then
		local timeLeft = LeaderboardsService:GetTimeTillExpiration(leaderboard)

		local success, msg = pcall(function()
			datastore:UpdateAsync(user.Player.UserId, function(data)
				return value, value
			end, timeLeft)
		end)
		if not success then
			warn("Failed to write to leaderboard " .. msg)
		end
	elseif Type == "Local" then
		datastore:UpdateUser(user)
		return
	end
end

function LeaderboardsService:KnitStart()
	local StatsService = knit.GetService("StatsService")

	for leaderboard, data in LeaderboardsData do
		if data.Type == "ServerOnly" then
			LocalLeaderboards[leaderboard] = LocalLeaderboard.new(leaderboard)

			LocalLeaderboards[leaderboard].Signals.Updated:Connect(function()
				LeaderboardsService:SyncLeaderboard(leaderboard)
			end)
		end

		LeaderboardsService:SyncLeaderboard(leaderboard)

		--Listen for stat increase
		StatsService.Signals.StatUpdated:Connect(function(user, stat, increment)
			if stat == data.Stat then
				--Update
				if data.Type == "Weekly" or data.Type == "Monthly" or data.Type == "Daily" then
					LeaderboardsService:IncrementLeaderboard(leaderboard, user, increment)
				else
					LeaderboardsService:WriteToLeaderboard(leaderboard, user, StatsService:GetStat(user, stat))
				end
			end
		end)
	end

	local lastUpdate = tick()
	RunService.Heartbeat:Connect(function(deltaTime)
		if tick() - lastUpdate >= 60 then
			--Update
			lastUpdate = tick()

			for leaderboard, _ in LeaderboardsData do
				LeaderboardsService:SyncLeaderboard(leaderboard)
			end
		end
	end)
end

function LeaderboardsService:KnitInit() end

return LeaderboardsService

--[[
AdminService
2023, 10, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local cmdr = require(ReplicatedStorage.Packages.Cmdr)

local TimeFormat = require(ReplicatedStorage.Common.TimeFormat)

local AdminService = knit.CreateService({
	Name = "AdminService",
	Client = {},
	Signals = {},
})

function AdminService:WipeUser(userId, reason) end

function AdminService:MuteUser(userId, t, reason) end

function AdminService:UnbanUser(userId)
	--Get datastore and ban them that way
	local DataService = knit.GetService("DataService")

	local DataStore = DataStoreService:GetDataStore(DataService:GetDataStoreName())
	local success, msg = pcall(function()
		DataStore:UpdateAsync(DataService:GetPlayersKey(userId), function(data)
			if not data then
				return data
			end
			if not data.Data then
				return data
			end

			data.Data.Moderation.CurrentBan = nil

			return data
		end)
	end)
	if not success then
		warn(msg)
		return msg
	end

	return true
end

function AdminService:BanUser(userId, t, reason)
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromUserId(userId)
	if user then
		--Ban user like this
		user:WaitForDataLoaded()

		user.Data.Moderation.CurrentBan = {
			Time = DateTime.now().UnixTimestamp + t,
			Reason = reason,
		}

		AdminService:IsUserBanned(user)

		return true
	end

	--Get datastore and ban them that way
	local DataService = knit.GetService("DataService")

	local DataStore = DataStoreService:GetDataStore(DataService:GetDataStoreName())
	local success, msg = pcall(function()
		DataStore:UpdateAsync(DataService:GetPlayersKey(userId), function(data)
			if not data then
				return data
			end
			if not data.Data then
				return data
			end

			data.Data.Moderation.CurrentBan = {
				Time = DateTime.now().UnixTimestamp + t,
				Reason = reason,
			}

			return data
		end)
	end)
	if not success then
		warn(msg)
		return msg
	end

	MessagingService:PublishAsync("Ban", userId)

	return true
end

function AdminService:IsUserMuted(user) end

function AdminService:IsUserBanned(user)
	user:WaitForDataLoaded()

	--Check time
	local currentBan = user.Data.Moderation.CurrentBan
	if not currentBan then
		return
	end

	if currentBan.Time < DateTime.now().UnixTimestamp then
		user.Data.Moderation.CurrentBan = nil
		return
	end

	local t = currentBan.Time - DateTime.now().UnixTimestamp
	t = math.max(t, 0)

	user.Player:Kick(
		`You were banned for the reason: {currentBan.Reason}. \n Come back in {TimeFormat.FormatSeconds(t)}`
	)
end

function AdminService:KnitStart()
	local UserService = knit.GetService("UserService")

	for _, user in UserService:GetUsers() do
		AdminService:IsUserBanned(user)
	end

	UserService.Signals.UserAdded:Connect(function(user)
		AdminService:IsUserBanned(user)
	end)

	MessagingService:SubscribeAsync("Ban", function(data)
		local user = UserService:GetUserFromUserId(data.Data)
		if not user then
			return
		end

		AdminService:IsUserBanned(user)
	end)
end

function AdminService:KnitInit()
	--Initialize CMDR
	cmdr:RegisterHooksIn(script.Parent.Hooks)
	cmdr:RegisterTypesIn(script.Parent.Types)
	cmdr:RegisterCommandsIn(script.Parent.Commands)
end

return AdminService

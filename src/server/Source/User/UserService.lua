--[[
UserService
2023, 04, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local userObj = require(script.Parent.User)

local UserService = knit.CreateService({
	Name = "UserService",
	Client = {
		AFK = knit.CreateProperty({}),
	},
	Signals = {
		UserAdded = signal.new(),
		UserRemoving = signal.new(),
	},
})

local Users = {}

function UserService.Client:Ready(player)
	local user = UserService:WaitForUser(player)

	user.Ready = true
end

function UserService:SetUserAFK(user, bool)
	user.AFK = bool

	local AFK = UserService.Client.AFK:Get()
	AFK[user.Player.UserId] = bool
	UserService.Client.AFK:Set(AFK)
end

function UserService:ListenForUserLeave(user)
	return user.Signals.Destroying
end

function UserService:WaitForUser(player: Player)
	local user = UserService:GetUserFromPlayer(player)
	if not user then
		local finished = false
		local d
		d = UserService.Signals.UserAdded:Connect(function(u)
			if u.Player == player then
				user = u
				finished = true
				d:Disconnect()
			end
		end)
		repeat
			task.wait()
		until finished == true
	end

	return user
end

function UserService:GetUserFromPlayer(player: Player)
	return Users[player] --Users are registered with their player
end

function UserService:GetUserFromUserId(id: string)
	local player = Players:GetPlayerByUserId(id)
	return Users[player]
end

function UserService:GetUserFromCharacter(character: Model)
	local player = Players:GetPlayerFromCharacter(character)
	return Users[player]
end

function UserService:GetUsers()
	return Users
end

function UserService:KnitStart() end

function UserService:KnitInit()
	--Load users
	local function UserAdded(player: Player)
		if UserService:GetUserFromPlayer(player) then
			return
		end

		Users[player] = userObj.new(player)
		UserService.Signals.UserAdded:Fire(Users[player])
	end

	local function UserRemoving(player: Player)
		local user = UserService:GetUserFromPlayer(player)

		if not user then
			return
		end

		UserService.Signals.UserRemoving:Fire(user)

		--Remove
		Users[player] = nil
		user:Destroy()
	end

	Players.PlayerAdded:Connect(UserAdded)
	Players.PlayerRemoving:Connect(UserRemoving)

	--Check if any players already joined somehow
	for _, player in Players:GetPlayers() do
		UserAdded(player)
	end
end

return UserService

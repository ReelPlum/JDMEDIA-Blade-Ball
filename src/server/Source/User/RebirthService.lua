--[[
RebirthService
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local RebirthService = knit.CreateService({
	Name = "RebirthService",
	Client = {
		Rebirths = knit.CreateProperty({}),
	},
	Signals = {
		UserRebirthed = signal.new(),
	},
})

function RebirthService:GetUsersRebirthLevel(user)
	local StatsService = knit.GetService("StatsService")

	return StatsService:GetStat(user, "Rebirth")
end

function RebirthService:Rebirth(user)
	--Rebirth user.
	local ExperienceService = knit.GetService("ExperienceService")
	if ExperienceService:GetNextLevel(user) then
		return
	end

	--User can rebirth
	local StatsService = knit.GetService("StatsService")
	StatsService:IncrementStat(user, "Rebirth", 1)

	ExperienceService:SetLevel(user, 1)

	--Open a rebirth crate
	local ShopService = knit.GetService("ShopService")
	ShopService:Unbox(user, "Rebirth")

	RebirthService.Signals.UserRebirthed:Fire(user)
end

function RebirthService:SyncRebirth(user)
	local rebirths = RebirthService.Client.Rebirths:Get()

	rebirths[user.Player.UserId] = RebirthService:GetUsersRebirthLevel(user)

	RebirthService.Client.Rebirths:Set(rebirths)
end

function RebirthService:KnitStart()
	local UserService = knit.GetService("UserService")

	for _, user in UserService:GetUsers() do
		RebirthService:SyncRebirth(user)
	end

	UserService.Signals.UserAdded:Connect(function(user)
		RebirthService:SyncRebirth(user)
	end)

	UserService.Signals.UserRemoving:Connect(function(user)
		local rebirths = RebirthService.Client.Rebirths:Get()

		rebirths[user.Player.UserId] = nil

		RebirthService.Client.Rebirths:Set(rebirths)
	end)
end

function RebirthService:KnitInit() end

return RebirthService

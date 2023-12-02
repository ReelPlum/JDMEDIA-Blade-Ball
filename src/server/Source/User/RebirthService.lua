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
		OnRebirth = knit.CreateSignal(),
	},
	Signals = {
		UserRebirthed = signal.new(),
	},
})

function RebirthService.Client:Rebirth(player)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	RebirthService:Rebirth(user)
end

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

	RebirthService.Client.OnRebirth:Fire(user.Player, RebirthService:GetUsersRebirthLevel(user))
	RebirthService.Signals.UserRebirthed:Fire(user, RebirthService:GetUsersRebirthLevel(user))
end

function RebirthService:KnitStart() end

function RebirthService:KnitInit() end

return RebirthService

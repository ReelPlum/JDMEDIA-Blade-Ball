--[[
RebirthService
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local RebirthsData = ReplicatedStorage.Data.Rebirths

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

function RebirthService:GetDataForRebirthLevel(level)
	if not level then
		return
	end

	local data = RebirthsData:FindFirstChild(level)
	if not data then
		return
	end
	if not data:IsA("ModuleScript") then
		return
	end

	return require(data)
end

function RebirthService:GetUsersRebirthLevel(user)
	local StatsService = knit.GetService("StatsService")

	return StatsService:GetStat(user, "Rebirth")
end

function RebirthService:Rebirth(user)
	--Rebirth user.
	local ExperienceService = knit.GetService("ExperienceService")
	if ExperienceService:GetNextLevel(user) then
		return warn("Not max lvl")
	end

	local rebirthLevel = RebirthService:GetUsersRebirthLevel(user)
	if not RebirthService:GetDataForRebirthLevel(rebirthLevel + 1) then
		return warn("No level")
	end

	local rebirthData = RebirthService:GetDataForRebirthLevel(rebirthLevel + 1)

	local CurrencyService = knit.GetService("CurrencyService")
	local ItemService = knit.GetService("ItemService")

	local Rewards = rebirthData.Rewards
	for _, data in Rewards do
		--Give to user
		if data.Type == "Item" then
			--Give item
			ItemService:GiveUserItem(user, data.Item.Item, data.Quantity, data.Item.Metadata)
		elseif data.Type == "Currency" then
			--Give currency
			CurrencyService:GiveCurrency(user, data.Currency, data.Amount)
		end
	end

	--User can rebirth
	local StatsService = knit.GetService("StatsService")
	StatsService:IncrementStat(user, "Rebirth", 1)

	ExperienceService:SetLevel(user, 1)

	RebirthService.Client.OnRebirth:Fire(user.Player, RebirthService:GetUsersRebirthLevel(user))
	RebirthService.Signals.UserRebirthed:Fire(user, RebirthService:GetUsersRebirthLevel(user))
end

function RebirthService:KnitStart() end

function RebirthService:KnitInit() end

return RebirthService

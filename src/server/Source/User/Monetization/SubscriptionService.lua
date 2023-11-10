--[[
SubscriptionService
2023, 11, 06
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketPlaceService = game:GetService("MarketplaceService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local SubscriptionData = require(ReplicatedStorage.Data.Monetization.SubscriptionData)

local SubscriptionService = knit.CreateService({
	Name = "SubscriptionService",
	Client = {},
	Signals = {},
})

local function CheckSubscriptionStatus(user, subscriptionData)
	if not subscriptionData then
		return
	end

	local success, result = pcall(function()
		return MarketPlaceService:GetUserSubscriptionStatusAsync(user.Player, subscriptionData.Id)
	end)

	if not success then
		warn("Failed to get subscription data " .. result)
		return
	end

	if result.IsSubscribed then
		--Grant reward
		subscriptionData.Grant(user)
		if not user.Data.Subscriptions[subscriptionData.Id] then
			user.Data.Subscriptions[subscriptionData.Id] = DateTime.now().UnixTimestamp
		end

		return
	end

	--If reward was owned then notify user and call remove subscription
	if user.Data.Subscriptions[subscriptionData.Id] then
		--Notify

		--Revoke
		subscriptionData.Revoke(user)
	end

	user.Data.Subscriptions[subscriptionData.Id] = nil
end

local function GetSubscriptionData(subscriptionId)
	for _, data in SubscriptionData do
		if data.Id == subscriptionId then
			return data
		end
	end

	return nil
end

function SubscriptionService:CheckUsersSubscriptions(user)
	--Get all active subscriptions for user
	for _, data in SubscriptionData do
		CheckSubscriptionStatus(user, data)
	end
end

function SubscriptionService:KnitStart()
	local UserService = knit.GetService("UserService")

	--What?
	-- MarketPlaceService.UserSubscriptionStatusChanged:Connect(function(player, subscriptionId)
	-- 	local user = UserService:WaitForUser(player)

	-- 	CheckSubscriptionStatus(user, GetSubscriptionData(subscriptionId))
	-- end)
end

function SubscriptionService:KnitInit() end

return SubscriptionService

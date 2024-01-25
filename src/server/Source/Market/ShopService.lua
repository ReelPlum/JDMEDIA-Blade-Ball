--[[
ShopService
26, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PolicyService = game:GetService("PolicyService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local promise = require(ReplicatedStorage.Packages.Promise)

local ShopData = ReplicatedStorage.Data.Shop
local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local ShopService = knit.CreateService({
	Name = "ShopService",
	Client = {
		ItemPurchased = knit.CreateSignal(),
		BundlePurchased = knit.CreateSignal(),
		UnboxablePurchased = knit.CreateSignal(),
	},
	Signals = {
		UnboxedItem = knit.CreateSignal(),
	},
})

function ShopService.Client:PurchaseItem(player, id)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	return ShopService:PurchaseItem(user, id)
end

function ShopService.Client:PurchaseBundle(player, id)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	ShopService:PurchaseBundle(user, id)
end

function ShopService:GetBundle(bundleId)
	return ShopData.Bundles[bundleId]
end

function ShopService:GetItem(itemShopId)
	if not itemShopId then
		return
	end

	local data = ShopData.Items:FindFirstChild(itemShopId)
	if not data then
		return
	end

	if not data:IsA("ModuleScript") then
		return
	end

	return require(data)
end

function ShopService:GetUnboxable(unboxableId)
	return ShopData.Unboxables[unboxableId]
end

function ShopService:PurchaseBundle(user, bundleId)
	--Makes user purchase bundle
	local data = ShopService:GetBundle(bundleId)
	if not data then
		return
	end

	local ItemService = knit.GetService("ItemService")
	local n = 0

	for _, itemData in data.Items do
		if not ItemService:CanUserRecieveItem(user, itemData.Item.Item) then
			return
		end

		n += itemData.Amount or 1
	end

	if not ItemService:DoesUserHaveSpaceForItems(user, n) then
		return warn("No space...")
	end

	if data.Price then
		local CurrencyService = knit.GetService("CurrencyService")
		if not CurrencyService:TakeCurrency(user, data.Price.Currency, data.Price.Amount) then
			return
		end
	end

	ShopService:GiveBundle(user, bundleId)
end

function ShopService:PurchaseItem(user, itemShopId)
	--Makes user purchase item
	local data = ShopService:GetItem(itemShopId)
	if not data then
		return warn("No data")
	end

	local ItemService = knit.GetService("ItemService")
	if not ItemService:DoesUserHaveSpaceForItems(user, data.Amount or 1) then
		return warn("No space")
	end

	if not ItemService:CanUserRecieveItem(user, data.Item) then
		return warn("Cannot recieve")
	end

	if data.Price then
		local CurrencyService = knit.GetService("CurrencyService")
		if not CurrencyService:TakeCurrency(user, data.Price.Currency, data.Price.Amount) then
			return warn("Not enough money")
		end
	end

	warn("Done!")

	return ShopService:GiveItem(user, itemShopId)
end

function ShopService:ArePaidRandomItemsRestricted(user)
	local success, result = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(user.Player)
	end)
	if not success then
		warn("Something went wrong while checking paid random items " .. result)
		return true
	end
	return result.ArePaidRandomItemsRestricted
end

function ShopService:GiveBundle(user, bundleId, priceInRobux)
	local data = ShopService:GetBundle(bundleId)
	if not data then
		return
	end

	local ItemService = knit.GetService("ItemService")
	for _, item in data.Items do
		local metadata = {
			[MetadataTypes.Types.OriginalPurchaser] = user.Player.UserId,
			[MetadataTypes.Types.Bundle] = bundleId,
			[MetadataTypes.Types.Robux] = priceInRobux,
		}

		for t, v in item.Metadata do
			metadata[t] = v
		end

		ItemService:GiveUserItem(user, item.Item, 1, metadata)
	end

	ShopService.Client.BundlePurchased:Fire(user.Player, bundleId)

	return true
end

function ShopService:GiveItem(user, itemShopId, priceInRobux)
	local data = ShopService:GetItem(itemShopId)
	if not data then
		return
	end

	local metadata = {
		[MetadataTypes.Types.OriginalPurchaser] = user.Player.UserId,
		[MetadataTypes.Types.Robux] = priceInRobux,
	}

	for t, v in data.Metadata or {} do
		metadata[t] = v
	end

	local ItemService = knit.GetService("ItemService")
	local items = ItemService:GiveUserItem(user, data.Item, data.Amount or 1, metadata)

	ShopService.Client.ItemPurchased:Fire(user.Player, itemShopId)

	return items
end

function ShopService:KnitStart() end

function ShopService:KnitInit() end

return ShopService

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

local ShopData = require(ReplicatedStorage.Data.ShopData)
local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local ShopService = knit.CreateService({
	Name = "ShopService",
	Client = {
		ItemPurchased = knit.CreateSignal(),
		BundlePurchased = knit.CreateSignal(),
		UnboxablePurchased = knit.CreateSignal(),
	},
	Signals = {},
})

function ShopService.Client:PurchaseItem(player, id)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	ShopService:PurchaseItem(user, id)
end

function ShopService.Client:PurchaseBundle(player, id)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	ShopService:PurchaseBundle(user, id)
end

function ShopService.Client:PurchaseUnboxable(player, id)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	ShopService:PurchaseUnboxable(user, id)
end

function ShopService:GetBundle(bundleId)
	return ShopData.Bundles[bundleId]
end

function ShopService:GetItem(itemShopId)
	return ShopData.Items[itemShopId]
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

	if not data.Price then
		return
	end

	local CurrencyService = knit.GetService("CurrencyService")
	if not CurrencyService:TakeCurrency(user, data.Price.Currency, data.Price.Amount) then
		return
	end

	ShopService:GiveBundle(user, bundleId)
end

function ShopService:PurchaseItem(user, itemShopId)
	--Makes user purchase item
	local data = ShopService:GetItem(itemShopId)
	if not data then
		return
	end

	if not data.Price then
		return
	end

	local CurrencyService = knit.GetService("CurrencyService")
	if not CurrencyService:TakeCurrency(user, data.Price.Currency, data.Price.Amount) then
		return
	end

	ShopService:GiveItem(user, itemShopId)
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

function ShopService:PurchaseUnboxable(user, unboxableId)
	--Unbox unboxable
	local data = ShopService:GetUnboxable(unboxableId)
	if not data then
		return
	end

	if not data.Price then
		return
	end

	local CurrencyService = knit.GetService("CurrencyService")
	if not CurrencyService:UserHasEnough(user, data.Price.Currency, data.Price.Amount) then
		return
	end

	local unboxedItem = ShopService:Unbox(user, unboxableId)
	if not unboxedItem then
		return
	end

	CurrencyService:TakeCurrency(user, data.Price.Currency, data.Price.Amount)
	return unboxedItem
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

		print("Giving item " .. item.Item)
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

	for t, v in data.Item.Metadata do
		metadata[t] = v
	end

	local ItemService = knit.GetService("ItemService")
	ItemService:GiveUserItem(user, data.Item.Item, 1, metadata)

	ShopService.Client.ItemPurchased:Fire(user.Player, itemShopId)

	return true
end

function ShopService:Unbox(user, unboxableId, priceInRobux)
	if ShopService:ArePaidRandomItemsRestricted(user) then
		return
	end

	local data = ShopService:GetUnboxable(unboxableId)
	if not data then
		return
	end

	if #data.DropList < 1 then
		return warn("Not enought loot to make unbox " .. unboxableId)
	end

	local weightedTable = {}
	for index, data in data.DropList do
		for i = 1, data.Weight do
			table.insert(weightedTable, index)
		end
	end

	local unboxedItem = weightedTable[math.random(1, #weightedTable)]
	local unboxedItemData = data.DropList[unboxedItem]

	warn(unboxedItem)

	if unboxedItemData.Type == "Item" then
		local ItemService = knit.GetService("ItemService")

		warn("Giving item")

		local metadata = {
			[MetadataTypes.Types.UnboxedBy] = user.Player.UserId,
			[MetadataTypes.Types.Unboxable] = unboxableId,
			[MetadataTypes.Types.Robux] = priceInRobux,
		}

		for t, v in unboxedItemData.Item.Metadata do
			metadata[t] = v
		end

		ItemService:GiveUserItem(user, unboxedItemData.Item.Item, 1, metadata)
	elseif unboxedItemData.Type == "Currency" then
		local CurrencyService = knit.GetService("CurrencyService")
		CurrencyService:GiveCurrency(user, unboxedItemData.Currency, unboxedItemData.Amount)
	else
		warn("Did not find unboxable type " .. unboxedItemData.Type)
		return nil
	end

	ShopService.Client.UnboxablePurchased:Fire(user.Player, unboxableId, unboxedItem)

	return unboxedItem
end

function ShopService:KnitStart() end

function ShopService:KnitInit() end

return ShopService

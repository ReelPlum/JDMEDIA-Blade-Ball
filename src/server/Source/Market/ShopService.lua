--[[
ShopService
26, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

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
	if not CurrencyService:TakeCurrency(user, data.Price.Currency, data.Price.Amount) then
		return
	end

	ShopService:Unbox(user, unboxableId)
end

function ShopService:GiveBundle(user, bundleId)
	local data = ShopService:GetBundle(bundleId)
	if not data then
		return
	end

	local ItemService = knit.GetService("ItemService")
	for _, item in data.Items do
		ItemService:GiveUserItem(user, item, 1, {
			[MetadataTypes.Types.OriginalPurchaser] = user.Player.UserId,
			[MetadataTypes.Types.Bundle] = bundleId,
		})
	end

	ShopService.Client.BundlePurchased:Fire(user.Player, bundleId)
end

function ShopService:GiveItem(user, itemShopId)
	local data = ShopService:GetItem(itemShopId)
	if not data then
		return
	end

	local ItemService = knit.GetService("ItemService")
	ItemService:GiveUserItem(user, data.Item, 1, {
		[MetadataTypes.Types.OriginalPurchaser] = user.Player.UserId,
	})

	ShopService.Client.ItemPurchased:Fire(user.Player, itemShopId)
end

function ShopService:Unbox(user, unboxableId)
	local data = ShopService:GetUnboxable(unboxableId)
	if not data then
		return
	end

	if #data.Loot < 1 then
		return warn("Not enought loot to make unbox " .. unboxableId)
	end

	local weightedTable = {}
	for index, data in data.Loot do
		for i = 1, data.Weight do
			table.insert(weightedTable, {
				Index = index,
				Data = data,
			})
		end
	end

	local unboxedItem = weightedTable[math.random(1, #weightedTable)]

	if unboxedItem.Data.Type == "Item" then
		local ItemService = knit.GetService("ItemService")
		ItemService:GiveUserItem(user, unboxedItem, 1, {
			[MetadataTypes.Types.UnboxedBy] = user.Player.UserId,
			[MetadataTypes.Types.Unboxable] = unboxableId,
		})
	elseif unboxedItem.Data.Type == "Currency" then
		local CurrencyService = knit.GetService("CurrencyService")
		CurrencyService:GiveCurrency(user, unboxedItem.Data.Currency, unboxedItem.Data.Amount)
	else
		warn("Did not find unboxable type " .. unboxedItem.Data.Type)
		return nil
	end

	ShopService.Client.UnboxablePurchased:Fire(user.Player, unboxedItem.Index)

	return unboxedItem
end

function ShopService:KnitStart() end

function ShopService:KnitInit() end

return ShopService

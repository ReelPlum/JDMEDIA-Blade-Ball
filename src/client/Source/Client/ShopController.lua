--[[
ShopController
27, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local ShopData = require(ReplicatedStorage.Data.ShopData)

local ShopController = knit.CreateController({
	Name = "ShopController",
	Signals = {
		Unboxed = signal.new(),
	},
})

local unboxedRequiringConfirmation = {}

function ShopController:ConfirmUnbox(unboxable)
	for index, data in unboxedRequiringConfirmation do
		if data.Unboxable == unboxable then
			ShopController.Signals.Unboxed:Fire(data.Unboxable, data.Item)
			unboxedRequiringConfirmation[index] = nil
		end
	end
end

function ShopController:GetBundle(bundleId)
	return ShopData.Bundles[bundleId]
end

function ShopController:GetItem(shopItemId)
	return ShopData.Items[shopItemId]
end

function ShopController:GetUnboxable(unboxableId)
	return ShopData.Unboxables[unboxableId]
end

function ShopController:GetLootFromUnboxable(unboxableId, lootIndex)
	local data = ShopController:GetUnboxable(unboxableId)
	if not data then
		return
	end

	return data.DropList[lootIndex]
end

function ShopController:PurchaseItem(shopItemId)
	local ShopService = knit.GetService("ShopService")
	ShopService:PurchaseItem(shopItemId)
end

function ShopController:PurchaseBundle(bundleId)
	local ShopService = knit.GetService("ShopService")
	ShopService:PurchaseBundle(bundleId)
end

function ShopController:PurchaseUnboxable(unboxableId)
	local ShopService = knit.GetService("ShopService")
	ShopService:PurchaseUnboxable(unboxableId)
end

function ShopController:GetBundlesForSale()
	local bundles = {}
	for id, data in ShopData.Bundles do
		if not data.Price then
			continue
		end

		bundles[id] = data
	end

	return bundles
end

function ShopController:GetItemsForSale()
	local items = {}
	for id, data in ShopData.Items do
		if not data.Price then
			continue
		end

		items[id] = data
	end

	return items
end

function ShopController:GetUnboxablesForSale()
	local unboxables = {}
	for id, data in ShopData.Unboxables do
		if not data.Price then
			continue
		end

		unboxables[id] = data
	end

	return unboxables
end

function ShopController:KnitStart()
	local ShopService = knit.GetService("ShopService")

	--Listen for purchased and unboxes
	ShopService.UnboxablePurchased:Connect(function(case, index)
		local data = ShopController:GetUnboxable(case)
		if data.RequiresConfirmation then
			table.insert(unboxedRequiringConfirmation, {
				Case = case,
				Item = index,
			})
			return
		end

		ShopController.Signals.Unboxed:Fire(case, index)
	end)
end

function ShopController:KnitInit() end

return ShopController

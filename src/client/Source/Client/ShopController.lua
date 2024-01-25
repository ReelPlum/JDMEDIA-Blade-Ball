--[[
ShopController
27, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local ShopData = ReplicatedStorage.Data.Shop

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
	if not bundleId then
		return
	end

	local data = ShopData.Bundles:FindFirstChild(bundleId)
	if not data then
		return
	end

	if not data:IsA("ModuleScript") then
		return
	end

	return require(data)
end

function ShopController:GetItem(shopItemId)
	if not shopItemId then
		return
	end

	local data = ShopData.Items:FindFirstChild(shopItemId)
	if not data then
		return
	end

	if not data:IsA("ModuleScript") then
		return
	end

	return require(data)
end

function ShopController:PurchaseItem(shopItemId)
	local ShopService = knit.GetService("ShopService")
	ShopService:PurchaseItem(shopItemId)
end

function ShopController:PurchaseBundle(bundleId)
	local ShopService = knit.GetService("ShopService")
	ShopService:PurchaseBundle(bundleId)
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

function ShopController:KnitInit() end

return ShopController

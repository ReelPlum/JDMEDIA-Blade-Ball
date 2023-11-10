--[[
DeveloperProductService
2023, 10, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketPlaceService = game:GetService("MarketplaceService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local StringCompress = require(ReplicatedStorage.Common.StringCompress)

local DeveloperProductData = require(ReplicatedStorage.Data.Monetization.DeveloperProductData)

local DeveloperProductService = knit.CreateService({
	Name = "DeveloperProductService",
	Client = {},
	Signals = {},
})

function DeveloperProductService:GetProduct(id)
	--Returns developer product from id
	for index, product in DeveloperProductData do
		if product.Id == id then
			return product, index
		end
	end

	return nil, nil
end

local PurchaseHistories = {}
function DeveloperProductService:GetUsersPurchaseHistory(user)
	if PurchaseHistories[user] then
		return PurchaseHistories[user]
	end

	user:WaitForDataLoaded()

	if not user.Data.PurchaseHistory then
		return {}
	end

	local DataCompressionService = knit.GetService("DataCompressionService")
	local uncompressed = DataCompressionService:DecompressData(user.Data.PurchaseHistory)

	if not uncompressed then
		return {}
	end

	return HttpService:JSONDecode(uncompressed)
end

function DeveloperProductService:SavePurchase(user, id, data)
	local PurchaseHistory = DeveloperProductService:GetUsersPurchaseHistory(user)

	PurchaseHistory[id] = data

	local DataCompressionService = knit.GetService("DataCompressionService")
	user.Data.PurchaseHistory = DataCompressionService:CompressData(HttpService:JSONEncode(PurchaseHistory))
end

function DeveloperProductService:KnitStart()
	local UserService = knit.GetService("UserService")

	UserService.Signals.UserRemoving:Connect(function(user)
		PurchaseHistories[user] = nil
	end)

	local function ProcessReciept(recieptInfo)
		--Handle DeveloperProduct purchase
		local user = UserService:GetUserFromUserId(recieptInfo.PlayerId)
		if not user then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		user:WaitForDataLoaded()

		local success, PurchaseHistory = pcall(function()
			return DeveloperProductService:GetUsersPurchaseHistory(user)
		end)
		if not success then
			warn("Failed to get purchase history for user... " .. PurchaseHistory)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		if PurchaseHistory[recieptInfo.PurchaseId] then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		local success, msg = pcall(function()
			local data = DeveloperProductService:GetProduct(recieptInfo.ProductId)
			if not data then
				error("Product not found " .. recieptInfo.ProductId)
			end
			data.OnPurchase(user)
		end)
		if not success then
			warn(msg)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		--Save it
		local data = {
			Date = DateTime.now().UnixTimestamp,
			Price = recieptInfo.CurrencySpent,
			PlaceId = recieptInfo.PlaceIdWherePurchased,
			ProductId = recieptInfo.ProductId,
		}

		local success, msg = pcall(function()
			DeveloperProductService:SavePurchase(user, recieptInfo.PurchaseId, data)
		end)
		if not success then
			warn(msg)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	MarketPlaceService.ProcessReceipt = ProcessReciept
end

function DeveloperProductService:KnitInit() end

return DeveloperProductService

--[[
DeveloperProductService
2023, 10, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketPlaceService = game:GetService("MarketplaceService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local DeveloperProductData = require(ReplicatedStorage.Data.DeveloperProductData)

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

function DeveloperProductService:KnitStart()
	local UserService = knit.GetService("UserService")

	local function ProcessReciept(recieptInfo)
		--Handle DeveloperProduct purchase
		local user = UserService:GetUserFromUserId(recieptInfo.PlayerId)
		if not user then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		user:WaitForDataLoaded()

		if user.Data.PurchaseHistory[recieptInfo.PurchaseId] then
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
		user.Data.PurchaseHistory[recieptInfo.PurchaseId] = {
			Date = DateTime.now().UnixTimestamp,
			Price = recieptInfo.CurrencySpent,
			PlaceId = recieptInfo.PlaceIdWherePurchased,
			ProductId = recieptInfo.ProductId,
		}

		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	MarketPlaceService.ProcessReceipt = ProcessReciept
end

function DeveloperProductService:KnitInit() end

return DeveloperProductService

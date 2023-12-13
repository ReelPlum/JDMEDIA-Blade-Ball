--[[
EnchantingService
2023, 11, 16
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local MetaDataTypes = require(ReplicatedStorage.Data.MetadataTypes)
local EnchantsData = require(ReplicatedStorage.Data.EnchantsData)
local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local EnchantingService = knit.CreateService({
	Name = "EnchantingService",
	Client = {
		RandomEnchant = knit.CreateProperty(nil),
	},
	Signals = {},
})

local WeightedTable = {}

function EnchantingService.Client:ApplyBookToItem(player, bookId, itemId)
	--Applies book on given item
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	EnchantingService:ApplyEnchantmentBookOnUsersItem(user, itemId, bookId)
	return true
end

function EnchantingService.Client:RandomlyEnchantItem(player, itemId)
	--Applies next "random" enchant on item
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	EnchantingService:ApplyRandomEnchantOnUsersItem(user, itemId)
	return true
end

function EnchantingService:GetEnchantData(enchant)
	return EnchantsData[enchant]
end

function EnchantingService:CanItemBeEnchanted(invItemData, enchant)
	--Check if enchantment supports the item to be enchanted
	if EnchantingService:GetEnchantOnInventoryItem(invItemData) then
		return false
	end

	local data = EnchantingService:GetEnchantData(enchant)
	if not data then
		return false
	end

	local ItemService = knit.GetService("ItemService")
	local itemData = ItemService:GetDataForItem(invItemData.Item)

	if not itemData then
		return
	end

	if not table.find(data.SupportedItemTypes, itemData.ItemType) then
		return false
	end

	return true
end

function EnchantingService:GetEnchantOnInventoryItem(invItemData)
	--Returns enchants on item
	local enchantOnItem = invItemData.Metadata[MetaDataTypes.Types.Enchant]
	if not enchantOnItem then
		return
	end

	return enchantOnItem[1], enchantOnItem[2] --Enchant, Level
end

function EnchantingService:GetEnchantOnUsersItem(user, id)
	--Get data for item and return the enchants on the item
	local ItemService = knit.GetService("ItemService")

	local data = ItemService:GetUsersDataFromId(user, id)
	if not data then
		return
	end

	return EnchantingService:GetEnchantOnInventoryItem(data)
end

function EnchantingService:ApplyEnchantOnItem(data, enchant, level)
	--Apply a enchant on a item
	local enchantData = EnchantingService:GetEnchantData(enchant)
	if not enchantData then
		return
	end

	if not EnchantingService:CanItemBeEnchanted(data, enchant) then
		return
	end

	local _, foundLevel = EnchantingService:GetEnchantOnInventoryItem(data)
	if foundLevel then
		if level ~= tonumber(foundLevel) then
			return false
		end

		if enchantData.Statistics[level + 1] then
			--Add up 1 level
			data.Metadata[MetaDataTypes.Types.Enchant][2] = level + 1
			return true
		end

		return
	end

	data.Metadata[MetaDataTypes.Types.Enchant] = { enchant, level }

	return data
end

function EnchantingService:GetRandomEnchant()
	local enchant = WeightedTable[math.random(1, #WeightedTable)]
	local enchantData = EnchantingService:GetEnchantData(enchant)
	local level = 1

	return enchant, level
end

function EnchantingService:ApplyRandomEnchantOnUsersItem(user, id)
	--Apply a random enchantment on a users item

	local ShopService = knit.GetService("ShopService")
	-- if ShopService:ArePaidRandomItemsRestricted(user) then
	-- 	return warn("Paid randomg items are restricted!")
	-- end

	local ItemService = knit.GetService("ItemService")

	local data = ItemService:GetUsersDataFromId(user, id)
	if not data then
		return warn("❗Data not found")
	end

	local enchant = user.Data.RandomEnchant

	local success = EnchantingService:ApplyEnchantOnItem(data, enchant, 1)
	if not success then
		return
	end

	user.Data.RandomEnchant = EnchantingService:GetRandomEnchant()
	EnchantingService.Client.RandomEnchant:SetFor(user.Player, user.Data.RandomEnchant)

	ItemService:UpdateId(user, id, success)

	return success
end

function EnchantingService:ApplyEnchantmentBookOnUsersItem(user, itemId, bookId)
	--Apply an enchantment book on a users item

	local ItemService = knit.GetService("ItemService")
	local data = ItemService:GetUsersDataFromId(user, itemId)
	if not data then
		return
	end
	local book = ItemService:GetUsersDataFromId(user, bookId)
	local bookItemData = ItemService:GetDataForItem(book.Item)
	if not bookItemData then
		return
	end
	if not bookItemData.ItemType == "Book" then
		return
	end

	local enchant, level = EnchantingService:GetEnchantOnInventoryItem(book)

	if not enchant or not level then
		return
	end

	local EnchantData = EnchantingService:GetEnchantData(enchant)
	if not EnchantData then
		return
	end

	--Check for price
	local CurrencyService = knit.GetService("CurrencyService")
	if not CurrencyService:UserHasEnough(user, EnchantData.Price.Currency, EnchantData.Price.Amount) then
		return
	end

	local success = EnchantingService:ApplyEnchantOnItem(data, enchant, level)
	if success then
		--Take book away from user
		ItemService:UpdateId(user, itemId, success)
		ItemService:TakeItemFromUser(user, bookId)

		CurrencyService:TakeCurrency(user, EnchantData.Price.Currency, EnchantData.Price.Amount)

		return true
	end

	--Did not enchant
end

function EnchantingService:BuyRandomEnchantment(user, itemId)
	local CurrencyService = knit.GetService("CurrencyService")

	if
		not CurrencyService:UserHasEnough(
			user,
			GeneralSettings.User.EnchantmentPrice.Currency,
			GeneralSettings.User.EnchantmentPrice.Amount
		)
	then
		return
	end

	if not EnchantingService:ApplyRandomEnchantOnUsersItem(user, itemId) then
		return
	end

	CurrencyService:TakeCurrency(
		user,
		GeneralSettings.User.EnchantmentPrice.Currency,
		GeneralSettings.User.EnchantmentPrice.Amount
	)

	return true
end

function EnchantingService:KnitStart()
	local UserService = knit.GetService("UserService")

	UserService.Signals.UserAdded:Connect(function(user)
		user:WaitForDataLoaded()
		if not user.Data.RandomEnchant then
			user.Data.RandomEnchant = EnchantingService:GetRandomEnchant()
		end

		EnchantingService.Client.RandomEnchant:SetFor(user.Player, user.Data.RandomEnchant)
	end)
end

function EnchantingService:KnitInit()
	for enchant, data in EnchantsData do
		for _ = 1, data.Weight do
			table.insert(WeightedTable, enchant)
		end
	end
end

return EnchantingService

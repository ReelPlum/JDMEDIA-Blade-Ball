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
local EnchantsData = ReplicatedStorage.Data.Enchants
local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local deepCopy = require(ReplicatedStorage.Common.DeepCopy)

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

function EnchantingService:GetEnchantData(name)
	if not name then
		return
	end
	local Enchant = EnchantsData:FindFirstChild(name)
	if not Enchant then
		return
	end

	if not Enchant:IsA("ModuleScript") then
		return
	end

	return require(Enchant)
end

function EnchantingService:CanItemBeEnchanted(invItemData, enchant)
	--Check if enchantment supports the item to be enchanted
	local foundEnchant, foundLevel = EnchantingService:GetEnchantOnInventoryItem(invItemData)
	if foundEnchant and foundEnchant ~= enchant then
		warn("Enchant on item")
		return false
	end

	local data = EnchantingService:GetEnchantData(enchant)
	if not data then
		warn("No data")
		return false
	end

	local ItemService = knit.GetService("ItemService")
	local itemData = ItemService:GetDataForItem(invItemData.Item)

	if not itemData then
		warn("No item data")
		return
	end

	print(data.SupportedItemTypes)
	print(itemData.ItemType)
	if not table.find(data.SupportedItemTypes, itemData.ItemType) then
		warn("Not supported")
		return false
	end

	return true
end

function EnchantingService:GetEnchantOnInventoryItem(invItemData)
	--Returns enchants on item
	local ItemService = knit.GetService("ItemService")

	local metadata = ItemService:GetMetadataFromItem(invItemData)
	local enchantOnItem = metadata[MetaDataTypes.Types.Enchant]
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
		warn(enchant)
		warn(data)
		return
	end

	local foundEnchant, foundLevel = EnchantingService:GetEnchantOnInventoryItem(data)
	if foundEnchant ~= enchant and foundEnchant then
		warn("Fail")
		return false
	end
	--data = deepCopy(data)

	if foundLevel then
		if level ~= tonumber(foundLevel) then
			warn("Fail")
			return false
		end

		if enchantData.Statistics[level + 1] then
			--Add up 1 level
			data.Metadata[MetaDataTypes.Types.Enchant][2] = level + 1
			return data
		end

		warn("Fail")
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

function EnchantingService:ApplyEnchantmentBookOnUsersItem(user, itemId, bookId)
	--Apply an enchantment book on a users item

	local ItemService = knit.GetService("ItemService")
	local data = ItemService:GetUsersDataFromId(user, itemId)
	if not data then
		return warn("No data")
	end
	local itemData = ItemService:GetDataForItem(data.Item)
	if not itemData then
		return
	end

	local book = ItemService:GetUsersDataFromId(user, bookId)
	if not book then
		return
	end
	local bookItemData = ItemService:GetDataForItem(book.Item)
	if not bookItemData then
		return warn("No item data")
	end

	if not (bookItemData.ItemType == "Book") then
		if itemData.ItemType == "Book" then
			--Swap

			local bookIdCache = bookId
			bookId = itemId
			itemId = bookIdCache

			local bookCache = book
			book = data
			data = bookCache
		else
			return
		end
	end

	local enchant, level = EnchantingService:GetEnchantOnInventoryItem(book)

	if not enchant or not level then
		return warn("No level / enchant")
	end

	local EnchantData = EnchantingService:GetEnchantData(enchant)
	if not EnchantData then
		return warn("No enchant data")
	end

	--Check for price
	local CurrencyService = knit.GetService("CurrencyService")
	if not CurrencyService:UserHasEnough(user, EnchantData.Price.Currency, EnchantData.Price.Amount) then
		return warn("User does not have enought :/")
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

function EnchantingService:KnitStart() end

function EnchantingService:KnitInit() end

return EnchantingService

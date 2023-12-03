--[[
StrangeItemsService
2023, 12, 02
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local StrangeItemData = require(ReplicatedStorage.Data.StrangeItemData)
local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local StrangeItemsService = knit.CreateService({
	Name = "StrangeItemsService",
	Client = {},
	Signals = {},
})

function StrangeItemsService:AddStrangePartToItem(user, itemId, strangePartId)
	--Adds strange part to item
end

function StrangeItemsService:IsItemStrange(itemData)
	if not itemData.Metadata then
		warn("No metadata")
		return
	end

	if not itemData.Metadata[MetadataTypes.Types.Strange] then
		warn("Not strange :(")
		return
	end

	return true
end

function StrangeItemsService:DoesItemHaveStrangePart(itemData, strangePart)
	if not itemData.Metadata then
		return
	end

	if not itemData.Metadata[MetadataTypes.Types.StrangeParts] then
		return
	end

	if not itemData.Metadata[MetadataTypes.Types.StrangeParts][strangePart] then
		return
	end

	return true
end

function StrangeItemsService:KnitStart()
	local StatsService = knit.GetService("StatsService")
	local ItemService = knit.GetService("ItemService")
	local EquipmentService = knit.GetService("EquipmentService")

	--[[
    We only work with stats that are incremented, because we dont want it to be set to some huge numbers :/
    But this also means we cant do things like a tracker for the highest killstreak ect :/
  ]]

	StatsService.Signals.StatIncremented:Connect(function(user, stat, amount)
		for itemType, data in StrangeItemData.ItemTypes do
			local equippedItem = EquipmentService:GetIdOfEquippedItemOfType(user, itemType)
			if not equippedItem then
				warn("No equipped item?")
				continue
			end

			local itemData = ItemService:GetUsersDataFromId(user, equippedItem)
			if not itemData then
				warn("No item data")
				continue
			end

			--Check if strange. It cannot have parts on it if its not strange.
			if not StrangeItemsService:IsItemStrange(itemData) then
				continue
			end
			warn(user.Player.DisplayName)

			if data.Stat == stat then
				itemData.Metadata[MetadataTypes.Types.Strange] += amount
			end

			for part, partData in StrangeItemData.Parts do
				if not partData.Stat == stat then
					continue
				end

				if not StrangeItemsService:DoesItemHaveStrangePart(itemData, part) then
					continue
				end

				itemData.Metadata[MetadataTypes.Types.StrangeParts][part] += amount
			end

			--Item is strange. Increment stat count
			ItemService:UpdateId(user, equippedItem, itemData)
		end
	end)

	--Listen to StatsService for changes.
	--Get all equipped items for user
	--Check if any of the equipped items are strange. If so increment strange value for tracker
end

function StrangeItemsService:KnitInit() end

return StrangeItemsService

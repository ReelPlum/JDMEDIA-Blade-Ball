--[[
ItemCustomizingService
2024, 01, 02
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TextService = game:GetService("TextService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local ItemCustomizingService = knit.CreateService({
	Name = "ItemCustomizingService",
	Client = {},
	Signals = {},
})

function ItemCustomizingService.Client:ApplyNameTagToItem(player, itemId, nametagItemId, name)
	if #name > 20 then
		return false
	end

	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	ItemCustomizingService:ApplyNameTagToItem(user, itemId, nametagItemId, name)
end

function ItemCustomizingService.Client:SignItem(player, itemId, autographItemId)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	ItemCustomizingService:SignItem(user, itemId, autographItemId)
end

function ItemCustomizingService:SignItem(user, itemId, autographItemId)
	local ItemService = knit.GetService("ItemService")

	local autograph = ItemService:GetUsersDataFromId(user, autographItemId)
	if not autograph then
		return false
	end
	local autographItemData = ItemService:GetItemData(autograph.Item)
	if not autographItemData then
		return false
	end
	if not autographItemData.ItemType == "Autograph" then
		return false
	end

	local item = ItemService:GetUsersDataFromId(user, itemId)
	if not item then
		return false
	end
	local itemData = ItemService:GetItemData(item.Item)
	if not itemData then
		return false
	end
	if not table.find(autographItemData.ApplyableItemTypes, itemData.ItemType) then
		return false
	end

	ItemService:TakeItemFromUser(user, autographItemId)

	item.Metadata[MetadataTypes.Types.Autograph] = user.Player.UserId

	--Sign item
	ItemService:UpdateId(user, itemId, item)
	return true
end

function ItemCustomizingService:ApplyNameTagToItem(user, itemId, nametagItemId, name)
	local ItemService = knit.GetService("ItemService")

	local nameTag = ItemService:GetUsersDataFromId(user, nametagItemId)
	if not nameTag then
		return false
	end
	local nameTagItemData = ItemService:GetItemData(nameTag.Item)
	if not nameTagItemData then
		return false
	end
	if not nameTagItemData.ItemType == "NameTag" then
		return false
	end

	local item = ItemService:GetUsersDataFromId(user, itemId)
	if not item then
		return false
	end
	local itemData = ItemService:GetItemData(item.Item)
	if not itemData then
		return false
	end
	if not table.find(nameTagItemData.ApplyableItemTypes, itemData.ItemType) then
		return false
	end

	--Filter name
	local success, result = pcall(function()
		return TextService:FilterStringAsync(name, user.Player.UserId, Enum.TextFilterContext.PublicChat)
	end)

	local filteredName = result:GetNonChatStringForBroadcastAsync()

	--If name is filtered then deny the name
	if filteredName ~= name then
		return false
	end

	ItemService:TakeItemFromUser(user, nametagItemId)

	--Apply name to item
	item.Metadata[MetadataTypes.Types.Name] = filteredName

	--Sign item
	ItemService:UpdateId(user, itemId, item)
	return true
end

function ItemCustomizingService:KnitStart() end

function ItemCustomizingService:KnitInit() end

return ItemCustomizingService

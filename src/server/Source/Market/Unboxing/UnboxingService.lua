--[[
UnboxingService
2023, 12, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local UnboxableData = ReplicatedStorage.Data.Unboxables
local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local UnboxingService = knit.CreateService({
	Name = "UnboxingService",
	Client = {},
	Signals = {
		UnboxedItem = signal.new(),
	},
})

function UnboxingService.Client:UnboxItem(player, itemIds: { string })
	--
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	for _, id in itemIds do
		task.spawn(function()
			UnboxingService:UnboxItem(user, id)
		end)
		task.wait(.1)
	end
end

function UnboxingService:GetUnboxable(unboxable)
	if not unboxable then
		return
	end

	local data = UnboxableData:FindFirstChild(unboxable)
	if not data then
		return
	end

	if not data:IsA("ModuleScript") then
		return
	end

	return require(data)
end

function UnboxingService:Unbox(user, unboxable: string)
	--Unbox and give the unboxed item to user
	local data = UnboxingService:GetUnboxable(unboxable)
	if not data then
		return
	end

	if #data.DropList < 1 then
		return warn("Not enought loot to make unbox " .. unboxable)
	end

	local weightedTable = data.WeightedTable

	if not data.WeightedTable then
		weightedTable = {}
		for index, data in data.DropList do
			for i = 1, data.Weight do
				table.insert(weightedTable, index)
			end
		end
	end

	data.WeightedTable = weightedTable

	local unboxedItem = weightedTable[math.random(1, #weightedTable)]
	local unboxedItemData = data.DropList[unboxedItem]

	local IsStrange = false

	if data.StrangeChance then
		if math.random(0, 100) <= data.StrangeChance then
			IsStrange = true
		end
	end

	warn(unboxedItem)

	if unboxedItemData.Type == "Item" then
		local ItemService = knit.GetService("ItemService")

		warn("Giving item")

		local metadata = {
			[MetadataTypes.Types.UnboxedBy] = user.Player.UserId,
			[MetadataTypes.Types.Unboxable] = unboxable,
		}

		if IsStrange then
			--Strange
			metadata[MetadataTypes.Types.Strange] = 0
		end

		if unboxedItemData.Item.Metadata then
			for t, v in unboxedItemData.Item.Metadata do
				metadata[t] = v
			end
		end

		ItemService:GiveUserItem(user, unboxedItemData.Item.Item, 1, metadata)
	elseif unboxedItemData.Type == "Currency" then
		local CurrencyService = knit.GetService("CurrencyService")
		CurrencyService:GiveCurrency(user, unboxedItemData.Currency, unboxedItemData.Amount)
	else
		warn("Did not find unboxable type " .. unboxedItemData.Type)
		return nil
	end

	--ShopService.Client.UnboxablePurchased:Fire(user.Player, unboxableId, unboxedItem, IsStrange)

	UnboxingService.Signals.UnboxedItem:Fire(user, unboxable, unboxedItem, IsStrange)

	return unboxedItem, IsStrange
end

function UnboxingService:UnboxItem(user, itemId: string)
	--Unbox item and remove item from user.
	local ItemService = knit.GetService("ItemService")
	local data = ItemService:GetUsersDataFromId(user, itemId)
	if not data then
		return
	end
	local itemData = ItemService:GetItemData(data.Item)
	if not itemData then
		return
	end

	if not itemData.ItemType == "Unboxable" then
		return
	end

	local unboxed, strange = UnboxingService:Unbox(user, itemData.Unboxable)
	if not unboxed then
		return
	end

	--Remove item
	ItemService:TakeItemFromUser(user, itemId)

	--Spawn unboxable in the world and animate it
	local WorldUnboxablesService = knit.GetService("WorldUnboxablesService")
	WorldUnboxablesService:Unbox(user, itemData.Unboxable, unboxed, strange)
end

function UnboxingService:KnitStart() end

function UnboxingService:KnitInit() end

return UnboxingService

--[[
ItemsStacks
2023, 12, 05
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local IndexesToIgnore = {
	"Date",
	MetadataTypes.Types.OriginalPurchaser,
	MetadataTypes.Types.UnboxedBy,
	MetadataTypes.Types.Unboxable,
	MetadataTypes.Types.Bundle,
	MetadataTypes.Types.Robux,
}

local function CompareItems(a, b, alreadyCheckedOther)
	for index, value in a do
		if table.find(IndexesToIgnore, index) then
			continue
		end

		if not b[index] then
			return false
		end
		if not (typeof(value) == typeof(b[index])) then
			return false
		end

		if typeof(value) == "table" then
			if not CompareItems(value, b[index], true) then
				return false
			end
			continue
		end

		if not (value == b[index]) then
			return false
		end
	end

	if alreadyCheckedOther then
		return true
	end

	return CompareItems(b, a, true)
end

local function GenerateStacks(items)
	local itemStacks = {}
	local itemLookup = {}

	local ItemController = knit.GetController("ItemController")

	print(items)

	for id, data in items do
		--Check item etc.
		local itemData = ItemController:GetItemData(data.Item)
		if not itemData then
			continue
		end
		if itemData.DontStack then
			local stackId = HttpService:GenerateGUID(false)
			itemStacks[stackId] = {
				Data = data,
				Hold = { id },
			}

			itemLookup[id] = stackId
			continue
		end

		local found = false
		for stackId, stackData in itemStacks do
			if CompareItems(stackData.Data, data) or (stackData.Data.Item == data.Item and itemData.OneCopyAllowed) then
				--Is equal
				found = true
				itemLookup[id] = stackId
				table.insert(itemStacks[itemLookup[id]].Hold, id)
				break
			end
		end

		if not found then
			--Create new stack
			local stackId = HttpService:GenerateGUID(false)
			itemStacks[stackId] = {
				Hold = {
					id,
				},
				Data = data,
			}
			itemLookup[id] = stackId
		end
	end

	return itemStacks, itemLookup
end

local function RemoveFromStack(stacks, lookup, id)
	if not lookup[id] then
		return
	end

	if not stacks[lookup[id]] then
		lookup[id] = nil
		return
	end

	local stack = stacks[lookup[id]]
	local index = table.find(stack.Hold, id)

	if not index then
		lookup[id] = nil
		return
	end
	table.remove(stack.Hold, index)

	if #stack.Hold <= 0 then
		stacks[lookup[id]] = nil
		print("Fully removed?!")
	end
	lookup[id] = nil
end

local function ItemsAdded(stacks, lookup, items)
	local n = 0

	local ItemController = knit.GetController("ItemController")

	for id, data in items do
		--Go through and find the matching item
		local itemData = ItemController:GetItemData(data.Item)
		if not itemData then
			continue
		end
		if itemData.DontStack then
			local stackId = HttpService:GenerateGUID(false)
			stacks[stackId] = {
				Data = data,
				Hold = { id },
			}

			lookup[id] = stackId
			continue
		end

		if lookup[id] then
			--Remove from other stack
			RemoveFromStack(stacks, lookup, id)
			print(id)
		end

		n += 1

		local found = false
		for stackId, stack in stacks do
			n += 1
			if CompareItems(data, stack.Data) or (stack.Data.Item == data.Item and itemData.OneCopyAllowed) then
				table.insert(stack.Hold, id)

				found = true
				lookup[id] = stackId

				break
			end
		end

		if not found then
			print("Creating new stack!")
			--Create new stack
			local stackId = HttpService:GenerateGUID(false)
			stacks[stackId] = {
				Data = data,
				Hold = { id },
			}

			lookup[id] = stackId
		end
	end
end

local function ItemsRemoved(stacks, lookup, items)
	for _, id in items do
		RemoveFromStack(stacks, lookup, id)
	end
end

local module = {
	GenerateStacks = GenerateStacks,
	ItemsAdded = ItemsAdded,
	ItemsRemoved = ItemsRemoved,
}

return module

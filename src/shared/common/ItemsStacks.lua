--[[
ItemsStacks
2023, 12, 05
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

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

	for id, data in items do
		--Check item etc.
		local itemData = ItemController:GetItemData(data.Item)
		if not itemData then
			continue
		end
		if itemData.DontStack then
			itemStacks[id] = {
				Data = data,
				Hold = { id },
			}

			itemLookup[id] = id
			continue
		end

		local found = false
		for stackId, stackData in itemStacks do
			if CompareItems(stackData.Data, data) then
				--Is equal
				found = true
				itemLookup[id] = stackId
				table.insert(itemStacks[itemLookup[id]].Hold, id)
			end
		end

		if not found then
			--Create new stack
			itemStacks[id] = {
				Hold = {
					id,
				},
				Data = data,
			}
			itemLookup[id] = id
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
			stacks[id] = {
				Data = data,
				Hold = { id },
			}

			lookup[id] = id
			continue
		end

		if lookup[id] then
			--Remove from other stack
			RemoveFromStack(stacks, lookup, id)
		end

		n += 1

		local found = false
		for stackId, stack in stacks do
			n += 1
			if CompareItems(data, stack.Data) then
				table.insert(stack.Hold, id)

				found = true
				lookup[id] = stackId

				break
			end
		end

		if not found then
			--Create new stack
			stacks[id] = {
				Data = data,
				Hold = { id },
			}

			lookup[id] = id
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

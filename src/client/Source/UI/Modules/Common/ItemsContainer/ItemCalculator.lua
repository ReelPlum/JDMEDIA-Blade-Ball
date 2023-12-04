local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local SharedTableRegistry = game:GetService("SharedTableRegistry")

local j = Janitor.new()

local ItemData = require(ReplicatedStorage.Data.ItemData)
local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local IndexesToIgnore = {
	"Date",
	MetadataTypes.Types.OriginalPurchaser,
	MetadataTypes.Types.UnboxedBy,
	MetadataTypes.Types.Unboxable,
	MetadataTypes.Types.Bundle,
	MetadataTypes.Types.Admin,
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

local module = {}

local itemLookup = {}
local itemStacks = {}
local lastItems = {}
local lastIgnore = {}

function module:Execute(items, itemTypes, ignore)
	debug.profilebegin("calculate item stacks")

	lastItems = items
	lastIgnore = ignore

	--Calculate items
	if not ignore then
		ignore = {}
	end

	for id, data in items do
		--Check item etc.
		if itemTypes then
			local itmData = ItemData[data.Item]
			if not table.find(itemTypes, itmData.ItemType) then
				if itemLookup[id] then
					local i = table.find(itemStacks[itemLookup[id].Item][itemLookup[id].StackId].Hold, id)
					if i then
						table.remove(itemStacks[itemLookup[id].Item][itemLookup[id].StackId].Hold, i)
					end
					itemLookup[id] = nil
				end
				continue
			end
		end

		if not itemStacks[data.Item] then
			--Add it
			itemStacks[data.Item] = {}
		end

		if itemLookup[id] then
			if itemStacks[data.Item][itemLookup[id].StackId] then
				if CompareItems(itemStacks[data.Item][itemLookup[id].StackId].Data, data) then
					continue
				end

				--Remove from stack
				local i = table.find(itemStacks[data.Item][itemLookup[id].StackId].Hold, id)
				if i then
					table.remove(itemStacks[data.Item][itemLookup[id].StackId].Hold, i)
				end
				itemLookup[id] = nil
			end
		end

		local found = false
		for stackId, stackData in itemStacks[data.Item] do
			if CompareItems(stackData.Data, data) then
				--Is equal
				found = true
				itemLookup[id] = { StackId = stackId, Item = data.Item }
				table.insert(itemStacks[data.Item][itemLookup[id].StackId].Hold, id)
			end
		end

		if not found then
			--Create new stack
			itemStacks[data.Item][id] = {
				Hold = {
					id,
				},
				Data = data,
			}
			itemLookup[id] = {
				StackId = id,
				Item = data.Item,
			}
		end
	end

	--Go through items and find the items not available anymore
	for id, stackData in itemLookup do
		if table.find(ignore, id) then
			--Remove item
			if not itemStacks[stackData.Item] then
				itemLookup[id] = nil
				continue
			end
			if not itemStacks[stackData.Item][stackData.StackId] then
				itemLookup[id] = nil
				continue
			end

			local i = table.find(itemStacks[stackData.Item][stackData.StackId].Hold, id)
			if i then
				table.remove(itemStacks[stackData.Item][stackData.StackId].Hold, i)
			end
			itemLookup[id] = nil

			continue
		end

		if not items[id] then
			--Remove item
			if not itemStacks[stackData.Item] then
				itemLookup[id] = nil
				continue
			end
			if not itemStacks[stackData.Item][stackData.StackId] then
				itemLookup[id] = nil
				continue
			end

			local i = table.find(itemStacks[stackData.Item][stackData.StackId].Hold, id)
			if i then
				table.remove(itemStacks[stackData.Item][stackData.StackId].Hold, i)
			end
			itemLookup[id] = nil

			continue
		end
	end

	--Check stacks
	for _, stacks in itemStacks do
		for id, data in stacks do
			if #data.Hold <= 0 then
				stacks[id] = nil
			end
		end
	end

	debug.profileend()
end

function module:GetResults()
	return itemStacks
end

return module

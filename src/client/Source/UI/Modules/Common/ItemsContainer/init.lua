--[[
ItemsContainer
2023, 11, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedTableRegistry = game:GetService("SharedTableRegistry")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local parallelworker = require(ReplicatedStorage.Packages.ParallelWorker)

local Item = require(script.Parent.Item)
local ToolTip = require(script.Parent.ToolTip)
local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local ItemsContainer = {}
ItemsContainer.ClassName = "ItemsContainer"
ItemsContainer.__index = ItemsContainer

function ItemsContainer.new(UI, items, clicked, itemTypes, check)
	local self = setmetatable({}, ItemsContainer)

	self.Janitor = janitor.new()

	self.UI = UI
	self.CurrentData = items
	self.Clicked = clicked
	self.ToolTip = ToolTip.new(self.UI:FindFirstAncestorWhichIsA("ScreenGui"))
	self.ItemTypes = itemTypes
	self.Check = check

	self.ParallelWorker = parallelworker.new(script.ItemCalculator)

	self.CreatedItems = {}
	self.ItemStacks = {}
	self.Items = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ItemsContainer:UpdateItemTypes(newItemTypes)
	self.ItemTypes = newItemTypes

	self:Update(self.CurrentData)
end

function ItemsContainer:Init()
	--Init container
	self:Update(self.CurrentData)

	local list = self.UI:FindFirstChildWhichIsA("UIGridStyleLayout")
	self.Janitor:Add(list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.UI.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
	end))
end

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

function ItemsContainer:UpdateStacks()
	--Update UI
	for id, ui in self.CreatedItems do
		local item = ui.Data.Item

		if not self.ItemStacks[item] then
			ui:Destroy()
			self.CreatedItems[id] = nil
			continue
		end

		if not self.ItemStacks[item][id] then
			ui:Destroy()
			self.CreatedItems[id] = nil
			continue
		end

		--Update UI
		ui:Update(self.ItemStacks[item][id].Data, #self.ItemStacks[item][id].Hold)
	end

	--Create new ui
	for item, stack in self.ItemStacks do
		for id, stackData in stack do
			if not self.CreatedItems[id] then
				--Create item
				self.CreatedItems[id] =
					self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, stackData.Data, function()
						self.Clicked(stackData.Hold[1])
					end, self.ToolTip, #stackData.Hold))

				self.CreatedItems[id].UI.Parent = self.UI
			end
		end
	end

	--Update scrolling
	local list = self.UI:FindFirstChildWhichIsA("UIGridStyleLayout")
	self.UI.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
end

function ItemsContainer:Update(items)
	debug.profilebegin("Update itemscontainer")
	--Update with new items
	local ItemController = knit.GetController("ItemController")

	local ui = self.UI:FindFirstAncestorWhichIsA("ScreenGui")

	local ignore = {}
	self.CurrentData = items

	for id, data in items do
		if self.Check then
			if not self.Check(id, data) then
				table.insert(ignore, id)
				continue
			end
		end
	end

	task.spawn(function()
		local success, stacks = self.ParallelWorker:Invoke(items, self.ItemTypes, ignore, self.Check)
		if not success then
			return
		end

		self.ItemStacks = stacks

		self:UpdateStacks()
	end)

	debug.profileend()
end

function ItemsContainer:GetUI(id)
	return self.CreatedItems[id]
end

function ItemsContainer:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ItemsContainer

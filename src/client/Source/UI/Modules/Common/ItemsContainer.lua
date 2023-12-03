--[[
ItemsContainer
2023, 11, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Item = require(script.Parent.Item)
local ToolTip = require(script.Parent.ToolTip)

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
}

local function CompareItems(a, b)
	return true
end

function ItemsContainer:Update(items)
	--Update with new items
	local ItemController = knit.GetController("ItemController")

	self.CurrentData = items

	--[[
		self.CreatedItems will hold all shown items in the UI.
		self.ItemStacks will hold all stacks for each different item.
		self.Items hold 
	]]

	for id, data in self.CurrentData do
		--Check item etc.
		if not self.Check(data) then
			continue
		end

		if not self.ItemStacks[data.Item] then
			--Add it
			self.ItemStacks[data.Item] = {}
		end

		if self.Items[id] then
			if self.ItemStacks[data.Item][self.Items[id].StackId] then
				if CompareItems(self.ItemStacks[data.Item][self.Items[id].StackId].Data, data) then
					continue
				end

				--Remove from stack
				local i = table.find(self.ItemStacks[data.Item][self.Items[id].StackId].Hold, id)
				if i then
					table.remove(self.ItemStacks[data.Item][self.Items[id].StackId].Hold, i)
				end
				self.Items[id] = nil
			end
		end

		local found = false
		for stackId, stackData in self.ItemStacks[data.Item] do
			if CompareItems(stackData.Data, data) then
				--Is equal
				found = true
				self.Items[id] = { StackId = stackId, Item = data.Item }
				table.insert(self.ItemStacks[data.Item][self.Items[id].StackId].Hold, id)
			end
		end

		if not found then
			--Create new stack
			self.ItemStacks[data.Item][id] = {
				Hold = {
					id,
				},
				Data = data,
			}
			self.Items[id] = {
				StackId = id,
				Item = data.Item,
			}
		end
	end

	--Go through items and find the items not available anymore
	for id, stackData in self.Items do
		if not items[id] then
			--Remove item
			if not self.ItemStacks[stackData.Item] then
				self.Items[id] = nil
				continue
			end
			if not self.ItemStacks[stackData.Item][stackData.StackId] then
				self.Items[id] = nil
				continue
			end

			local i = table.find(self.ItemStacks[stackData.Item][stackData.StackId].Hold, id)
			if i then
				table.remove(self.ItemStacks[stackData.Item][stackData.StackId].Hold, i)
			end
			self.Items[id] = nil

			continue
		end
	end

	--Check stacks
	for _, stacks in self.ItemStacks do
		for id, data in stacks do
			if #data.Hold <= 0 then
				stacks[id] = nil
			end
		end
	end

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

function ItemsContainer:GetUI(id)
	return self.CreatedItems[id]
end

function ItemsContainer:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ItemsContainer

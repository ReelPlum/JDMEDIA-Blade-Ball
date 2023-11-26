--[[
ItemsContainer
2023, 11, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

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
	self.Items = items
	self.Clicked = clicked
	self.ToolTip = ToolTip.new(self.UI:FindFirstAncestorWhichIsA("ScreenGui"))
	self.ItemTypes = itemTypes
	self.Check = check

	self.CreatedItems = {}
	self.ItemStacks = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ItemsContainer:UpdateItemTypes(newItemTypes)
	self.ItemTypes = newItemTypes

	self:Update(self.Items)
end

function ItemsContainer:Init()
	--Init container
	self:Update(self.Items)

	local list = self.UI:FindFirstChildOfClass("UIListLayout")
	self.Janitor:Add(list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.UI.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
	end))
end

function ItemsContainer:Update(items)
	--Update with new items
	local ItemController = knit.GetController("ItemController")

	self.Items = items

	--Dont stack items. Create all items.
	for id, data in items do
		--Create UI
		local item = self:GetUI(id)

		if self.ItemTypes then
			local itmData = ItemController:GetItemData(data.Item)
			if not table.find(self.ItemTypes, itmData.ItemType) then
				if item then
					item:Destroy()
					self.CreatedItems[id] = nil
				end
				continue
			end
		end

		if self.Check then
			if not self.Check(id, data) then
				if item then
					item:Destroy()
					self.CreatedItems[id] = nil
				end
				continue
			end
		end

		if item then
			item:Update(data)
			continue
		end

		--Create new item
		local item = Item.new(ReplicatedStorage.Assets.UI.Item, data, function()
			--Clicked
			self.Clicked(id)
		end, self.ToolTip)
		item.UI.Parent = self.UI
		self.CreatedItems[id] = item
	end

	for id, item in self.CreatedItems do
		if not items[id] then
			item:Destroy()
			self.CreatedItems[id] = nil
		end
	end

	--Update scrolling
	local list = self.UI:FindFirstChildOfClass("UIListLayout")
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

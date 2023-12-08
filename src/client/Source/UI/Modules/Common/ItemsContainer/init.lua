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
local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local ItemsContainer = {}
ItemsContainer.ClassName = "ItemsContainer"
ItemsContainer.__index = ItemsContainer

function ItemsContainer.new(UI, items, clicked, itemTypes, check, debugMode)
	local self = setmetatable({}, ItemsContainer)

	self.Janitor = janitor.new()

	self.UI = UI
	self.CurrentData = items
	self.Clicked = clicked
	self.ToolTip = ToolTip.new(self.UI:FindFirstAncestorWhichIsA("ScreenGui"))
	self.ItemTypes = itemTypes
	self.Check = check
	self.DebugMode = debugMode

	self.CreatedItems = {}
	self.ItemStacks = {}
	self.ItemLookup = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ItemsContainer:Init()
	--Init container
	local list = self.UI:FindFirstChildWhichIsA("UIGridStyleLayout")
	self.Janitor:Add(list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.UI.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
	end))

	self:Update({}, {})
end

function ItemsContainer:UpdateItemTypes(newItemTypes)
	self.ItemTypes = newItemTypes

	local ItemController = knit.GetController("ItemController")

	for id, ui in self.CreatedItems do
		--Check itemtype
		local data = ItemController:GetItemData(ui.Data.Item)
		if not data then
			continue
		end
		if self.ItemTypes then
			if not table.find(self.ItemTypes, data.ItemType) then
				ui:Destroy()
				self.CreatedItems[id] = nil
				continue
			end
		end

		if ui.StackSize > 0 then
			ui.UI.Visible = true
		end
	end
end

function ItemsContainer:UpdateStacks()
	--Update UI

	if self.DebugMode then
		warn(self.ItemStacks)
		warn(self.ItemLookup)
	end

	for id, ui in self.CreatedItems do
		local item = ui.Data.Item

		if self.DebugMode then
			warn("Checking item!")
		end

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
		ui:Update(self.ItemStacks[item][id].Data, #self.ItemStacks[item][id].Hold, function()
			self.Clicked(self.ItemStacks[item][id].Hold[1], self.ItemStacks[item][id].Hold)
		end)
	end

	--Create new ui
	for item, stack in self.ItemStacks do
		for id, stackData in stack do
			local n = 0
			if self.Check then
				local bool, num = self.Check(stackData, id, self.ItemLookup)
				if not bool and not num then
					if self.CreatedItems[id] then
						self.CreatedItems[id]:Destroy()
						self.CreatedItems[id] = nil
					end
					continue
				end

				if not bool and num then
					if self.CreatedItems[id] then
						self.CreatedItems[id]:Update(stackData.Data, #stackData.Hold + num, function()
							self.Clicked(
								self.ItemStacks[item][id].Hold[1 + math.abs(num)],
								self.ItemStacks[item][id].Hold
							)
						end)
						continue
					end
					n = num
				end
			end

			if not self.CreatedItems[id] then
				--Create item
				self.CreatedItems[id] =
					self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, stackData.Data, function()
						self.Clicked(self.ItemStacks[item][id].Hold[1 + math.abs(n)], self.ItemStacks[item][id].Hold)
					end, self.ToolTip, #stackData.Hold + n))
				self.CreatedItems[id].UI.Parent = self.UI
			end
		end
	end

	if self.DebugMode then
		warn(self.CreatedItems)
	end

	self:UpdateItemTypes(self.ItemTypes)

	--Update scrolling
	local list = self.UI:FindFirstChildWhichIsA("UIGridStyleLayout")
	self.UI.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
end

function ItemsContainer:Update(stacks, lookup)
	task.spawn(function()
		self.ItemStacks, self.ItemLookup = stacks, lookup

		self:UpdateStacks()
	end)
	--Update with new items

	-- if not stacks then
	-- 	stacks = self.ItemStacks or {}
	-- end
	-- if not lookup then
	-- 	lookup = self.ItemLookup or {}
	-- end

	--Update with stacks
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

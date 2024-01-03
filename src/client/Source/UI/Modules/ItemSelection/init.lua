--[[
init
2024, 01, 03
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemContainer = require(script.Parent.Common.ItemContainer)
local ToolTip = require(script.Parent.Common.ToolTip)

local SortFunctions = script.Parent.Common.SortFunctions
local SortName = require(SortFunctions.SortName)
local SortRarity = require(SortFunctions.SortRarity)
local SortUniqueness = require(SortFunctions.SortUniqueness)

local ItemSelection = {}
ItemSelection.ClassName = "ItemSelection"
ItemSelection.__index = ItemSelection

function ItemSelection.new(template, parent)
	local self = setmetatable({}, ItemSelection)

	self.Janitor = janitor.new()

	self.Parent = parent
	self.Template = template

	self.OnClick = nil
	self.ReturnUI = nil

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ItemSelection:Init()
	--UI
	local InputController = knit.GetController("InputController")

	if self.Template:FindFirstChild(InputController.Platform) then
		self.UI = self.Janitor:Add(self.Template:FindFirstChild(InputController.Platform):Clone())
	else
		self.UI = self.Janitor:Add(self.Template["Normal"]:Clone())
	end

	self.UI.Parent = self.Parent

	self.ToolTip = self.Janitor:Add(ToolTip.new(self.Parent))

	local config = self.UI.Config

	self.ContainerUI = config.ScrollingFrame.Value
	self.Title = config.Title.Value
	self.Icon = config.Icon.Value
	self.CloseButton = config.CloseButton.Value
	self.SearchBar = config.Search.Value
	self.SortRarity = config.RaritySort.Value
	self.SortUniqueness = config.UniquenessSort.Value
	self.SortName = config.NameSort.Value

	--Item Container
	self.ItemContainer =
		self.Janitor:Add(ItemContainer.new(self.ContainerUI, ReplicatedStorage.Assets.UI.Item, self.ToolTip, false))

	self.ItemContainer.GetItemInformation = function(item)
		if self.Testing then
			return require(ReplicatedStorage.Data.Items[item])
		end

		local ItemController = knit.GetController("ItemController")
		return ItemController:GetItemData(item)
	end

	self.ItemContainer.OnClick = function(ids, data)
		--Use
		if not self.OnClick then
			return
		end

		local success = self.OnClick(ids, data)
		if success then
			if self.ReturnUI then
				self.ReturnUI:SetVisible(true)
			end
			self:SetVisible(false)
		end
	end

	--Sort buttons
	self.ItemContainer:UpdateSort(SortRarity)

	self.Janitor:Add(self.SortName.MouseButton1Click:Connect(function()
		self.ItemContainer:UpdateSort(SortName)
	end))

	self.Janitor:Add(self.SortRarity.MouseButton1Click:Connect(function()
		self.ItemContainer:UpdateSort(SortRarity)
	end))

	self.Janitor:Add(self.SortUniqueness.MouseButton1Click:Connect(function()
		self.ItemContainer:UpdateSort(SortUniqueness)
	end))

	--Close button
	self.Janitor:Add(self.CloseButton.MouseButton1Click:Connect(function()
		if self.ReturnUI then
			self.ReturnUI:SetVisible(true)
		end

		self:SetVisible(false)
	end))

	--Search
	self.Janitor:Add(self.SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
		self.ItemContainer:UpdateSearchTerm(self.SearchBar.ContentText)
	end))

	--Listen for changes
	local ItemController = knit.GetController("ItemController")

	self.Janitor:Add(ItemController.Signals.StacksUpdated:Connect(function()
		local stacks, lookup = ItemController:GetInventoryInStacks()
		self.ItemContainer:UpdateWithStacks(stacks, lookup)
	end))

	self:SetVisible(false)
end

function ItemSelection:SetItemTypes(itemtypes)
	--Update item types
	self.ItemContainer:UpdateItemTypes(itemtypes)
end

function ItemSelection:SetTitle(title, icon)
	--Sets title
	if title then
		self.Title.Text = title
	end
	if icon then
		self.Icon.Image = icon
	end
end

function ItemSelection:SetOnClick(onClick)
	--Sets on click
	self.OnClick = onClick
end

function ItemSelection:SetVisible(bool, returnui)
	if bool == nil then
		bool = not self.Visible
	end

	self.ReturnUI = returnui
	self.ToolTip:ClearAllActors()

	self.Visible = bool
	self.UI.Visible = bool
end

function ItemSelection:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ItemSelection

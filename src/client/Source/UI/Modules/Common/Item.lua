--[[
Item
2023, 12, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ViewportFrameModel = require(ReplicatedStorage.Common.ViewportFrameModel)

local Item = {}
Item.ClassName = "Item"
Item.__index = Item

function Item.new(template, parent, testing)
	local self = setmetatable({}, Item)

	self.Janitor = janitor.new()
	self.ItemJanitor = self.Janitor:Add(janitor.new())

	self.Template = template
	self.Parent = parent
	self.Testin = testing

	self.Enabled = true
	self.OnClick = nil

	self.Data = nil
	self.StackSize = 1

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Item:Init()
	--Create UI
	self.UI = self.Janitor:Add(self.Template:Clone())
	self.UI.Parent = self.Parent

	--Set presets
	self.Button = self.UI.Config.Button.Value
	self.ViewportFrame = self.UI.Config.ViewportFrame.Value
	self.ItemImage = self.UI.Config.ItemImage.Value
	self.ItemName = self.UI.Config.ItemName.Value
	self.StackText = self.UI.Config.StackSize.Value
	self.EquippedFrame = self.UI.Config.Equipped.Value

	--
	self.Button.MouseButton1Click:Connect(function()
		if not self.onClick then
			return
		end

		self.onClick()
	end)

	self.Button.MouseEnter:Connect(function()
		--Show tool tip
	end)

	self.Button.MouseLeave:Connect(function()
		--Hide tool tip
	end)

	--Setup
	self:SetEquipped(false)
end

function Item:SetParent(parent)
	self.UI.Parent = parent
end

function Item:UpdateStack(stackSize)
	--Change stack size
end

function Item:SetEmpty()
	--Set item to empty
end

function Item:UpdateData(newData)
	--Update item with new data
	if not newData then
		self:SetEmpty()
		return
	end

	self.Data = newData

	if self.Testing then
		return
	end

	local ItemController = knit.GetController("ItemController")
	local itemData = ItemController:GetItemData(self.Data.Item)
	if not itemData then
		return
	end

	--Set item data
	self:UpdateWithItemData(itemData)
end

function Item:UpdateWithItemData(itemData)
	if not itemData then
		self:SetEmpty()
		return
	end

	--Set name
	self.ItemName.Text = itemData.DisplayName

	if itemData.Image then
		--Set image
		self.ItemImage.Image = itemData.Image
	elseif itemData.Model then
		local model = self.ItemJanitor:Add(itemData.Model:Clone())
		model.Parent = self.ViewportFrame
	end
end

function Item:SetEquipped(bool)
	if bool == nil then
		bool = not self.Equipped
	end

	self.Equipped = bool

	self.EquippedFrame.Visible = self.Equipped
end

function Item:SetEnabled(bool)
	if bool == nil then
		bool = not self.Enabled
	end

	self.Enabled = bool
end

function Item:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Item

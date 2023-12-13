--[[
item
2023, 11, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local ViewportFrameModel = require(ReplicatedStorage.Common.ViewportFrameModel)

local CurrencyData = require(ReplicatedStorage.Data.CurrencyData)
local StrangeItemData = require(ReplicatedStorage.Data.StrangeItemData)
local StatData = require(ReplicatedStorage.Data.StatData)

local Item = {}
Item.ClassName = "Item"
Item.__index = Item

function Item.new(unboxingFrame, ui, width, index)
	local self = setmetatable({}, Item)

	self.Janitor = janitor.new()
	self.ItemJanitor = self.Janitor:Add(janitor.new())

	self.UI = self.Janitor:Add(ui)
	self.UnboxingFrame = unboxingFrame
	self.Width = width
	self.Index = index

	self.Camera = self.Janitor:Add(Instance.new("Camera"))
	self.UI.ItemViewport.CurrentCamera = self.Camera
	self.VPF = ViewportFrameModel.new(self.UI.ItemViewport, self.Camera)

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function Item:Update(newIndex, unboxable, newData)
	self.ItemJanitor:Cleanup()
	if not newData then
		return
	end

	local newItemIndex = newData[1]
	local IsStrange = newData[2]

	self.Index = newIndex

	if not newItemIndex then
		return
	end

	--Set item image & name & rarity color
	local ShopController = knit.GetController("ShopController")
	local data = ShopController:GetLootFromUnboxable(unboxable, newItemIndex)

	if data.Type == "Item" then
		--
		local ItemController = knit.GetController("ItemController")
		local itemData = ItemController:GetItemData(data.Item.Item)

		local rarityData = ItemController:GetRarityData(itemData.Rarity)

		if itemData.Image then
			self.UI.ItemViewport.Visible = false
			self.UI.ItemImage.Visible = true
			self.UI.ItemImage.Image = itemData.Image
		elseif itemData.Model then
			self.UI.ItemViewport.Visible = true
			self.UI.ItemImage.Visible = false

			--Put in model
			self.ViewportModel = self.ItemJanitor:Add(itemData.Model:Clone())
			self.ViewportModel.Parent = self.UI.ItemViewport
			self.ViewportModel:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0))
			--Make item fit, and then apply offset.
			self.VPF:SetModel(self.ViewportModel)
			local cf = self.VPF:GetMinimumFitCFrame(CFrame.new(0, 0, 0))
			if itemData.Offset then
				cf = cf * itemData.Offset
			end
			self.Camera.CFrame = cf
		else
			self.UI.ItemImage.Visible = false
			self.UI.ItemViewport.Visible = false
		end

		self.UI.ItemName.Text = itemData.DisplayName
		self.ItemJanitor:Add(rarityData.Effect(rarityData, self.UI))

		if IsStrange then
			--Add emoji for strange item
			local strangeData = StrangeItemData.ItemTypes[itemData.ItemType]
			if not strangeData then
				return
			end
			local statData = StatData[strangeData.Stat]
			if not statData then
				return
			end

			self.UI.ItemName.Text = itemData.DisplayName .. " " .. statData.Emoji
		end
	elseif data.Type == "Currency" then
		local cData = CurrencyData[data.Currency]

		self.UI.BackgroundColor3 = cData.Color
		self.UI.ItemImage.Image = cData.Image
		self.UI.ItemName.Text = cData.DisplayName .. " - " .. data.Amount
	end
end

function Item:SetPosition(x)
	self.UI.Position = UDim2.new(0.5 + (self.Index - x) * self.Width, 0, 0.5, 0)
end

function Item:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Item

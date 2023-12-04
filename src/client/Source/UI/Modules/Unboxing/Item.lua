--[[
item
2023, 11, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

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

		self.UI.ItemImage.Image = itemData.Image
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

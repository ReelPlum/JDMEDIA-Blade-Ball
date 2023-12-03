--[[
Item
2023, 11, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)
local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local Item = {}
Item.ClassName = "Item"
Item.__index = Item

function Item.new(UI, data, clicked, tooltip)
	local self = setmetatable({}, Item)

	self.Janitor = janitor.new()
	self.ItemJanitor = self.Janitor:Add(janitor.new())

	self.UI = self.Janitor:Add(UI:Clone())
	self.Clicked = clicked
	self.Data = data
	self.ToolTip = tooltip

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Item:Init()
	--Setup Visuals for UI
	self:Update(self.Data)

	--Events
	self.Janitor:Add(self.UI.MouseEnter:Connect(function()
		--Hover animation

		--Show tooltip and get information to display on tooltip
		self.ToolTip:AddActor(self.ToolTipData)
	end))

	self.Janitor:Add(self.UI.MouseLeave:Connect(function()
		--Hover animation

		--Tell tooltip that mouse is not on this item anymore
		self.ToolTip:RemoveActor(self.ToolTipData)
	end))

	self.Janitor:Add(self.UI.MouseButton1Click:Connect(function()
		--Click Animation

		--Clicked
		self.Clicked()
	end))

	local CacheController = knit.GetController("CacheController")
	self.Janitor:Add(CacheController.Signals.ItemCopiesChanged:Connect(function()
		self:Update(self.Data)
	end))
end

function Item:Update(information)
	--Updates with new data
	if not information then
		return
	end

	self.ItemJanitor:Cleanup()

	local index = self.ToolTip:RemoveActor(self.ToolTipData)

	self.Data = information

	local ItemController = knit.GetController("ItemController")
	local CacheController = knit.GetController("CacheController")

	local itemData = ItemController:GetItemData(self.Data.Item)
	local rarityData = ItemController:GetRarityData(itemData.Rarity)


	--Setup data for tooltip
	self.ToolTipData = {}
	table.insert(self.ToolTipData, {
		Type = "Header",
		Text = itemData.DisplayName,
		Item = self.Data.Item,
	})
	table.insert(self.ToolTipData, {
		Type = "Rarity",
		Data = rarityData,
		Item = self.Data.Item,
	})
	--Add metadata
	for metadata, data in self.Data.Metadata do
		table.insert(self.ToolTipData, { Type = metadata, Data = data, Item = self.Data.Item })
	end

	if table.find(GeneralSettings.ItemTypesToTrackCopiesOf, itemData.ItemType) then
		local amount = 0
		if CacheController.Cache.ItemCopies then
			amount = CacheController.Cache.ItemCopies[self.Data.Item]
		end

		table.insert(self.ToolTipData, {
			Type = "Copies",
			Copies = amount,
			Item = self.Data.Item,
		})
	end


	if index then
		self.ToolTip:AddActor(self.ToolTipData)
	end

	--self.UI:WaitForChild("ItemImage").Image = itemData.Image
	self.UI.ItemName.Text = itemData.DisplayName
	self.UI.ItemImage.Image = itemData.Image
	self.ItemJanitor:Add(rarityData.Effect(rarityData, self.UI))
end

function Item:Destroy()
	self.ToolTip:RemoveActor(self.ToolTipData)

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Item

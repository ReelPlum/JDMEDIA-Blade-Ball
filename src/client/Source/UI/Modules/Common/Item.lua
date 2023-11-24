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

local Item = {}
Item.ClassName = "Item"
Item.__index = Item

function Item.new(UI, data, clicked, tooltip)
	local self = setmetatable({}, Item)

	self.Janitor = janitor.new()

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
end

function Item:Update(information)
	--Updates with new data
	if not information then
		return
	end

	local index = self.ToolTip:RemoveActor(self.ToolTipData)

	self.Data = information

	local ItemController = knit.GetController("ItemController")

	local itemData = ItemController:GetItemData(self.Data.Item)
	local rarityData = ItemController:GetRarityData(itemData.Rarity)

	local rankings = {
		["Header"] = 1,
		["Rarity"] = 2,
		[MetadataTypes.Types.Enchant] = 3,
		[MetadataTypes.Types.Untradeable] = 10,
		[MetadataTypes.Types.UnboxedBy] = 11,
	}

	--Setup data for tooltip
	self.ToolTipData = {}
	table.insert(self.ToolTipData, {
		Type = "Header",
		Text = itemData.DisplayName,
	})
	table.insert(self.ToolTipData, {
		Type = "Rarity",
		Data = rarityData,
	})
	--Add metadata
	for metadata, data in self.Data.Metadata do
		table.insert(self.ToolTipData, { Type = metadata, Data = data })
	end

	table.sort(self.ToolTipData, function(a, b)
		--Check if ranked
		if a.Type == "Untradeable" then
			warn("Untradeable")
		end

		if rankings[a.Type] and not rankings[b.Type] then
			return true
		elseif not rankings[a.Type] and rankings[b.Type] then
			return false
		elseif rankings[a.Type] and rankings[b.Type] then
			return rankings[a.Type] < rankings[b.Type]
		end

		return true
	end)

	if index then
		self.ToolTip:AddActor(self.ToolTipData)
	end

	--self.UI:WaitForChild("ItemImage").Image = itemData.Image
	self.UI.ItemName.Text = itemData.DisplayName
	self.UI.ItemImage.Image = itemData.Image
	self.Janitor:Add(rarityData.Effect(rarityData, self.UI))
end

function Item:Destroy()
	self.ToolTip:RemoveActor(self.ToolTipData)

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Item

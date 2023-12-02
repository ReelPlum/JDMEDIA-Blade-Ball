--[[
Unboxable
2023, 11, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Unboxable = {}
Unboxable.ClassName = "Unboxable"
Unboxable.__index = Unboxable

function Unboxable.new(unboxables, id)
	local self = setmetatable({}, Unboxable)

	self.Janitor = janitor.new()

	self.Unboxables = unboxables
	self.UnboxableId = id

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Unboxable:Init()
	local ShopController = knit.GetController("ShopController")
	local CurrencyController = knit.GetController("CurrencyController")
	local ItemController = knit.GetController("ItemController")

	local unboxableData = ShopController:GetUnboxable(self.UnboxableId)
	if not unboxableData then
		return
	end
	local currencyData = CurrencyController:GetCurrencyData(unboxableData.Price.Currency)
	if not currencyData then
		return
	end

	--UI
	self.UI = self.Janitor:Add(self.Unboxables.UI.Item:Clone())
	self.UI.Parent = self.Unboxables.UI
	self.UI.Visible = true

	self.UI.Item.ItemName.Text = unboxableData.DisplayName
	self.UI.Item.ItemImage.Image = unboxableData.Image

	--Display price
	self.UI.TextLabel.TextLabel.Text = unboxableData.Price.Amount
	self.UI.TextLabel.ImageLabel.Image = currencyData.Image

	--Button
	self.Janitor:Add(self.UI.MouseButton1Click:Connect(function()
		--Buy unboxable
		ShopController:PurchaseUnboxable(self.UnboxableId)
	end))

	--Display chances on hover
	local totalWeight = 0
	local chances = {}

	for _, i in unboxableData.DropList do
		totalWeight += i.Weight
	end
	for _, i in unboxableData.DropList do
		if i.Type == "Item" then
			local data = ItemController:GetItemData(i.Item.Item)
			print(i)
			if not data then
				data = {
					Image = "rbxassetid://1",
				}
			end

			table.insert(chances, {
				Chance = math.floor(i.Weight / totalWeight * 100),
				Image = data.Image,
				--Item = i.Item.Item,
				--Metadata = i.Item.Metadata,
			})
		elseif i.Type == "Currency" then
			--Currency
			local data = CurrencyController:GetCurrencyData(i.Currency)
			if not data then
				data = {
					Image = "rbxassetid://1",
				}
			end

			table.insert(chances, {
				Chance = math.floor(i.Weight / totalWeight * 100),
				Image = data.Image,
				--Item = i.Item.Item,
				--Metadata = i.Item.Metadata,
			})
		end
	end

	self.ToolTipData = {
		{
			Type = "Header",
			Text = unboxableData.DisplayName,
		},
		{
			Type = "UnboxChances",
			Data = chances,
		},
	}

	self.Janitor:Add(self.UI.MouseEnter:Connect(function()
		--Show tooltip
		self.Unboxables.ItemsPage.Shop.ToolTip:AddActor(self.ToolTipData)
	end))

	self.Janitor:Add(self.UI.MouseLeave:Connect(function()
		--Hide tooltip
		self.Unboxables.ItemsPage.Shop.ToolTip:RemoveActor(self.ToolTipData)
	end))
end

function Unboxable:Destroy()
	self.Unboxables.ItemsPage.Shop.ToolTip:RemoveActor(self.ToolTipData)

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Unboxable

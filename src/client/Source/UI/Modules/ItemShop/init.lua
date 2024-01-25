--[[
init
2024, 01, 24
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ShopItemsData = ReplicatedStorage.Data.Shop.Items

local ShopItem = require(script.ShopItem)
local WorldItems = require(script.WorldItems)

local ItemShop = {}
ItemShop.ClassName = "ItemShop"
ItemShop.__index = ItemShop

function ItemShop.new(template, parent)
	local self = setmetatable({}, ItemShop)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ItemShop:Init()
	--UI
	local InputController = knit.GetController("InputController")

	if self.Template:FindFirstChild(InputController.Platform) then
		self.UI = self.Janitor:Add(self.Template:FindFirstChild(InputController.Platform):Clone())
	else
		self.UI = self.Janitor:Add(self.Template["Normal"]:Clone())
	end

	self.UI.Parent = self.Parent

	--Config
	local Config = self.UI.Config
	self.CloseButton = Config.Close.Value
	self.Item = Config.Item.Value
	self.Container = Config.Container.Value

	--Buttons
	self.Janitor:Add(self.CloseButton.MouseButton1Click:Connect(function()
		self:SetVisible(false)
	end))

	--Load items that are set to be shown in the shop
	self.Items = {}
	self.ShopData = {}

	for _, item in ShopItemsData:GetChildren() do
		if not item:IsA("ModuleScript") then
			continue
		end

		local data = require(item)
		self.ShopData[item.Name] = data

		if data.ShowInShop then
			self.Items[item.Name] = data
			continue
		end
	end

	--Create item elements ui
	self.Elements = {}
	for name, data in self.Items do
		self.Elements[name] = self.Janitor:Add(ShopItem.new(self, name, data, self.Item, self.Container))
	end

	self.Janitor:Add(WorldItems.new(self.ShopData))

	self:SetVisible(false)
end

function ItemShop:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Visible = bool
end

function ItemShop:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ItemShop

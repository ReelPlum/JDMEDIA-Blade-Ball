--[[
FrontPage
2023, 11, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local FrontPage = {}
FrontPage.ClassName = "FrontPage"
FrontPage.__index = FrontPage

function FrontPage.new(shop)
	local self = setmetatable({}, FrontPage)

	self.Janitor = janitor.new()

	self.Shop = shop

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function FrontPage:Init()
	--UI
	self.UI = self.Shop.PlatformUI.Holder.Navigate

	--Buttons
	self.Janitor:Add(self.UI.Cash.MouseButton1Click:Connect(function()
		self.Shop:ChangePage("CashPage")
	end))

	self.Janitor:Add(self.UI.GamePasses.MouseButton1Click:Connect(function()
		self.Shop:ChangePage("GamePassPage")
	end))

	self.Janitor:Add(self.UI.Items.MouseButton1Click:Connect(function()
		self.Shop:ChangePage("ItemsPage")
	end))
end

function FrontPage:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Visible = bool
end

function FrontPage:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return FrontPage

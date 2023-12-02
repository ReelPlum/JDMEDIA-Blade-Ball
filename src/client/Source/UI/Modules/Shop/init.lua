--[[
Shop
2023, 11, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ToolTip = require(script.Parent.Common.ToolTip)

local Shop = {}
Shop.ClassName = "Shop"
Shop.__index = Shop

function Shop.new(uiTemplate)
	local self = setmetatable({}, Shop)

	self.Janitor = janitor.new()

	self.UITemplate = uiTemplate

	self.Pages = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Shop:Init()
	--Create UI
	self.UI = self.Janitor:Add(self.UITemplate:Clone())
	self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")
	self.ToolTip = self.Janitor:Add(ToolTip.new(self.UI))

	local InputController = knit.GetController("InputController")
	if self.UI:FindFirstChild(InputController.Platform) then
		self.PlatformUI = self.UI:FindFirstChild(InputController.Platform)
	else
		self.PlatformUI = self.UI:FindFirstChild("Frame")
	end

	for _, page in script.Pages:GetChildren() do
		self.Pages[page.Name] = require(page).new(self)
	end

	self:ChangePage("FrontPage")

	--Buttons
	self.Janitor:Add(self.PlatformUI.Topbar.Close.MouseButton1Click:Connect(function()
		self:SetVisible(false)
	end))

	self.Janitor:Add(self.PlatformUI.Topbar.Back.MouseButton1Click:Connect(function()
		self:ChangePage("FrontPage")
	end))

	self:SetVisible(false)
end

function Shop:ChangePage(page)
	--Change page
	self.CurrentPage = page

	for name, p in self.Pages do
		if name == page then
			p:SetVisible(true)
			continue
		end
		p:SetVisible(false)
	end
end

function Shop:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Enabled = bool
end

function Shop:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Shop

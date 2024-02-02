--[[
init
2024, 01, 24
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ExclusiveShop = {}
ExclusiveShop.ClassName = "ExclusiveShop"
ExclusiveShop.__index = ExclusiveShop
ExclusiveShop.UIType = "Main"

function ExclusiveShop.new(template, parent)
	local self = setmetatable({}, ExclusiveShop)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ExclusiveShop:Init()
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
	self.Container = Config.Container.Value
	self.SectionButton = Config.SectionButton.Value
	self.NavigationHolder = Config.Navigation.Value

	--Buttons
	self.Janitor:Add(self.CloseButton.MouseButton1Click:Connect(function()
		self:SetVisible(false)
	end))

	--Initialize modules
end

function ExclusiveShop:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Visible = bool
end

function ExclusiveShop:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ExclusiveShop

--[[
init
2024, 01, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local CodeRedemption = {}
CodeRedemption.ClassName = "CodeRedemption"
CodeRedemption.__index = CodeRedemption
CodeRedemption.UIType = "Main"

function CodeRedemption.new(template, parent)
	local self = setmetatable({}, CodeRedemption)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function CodeRedemption:Init()
	--UI
	local InputController = knit.GetController("InputController")

	if self.Template:FindFirstChild(InputController.Platform) then
		self.UI = self.Janitor:Add(self.Template:FindFirstChild(InputController.Platform):Clone())
	else
		self.UI = self.Janitor:Add(self.Template["Normal"]:Clone())
	end

	self.UI.Parent = self.Parent

	local config = self.UI.Config
	self.Input = config.Input.Value
	self.CloseButton = config.CloseButton.Value
	self.ConfirmButton = config.ConfirmButton.Value

	--Buttons
end

function CodeRedemption:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
end

function CodeRedemption:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return CodeRedemption

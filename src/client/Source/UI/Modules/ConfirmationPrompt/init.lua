--[[
init
2024, 01, 25
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ConfirmationPrompt = {}
ConfirmationPrompt.ClassName = "ConfirmationPrompt"
ConfirmationPrompt.__index = ConfirmationPrompt

function ConfirmationPrompt.new(template, parent)
	local self = setmetatable({}, ConfirmationPrompt)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ConfirmationPrompt:Init()
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
	self.CancelButton = Config.Cancel.Value
	self.ConfirmButton = Config.Confirm.Value
	self.Message = Config.Message.Value

	--Handle button clicks
	self.Janitor:Add(self.ConfirmButton.MouseButton1Click:Connect(function()
		if not self.onConfirm then
			return
		end

		self.onConfirm()

		if self.ReturnUI then
			self.ReturnUI:SetVisible(true)
		end

		self:SetVisible(false)
	end))

	self.Janitor:Add(self.CancelButton.MouseButton1Click:Connect(function()
		if not self.onCancel then
			return
		end

		self.onCancel()

		if self.ReturnUI then
			self.ReturnUI:SetVisible(true)
		end

		self:SetVisible(false)
	end))

	self:SetVisible(false)
end

function ConfirmationPrompt:SetVisible(bool, returnUI, onConfirm, onCancel, message)
	warn(bool)

	self.Visible = bool

	self.ReturnUI = returnUI
	self.onConfirm = onConfirm
	self.onCancel = onCancel

	if message then
		self.Message.Text = message
	end

	self.UI.Visible = self.Visible
end

function ConfirmationPrompt:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ConfirmationPrompt

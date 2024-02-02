--[[
init
2024, 01, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Notifications = {}
Notifications.ClassName = "Notifications"
Notifications.__index = Notifications
Notifications.UIType = "Main"

function Notifications.new(template, parent)
	local self = setmetatable({}, Notifications)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent

	self.Queue = {}
	self.CurrentMessage = nil
	self.HiddenUI = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Notifications:Init()
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
	self.ConfirmButton = Config.Confirm.Value
	self.MessageLabel = Config.Message.Value

	--Listen for notifications
	local NotificationController = knit.GetController("NotificationController")
	self.Janitor:Add(NotificationController.Signals.RecievedNotification:Connect(function(message)
		if table.find(self.Queue, message) or self.CurrentMessage == message then
			return
		end

		table.insert(self.Queue, message)

		self:CheckQueue()
	end))

	--Buttons
	self.Janitor:Add(self.ConfirmButton.MouseButton1Click:Connect(function()
		self.CurrentMessage = nil
		self:CheckQueue()
	end))

	self:SetVisible(false)
end

function Notifications:CheckQueue()
	if self.CurrentMessage then
		return
	end

	if not self.Queue[1] then
		self:SetVisible(false)
		return
	end

	self:ShowNotification(self.Queue[1])
	table.remove(self.Queue, 1)
end

function Notifications:ShowNotification(message)
	warn(message)

	self.MessageLabel.Text = message
	self.CurrentMessage = message

	--Hide visible ui
	local UIController = knit.GetController("UIController")
	local visibleUI = UIController:GetVisibleUIOfType("Main")

	for name, ui in visibleUI do
		if visibleUI == self then
			continue
		end

		self.HiddenUI[name] = ui
		ui:SetVisible(false)
	end

	self:SetVisible(true)
end

function Notifications:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Visible = bool

	if not bool then
		for i, ui in self.HiddenUI do
			ui:SetVisible(true)
			self.HiddenUI[i] = nil
		end
	end
end

function Notifications:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Notifications

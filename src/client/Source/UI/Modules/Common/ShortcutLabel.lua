--[[
ShortcutLabel
2023, 10, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local InputData = require(ReplicatedStorage.Data.InputData)

local ShortcutLabel = {}
ShortcutLabel.__index = ShortcutLabel

function ShortcutLabel.new(UI, action: string)
	local self = setmetatable({}, ShortcutLabel)

	self.Janitor = janitor.new()

	self.UI = UI
	self.Action = action
	self.BackgroundColor = self.UI.BackgroundColor3

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ShortcutLabel:Init()
	--Initialize the shortcut label
	--Setup update stuff
	local InputController = knit.GetController("InputController")
	self.Janitor:Add(InputController.Signals.InputModeChanged:Connect(function()
		self:Update()
	end))
	self:Update()

	local holdClr = Vector3.new(self.BackgroundColor.R, self.BackgroundColor.G, self.BackgroundColor.B) * 255
		- Vector3.new(75, 75, 75)

	holdClr = Vector3.new(math.clamp(holdClr.X, 0, 255), math.clamp(holdClr.Y, 0, 255), math.clamp(holdClr.Z, 0, 255))

	--Detect click for down effect
	self.Janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		local inputMode = InputController.CurrentInputMode

		local data = InputData[inputMode]
		if not data then
			return
		end

		if data.ShiftLock and InputController:IsShiftLock() then
			if data.ShiftLock[self.Action] then
				--Check if action is input
				if InputController:CheckUserInput(input, data.ShiftLock[self.Action]) then
					self.UI.BackgroundColor3 = Color3.fromRGB(holdClr.X, holdClr.Y, holdClr.Z)

					self.CurrentInput = data.ShiftLock[self.Action]

					return
				end
			end
		end

		if not data[self.Action] then
			return
		end

		if InputController:CheckUserInput(input, data[self.Action]) then
			self.UI.BackgroundColor3 = Color3.fromRGB(holdClr.X, holdClr.Y, holdClr.Z)

			self.CurrentInput = data[self.Action]
		end
	end))

	self.Janitor:Add(UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		local inputMode = InputController.CurrentInputMode

		local data = InputData[inputMode]
		if not data then
			return
		end

		if data.ShiftLock and InputController:IsShiftLock() then
			if data.ShiftLock[self.Action] then
				--Check if action is input
				if InputController:CheckUserInput(input, data.ShiftLock[self.Action]) then
					self.UI.BackgroundColor3 = self.BackgroundColor

					self.CurrentInput = nil

					return
				end
			end
		end

		if not data[self.Action] then
			return
		end

		if InputController:CheckUserInput(input, data[self.Action]) then
			self.UI.BackgroundColor3 = self.BackgroundColor

			self.CurrentInput = nil
		end
	end))

	self.Janitor:Add(InputController.Signals.ShiftLockChanged:Connect(function(bool)
		if bool then
			return
		end

		local inputMode = InputController.CurrentInputMode

		local data = InputData[inputMode]
		if not data then
			return
		end

		if data.ShiftLock then
			if data.ShiftLock[self.Action] then
				--Check if action is input
				if data.ShiftLock[self.Action] == self.CurrentInput then
					self.UI.BackgroundColor3 = self.BackgroundColor

					self.CurrentInput = nil
				end

				self:Update()
			end
		end
	end))
end

function ShortcutLabel:UpdateAction(action)
	self.Action = action

	self:Update()
end

function ShortcutLabel:Update()
	--Update the shortcut label
	--Updates input mode type to whatever the current input type is.
	local InputController = knit.GetController("InputController")
	local inputMode = InputController.CurrentInputMode

	self.UI.BackgroundColor3 = self.BackgroundColor

	local data = InputData[inputMode]
	if not data then
		--No inputmode has been set. Remove shortcut indicator.
		self:SetVisible(false)

		return
	end

	if data[self.Action] then
		self:SetVisible(true)

		local img = UserInputService:GetImageForKeyCode(data[self.Action])
		if img ~= "" then
			self.UI:WaitForChild("Image").Image = img

			self.UI:WaitForChild("Image").Visible = true
			self.UI:WaitForChild("Label").Visible = false
			return
		end
		self.UI:WaitForChild("Label").Text = UserInputService:GetStringForKeyCode(data[self.Action])

		self.UI:WaitForChild("Image").Visible = false
		self.UI:WaitForChild("Label").Visible = true
		return
	end

	--No matching input? Hide UI...
	self:SetVisible(false)
end

function ShortcutLabel:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Visible = self.Visible
end

function ShortcutLabel:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ShortcutLabel

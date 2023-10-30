--[[
InputController
2023, 10, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local InputActions = require(script.Parent.InputActions)

local InputData = require(ReplicatedStorage.Data.InputData)

local InputController = knit.CreateController({
	Name = "InputController",
	Signals = {
		InputModeChanged = signal.new(),
		ShiftLockChanged = signal.new(),
	},

	CurrentInputMode = nil,
	Platform = nil,
})

local function ChangeInputMode(newInputMode)
	if newInputMode == InputController.CurrentInputMode then
		return
	end

	InputController.CurrentInputMode = newInputMode
	InputController.Signals.InputModeChanged:Fire(newInputMode)

	warn("New input mode! " .. newInputMode)
end

function InputController:FireAction(action)
	if not InputActions[action] then
		return
	end

	InputActions[action]()
end

function InputController:IsShiftLock()
	return UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
end

function InputController:CheckUserInput(input: InputObject, check: EnumItem)
	return input[tostring(check.EnumType)] == check
end

function InputController:KnitStart()
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if not InputData[self.CurrentInputMode] then
			return
		end

		for action, wantedInput in InputData[self.CurrentInputMode] do
			if action == "ShiftLock" then
				--Check if shiftlock
				if not self:IsShiftLock() then
					continue
				end

				for action, wantedInput in wantedInput do
					if self:CheckUserInput(input, wantedInput) then
						self:FireAction(action)
					end
				end

				continue
			end

			if self:CheckUserInput(input, wantedInput) then
				self:FireAction(action)
			end
		end
	end)
end

function InputController:KnitInit()
	if GuiService:IsTenFootInterface() then
		self.Platform = "Console"
		ChangeInputMode("Gamepad")
	elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		if workspace.CurrentCamera.ViewportSize.Y > 600 then
			self.Platform = "Tablet"
		else
			self.Platform = "Phone"
		end

		ChangeInputMode("Touch")
	else
		self.Platform = "PC"
		ChangeInputMode("Keyboard")

		if UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1) then
			ChangeInputMode("Gamepad")
		end
	end

	UserInputService.GamepadConnected:Connect(function(gamepadNum)
		if gamepadNum ~= Enum.UserInputType.Gamepad1 then
			return
		end

		ChangeInputMode("Gamepad")
	end)

	UserInputService.GamepadDisconnected:Connect(function(gamepadNum)
		if gamepadNum ~= Enum.UserInputType.Gamepad1 then
			return
		end

		if self.Platform == "PC" then
			ChangeInputMode("Keyboard")
			return
		end

		if self.Platform == "Tablet" or self.Platform == "Phone" then
			ChangeInputMode("Touch")
		end
	end)

	UserInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(function()
		self.Signals.ShiftLockChanged:Fire(UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter)
	end)

	task.spawn(function()
		while task.wait(5) do
			if
				UserInputService.KeyboardEnabled
				and (self.Platform == "Console" or self.Platform == "Tablet" or self.Platform == "Phone")
			then
				ChangeInputMode("Keyboard")
				continue
			end

			if not UserInputService.KeyboardEnabled and (self.Platform == "Phone" or self.Platform == "Tablet") then
				ChangeInputMode("Touch")
				continue
			end

			if
				UserInputService.KeyboardEnabled
				and self.Platform == "PC"
				and not UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1)
			then
				ChangeInputMode("Keyboard")
				continue
			end
		end
	end)
end

return InputController

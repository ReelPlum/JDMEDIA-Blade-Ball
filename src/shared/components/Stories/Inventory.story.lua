--[[
Inventory.story
2023, 12, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local Inventory = require(StarterPlayerScripts.Client.Source.UI.Modules.Inventory)

return function(target)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1

	local inventory = Inventory.new(ReplicatedStorage.Assets.UI.Inventory, frame, true)

	-- Populate inventory
	inventory:UpdateWithStack({
		[1] = {
			Data = {
				Item = "TestItem",
			},
			Hold = { 1 },
		},
		[2] = {
			Data = {
				Item = "TestItem",
			},
			Hold = { 2 },
		},
		[3] = {
			Data = {
				Item = "TestItem",
			},
			Hold = { 3 },
		},
		[4] = {
			Data = {
				Item = "Dash",
			},
			Hold = { 4, 7, 8 },
		},
		[5] = {
			Data = {
				Item = "aa",
			},
			Hold = { 4, 7, 8 },
		},
		[6] = {
			Data = {
				Item = "ab",
			},
			Hold = { 4, 7, 8 },
		},
	}, {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = 4,
		[7] = 4,
		[8] = 4,
	})

	local button = Instance.new("TextButton")
	button.BackgroundTransparency = 0
	button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	button.TextColor3 = Color3.fromRGB(0, 0, 0)
	button.TextScaled = true
	button.Size = UDim2.new(0, 100, 0, 50)
	button.MouseButton1Click:Connect(function()
		inventory:SetVisible()
	end)

	button.Position = UDim2.new(1, -10, 0, 10)
	button.AnchorPoint = Vector2.new(1, 0)
	button.Parent = frame

	frame.Parent = target

	return function()
		inventory:Destroy()
		frame:Destroy()
	end
end

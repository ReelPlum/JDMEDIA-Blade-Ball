--[[
Rainbow
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local janitor = require(ReplicatedStorage.Packages.Janitor)

local function brightness(R, G, B)
	return 0.299 * R + 0.587 * G + 0.114 * B
end

--Ill make this some day lol
return function(data, ui)
	local screengui = ui:FindFirstAncestorWhichIsA("ScreenGui")

	local j = janitor.new()

	j:Add(ui.Destroying:Connect(function()
		j:Destroy()
	end))
	j:Add(RunService.RenderStepped:Connect(function()
		if not screengui then
			screengui = ui:FindFirstAncestorWhichIsA("ScreenGui")
			return
		end

		if not screengui.Enabled then
			return
		end

		ui.BackgroundColor3 = Color3.fromHSV(tick() % 20 / 20, 1, 1)

		if ui:IsA("TextLabel") then
			if brightness(ui.BackgroundColor3.R, ui.BackgroundColor3.G, ui.BackgroundColor3.B) > 0.5 then
				ui.TextColor3 = Color3.fromRGB(20, 20, 20)
			else
				ui.TextColor3 = Color3.fromRGB(242, 242, 242)
			end
		end
	end))

	return j
end

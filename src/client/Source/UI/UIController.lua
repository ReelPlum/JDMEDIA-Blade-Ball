--[[
UIController
2023, 10, 22
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local UIController = knit.CreateController({
	Name = "UIController",
	Signals = {},
})

local UI = {}

function UIController:GetDeafaultStyleSheet()
	return require(ReplicatedStorage.Components.StyleSheets.Default)
end

function UIController:HideAllUI()
	for _, ui in UI do
		if not ui.SetVisible then
			continue
		end
		ui:SetVisible(false)
	end
end

function UIController:KnitStart() end

function UIController:KnitInit() end

return UIController

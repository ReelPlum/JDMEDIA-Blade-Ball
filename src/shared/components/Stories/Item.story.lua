--[[
Item.story
2023, 12, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local knit = require(ReplicatedStorage.Packages.Knit)

local Source = StarterPlayerScripts.Client.Source

local Item = ReplicatedStorage.Assets.UI.Item
local ItemClass = require(StarterPlayerScripts.Client.Source.UI.Modules.Common.Item)

return function(target)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 1, 0)
	holder.BackgroundTransparency = 1

	print("hello")

	--Create item
	local itm = ItemClass.new(Item, holder)
	local data = {
		Item = "Dash",
	}
	itm:UpdateWithItemData(require(ReplicatedStorage.Data.Items.Dash))

	holder.Parent = target

	return function()
		holder:Destroy()
	end
end

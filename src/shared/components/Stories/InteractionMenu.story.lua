--[[
InteractionMenu.story
2023, 12, 18
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local ItemInteractionMenu = require(StarterPlayerScripts.Client.Source.UI.Modules.Common.ItemInteractionMenu)

return function(target)
	local menu = ItemInteractionMenu.new(ReplicatedStorage.Assets.UI.ItemInteractionMenu, target)

	menu:SetData(
		require(StarterPlayerScripts.Client.Source.UI.Modules.Inventory.ItemTypes.Knife).Interactions,
		{ 1 },
		UDim2.new(0.5, 0, 0.5, 0)
	)

	return function()
		menu:Destroy()
	end
end

--[[
ItemsInInventory
2023, 11, 26
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return {
	Name = "OpenFFlags",
	Aliases = {},
	Description = "Open FFlags menu",
	Group = "Owner",
	Args = {},

	ClientRun = function(context, fromPlayers, toPlayer)
		local UIController = knit.GetController("UIController")

		local ui = UIController:GetUI("FFlags")
		if not ui then
			return "Could not find ui..."
		end

		ui:SetVisible(true)
		return "Openeded FFlags!"
	end,
}

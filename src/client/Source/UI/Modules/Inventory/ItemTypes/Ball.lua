--[[
Knife
2023, 12, 14
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return {
	Use = function(ids)
		local EquipmentController = knit.GetController("EquipmentController")

		EquipmentController:EquipItem(ids[1])
	end,
	Interactions = {
		{
			DisplayName = "Equip",
			Use = function(ids)
				local EquipmentController = knit.GetController("EquipmentController")

				EquipmentController:EquipItem(ids[1])
			end,
			Check = function(data, itemData, ids, equipped)
				return not equipped
			end,
		},
		-- {
		-- 	DisplayName = "Lock",
		-- 	Use = function(ids)
		-- 		warn("Lock")
		-- 	end,
		-- 	Check = function(data)
		-- 		return true
		-- 	end,
		-- },
	},
}

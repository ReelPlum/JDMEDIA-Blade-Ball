--[[
ItemTypes
2023, 12, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.Knit)

return {
	["Knife"] = function(id)
		local EquipmentController = knit.GetController("EquipmentController")
		EquipmentController:EquipItem(id)
	end,
	["Ability"] = function(id)
		local EquipmentController = knit.GetController("EquipmentController")
		EquipmentController:EquipItem(id)
	end,
	["Ball"] = function(id)
		local EquipmentController = knit.GetController("EquipmentController")
		EquipmentController:EquipItem(id)
	end,
	["Tag"] = function(id)
		local EquipmentController = knit.GetController("EquipmentController")
		EquipmentController:EquipItem(id)
	end,
	["Explosion"] = function(id)
		local EquipmentController = knit.GetController("EquipmentController")
		EquipmentController:EquipItem(id)
	end,
}

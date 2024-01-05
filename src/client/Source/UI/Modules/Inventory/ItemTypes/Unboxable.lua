--[[
Unboxable
2023, 12, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return {
	Use = function(ids)
		local UnboxingService = knit.GetService("UnboxingService")

		UnboxingService:UnboxItem({ ids[1] })

		local UIController = knit.GetController("UIController")
		local inventory = UIController:GetUI("Inventory")
		inventory:SetVisible(false)
	end,
	Interactions = {
		{
			DisplayName = "Open",
			Use = function(ids)
				local UnboxingService = knit.GetService("UnboxingService")

				UnboxingService:UnboxItem({ ids[1] })

				local UIController = knit.GetController("UIController")
				local inventory = UIController:GetUI("Inventory")
				inventory:SetVisible(false)
			end,
			Check = function(data, itemData, ids, equipped)
				return true
			end,
		},
		{
			DisplayName = "Open 2",
			Use = function(ids)
				local UnboxingService = knit.GetService("UnboxingService")

				UnboxingService:UnboxItem({ ids[1], ids[2] })

				local UIController = knit.GetController("UIController")
				local inventory = UIController:GetUI("Inventory")
				inventory:SetVisible(false)
			end,
			Check = function(data, itemData, ids, equipped)
				return #ids >= 2
			end,
		},
		{
			DisplayName = "Open 8",
			Use = function(ids)
				local UnboxingService = knit.GetService("UnboxingService")

				UnboxingService:UnboxItem({ ids[1], ids[2], ids[3], ids[4], ids[5], ids[6], ids[7], ids[8] })
				
				local UIController = knit.GetController("UIController")
				local inventory = UIController:GetUI("Inventory")
				inventory:SetVisible(false)
			end,
			Check = function(data, itemData, ids, equipped)
				return #ids >= 8
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

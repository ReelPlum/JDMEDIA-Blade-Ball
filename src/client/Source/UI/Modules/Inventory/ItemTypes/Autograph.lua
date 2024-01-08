--[[
NameTag
2024, 01, 03
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return {
	Use = function(ids, data)
		local UIController = knit.GetController("UIController")
		local ItemSelectionUI = UIController:GetUI("ItemSelection")
		local InventoryUI = UIController:GetUI("Inventory")

		local ItemController = knit.GetController("ItemController")
		local itemData = ItemController:GetItemData(data.Item)

		ItemSelectionUI:SetItemTypes(itemData.ApplyableItemTypes)
		ItemSelectionUI:SetTitle("Autograph Item")
		ItemSelectionUI:SetOnClick(function(selectedItemIds, selectedItemData)
			--Open name item page.
			local ItemCustomizingService = knit.GetService("ItemCustomizingService")

			ItemCustomizingService:SignItem(selectedItemIds[1], ids[1])
			return true
		end)
		ItemSelectionUI:SetVisible(true, InventoryUI)
		InventoryUI:SetVisible(false)
	end,
	Interactions = {
		{
			DisplayName = "Use",
			Use = function(ids, data) end,
			Check = function(data, itemData, ids, equipped)
				local UIController = knit.GetController("UIController")
				local ItemSelectionUI = UIController:GetUI("ItemSelection")
				local InventoryUI = UIController:GetUI("Inventory")

				local ItemController = knit.GetController("ItemController")
				local itemData = ItemController:GetItemData(data.Item)

				ItemSelectionUI:SetItemTypes(itemData.ApplyableItemTypes)
				ItemSelectionUI:SetTitle("Autograph Item")
				ItemSelectionUI:SetOnClick(function(selectedItemIds, selectedItemData)
					--Open name item page.
					local ItemCustomizingService = knit.GetService("ItemCustomizingService")

					ItemCustomizingService:SignItem(selectedItemIds[1], ids[1])
					return true
				end)
				ItemSelectionUI:SetVisible(true, InventoryUI)
				InventoryUI:SetVisible(false)
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

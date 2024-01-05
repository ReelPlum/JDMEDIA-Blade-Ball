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
		local TextPromptUI = UIController:GetUI("TextPrompt")

		local ItemController = knit.GetController("ItemController")
		local itemData = ItemController:GetItemData(data.Item)

		ItemSelectionUI:SetItemTypes(itemData.ApplyableItemTypes)
		ItemSelectionUI:SetTitle("Name Item")
		ItemSelectionUI:SetOnClick(function(selectedItemIds, selectedItemData)
			--Open name item page.
			TextPromptUI:AskInput(20, function(text)
				local ItemCustomizingService = knit.GetService("ItemCustomizingService")
				ItemCustomizingService:ApplyNameTagToItem(selectedItemIds[1], ids[1], text):andThen(function(success)
					if not success then
						return
					end

					ItemSelectionUI:SetVisible(false)
					InventoryUI:SetVisible(true)
				end)

				return false
			end)

			return true
		end)
		ItemSelectionUI:SetVisible(true, InventoryUI)
	end,
	Interactions = {
		{
			DisplayName = "Use",
			Use = function(ids, data)
				local UIController = knit.GetController("UIController")
				local ItemSelectionUI = UIController:GetUI("ItemSelection")
				local InventoryUI = UIController:GetUI("Inventory")
				local TextPromptUI = UIController:GetUI("TextPrompt")

				local ItemController = knit.GetController("ItemController")
				local itemData = ItemController:GetItemData(data.Item)

				ItemSelectionUI:SetItemTypes(itemData.ApplyableItemTypes)
				ItemSelectionUI:SetTitle("Name Item")
				ItemSelectionUI:SetOnClick(function(selectedItemIds, selectedItemData)
					--Open name item page.
					TextPromptUI:AskInput(20, function(text)
						local ItemCustomizingService = knit.GetService("ItemCustomizingService")
						ItemCustomizingService:ApplyNameTagToItem(selectedItemIds[1], ids[1], text)
							:andThen(function(success)
								if not success then
									return
								end

								ItemSelectionUI:SetVisible(false)
								InventoryUI:SetVisible(true)
							end)

						return false
					end)

					return true
				end)
				ItemSelectionUI:SetVisible(true, InventoryUI)
			end,
			Check = function(data, itemData, ids, equipped)
				return true
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

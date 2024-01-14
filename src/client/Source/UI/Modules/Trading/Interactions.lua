local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return {
	--------------------------------------------------------------------------
	-------------------ADD-------------------------------------------------
	--------------------------------------------------------------------------
	Add = {
		{
			DisplayName = "Add 1",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")
				local itms = {}

				for i = 1, 1 do
					table.insert(itms, ids[i])
				end

				TradingService:AddItemsToTrade(itms)
			end,
			Check = function(data, itemData, ids)
				return #ids >= 1
			end,
		},
		{
			DisplayName = "Add 2",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")
				local itms = {}

				for i = 1, 2 do
					table.insert(itms, ids[i])
				end

				TradingService:AddItemsToTrade(itms)
			end,
			Check = function(data, itemData, ids)
				return #ids >= 2
			end,
		},
		{
			DisplayName = "Add 5",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")
				local itms = {}

				for i = 1, 5 do
					table.insert(itms, ids[i])
				end

				TradingService:AddItemsToTrade(itms)
			end,
			Check = function(data, itemData, ids)
				return #ids >= 5
			end,
		},
		{
			DisplayName = "Add 10",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")
				local itms = {}

				for i = 1, 10 do
					table.insert(itms, ids[i])
				end

				TradingService:AddItemsToTrade(itms)
			end,
			Check = function(data, itemData, ids)
				return #ids >= 10
			end,
		},
		{
			DisplayName = "Add 50",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")
				local itms = {}

				for i = 1, 50 do
					table.insert(itms, ids[i])
				end

				TradingService:AddItemsToTrade(itms)
			end,
			Check = function(data, itemData, ids)
				return #ids >= 50
			end,
		},
		{
			DisplayName = "Add 100",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")
				local itms = {}

				for i = 1, 100 do
					table.insert(itms, ids[i])
				end

				TradingService:AddItemsToTrade(itms)
			end,
			Check = function(data, itemData, ids)
				return #ids >= 100
			end,
		},
		{
			DisplayName = "Add all",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")

				TradingService:AddItemsToTrade(ids)
			end,
			Check = function(data, itemData, ids)
				return #ids > 10
			end,
		},
	},

	--------------------------------------------------------------------------
	-------------------REMOVE-------------------------------------------------
	--------------------------------------------------------------------------

	Remove = {
		{
			DisplayName = "Remove 1",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")
				local itms = {}

				for i = 1, 1 do
					table.insert(itms, ids[i])
				end

				TradingService:RemoveItemsFromTrade(itms)
			end,
			Check = function(data, itemData, ids)
				return #ids >= 1
			end,
		},
		{
			DisplayName = "Remove 2",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")
				local itms = {}

				for i = 1, 2 do
					table.insert(itms, ids[i])
				end

				TradingService:RemoveItemsFromTrade(itms)
			end,
			Check = function(data, itemData, ids)
				return #ids >= 2
			end,
		},
		{
			DisplayName = "Remove 5",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")
				local itms = {}

				for i = 1, 5 do
					table.insert(itms, ids[i])
				end

				TradingService:RemoveItemsFromTrade(itms)
			end,
			Check = function(data, itemData, ids)
				return #ids >= 5
			end,
		},
		{
			DisplayName = "Remove 10",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")
				local itms = {}

				for i = 1, 10 do
					table.insert(itms, ids[i])
				end

				TradingService:RemoveItemsFromTrade(itms)
			end,
			Check = function(data, itemData, ids)
				return #ids >= 10
			end,
		},
		{
			DisplayName = "Remove 50",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")
				local itms = {}

				for i = 1, 50 do
					table.insert(itms, ids[i])
				end

				TradingService:RemoveItemsFromTrade(itms)
			end,
			Check = function(data, itemData, ids)
				return #ids >= 50
			end,
		},
		{
			DisplayName = "Remove 100",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")
				local itms = {}

				for i = 1, 100 do
					table.insert(itms, ids[i])
				end

				TradingService:RemoveItemsFromTrade(itms)
			end,
			Check = function(data, itemData, ids)
				return #ids >= 100
			end,
		},
		{
			DisplayName = "Remove all",
			Use = function(ids)
				local TradingService = knit.GetService("TradingService")

				TradingService:RemoveItemsFromTrade(ids)
			end,
			Check = function(data, itemData, ids)
				return #ids > 10
			end,
		},
	},
}

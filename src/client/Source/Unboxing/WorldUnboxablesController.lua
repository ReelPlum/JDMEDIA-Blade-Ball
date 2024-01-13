--[[
WorldUnboxablesController
2023, 12, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local WorldUnboxable = require(script.Parent.WorldUnboxable)

local WorldUnboxablesController = knit.CreateController({
	Name = "WorldUnboxablesController",
	Signals = {},
})

function WorldUnboxablesController:CreateWorldUnboxableUnboxable(player, origin, location, unboxable, unboxedIndex)
	--Create unboxable and animate it.
	local wu = WorldUnboxable.new(location, origin, unboxable, player, unboxedIndex)
end

function WorldUnboxablesController:CreateModelForItem(data)
	--Create a model for the given item
	if data.Type == "Item" then
		local ItemController = knit.GetController("ItemController")
		local itemData = ItemController:GetItemData(data.Item.Item)
		local model = itemData.Model:Clone()

		for _, obj in model:GetDescendants() do
			if obj:IsA("BasePart") then
				obj.CanCollide = false
				obj.Anchored = true
			end
		end

		return model
	end
end

function WorldUnboxablesController:KnitStart()
	local WorldUnboxablesService = knit.GetService("WorldUnboxablesService")
	WorldUnboxablesService.SpawnUnboxable:Connect(function(player, origin, location, unboxable, unboxed, strange)
		WorldUnboxablesController:CreateWorldUnboxableUnboxable(player, origin, location, unboxable, unboxed, strange)
	end)
end

function WorldUnboxablesController:KnitInit() end

return WorldUnboxablesController

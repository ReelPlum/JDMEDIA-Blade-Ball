--[[
EquipmentController
2023, 10, 31
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local EquipmentController = knit.CreateController({
	Name = "EquipmentController",
	Signals = {
		EquipmentChanged = signal.new(),
	},
})

local itemTypeAddedEvents = {}

function EquipmentController:GetEquippedItems()
	local CacheController = knit.GetController("CacheController")

	if not CacheController.Cache.Equipment then
		return {}
	end

	return CacheController.Cache.Equipment
end

function EquipmentController:GetEquippedItemForType(itemType)
	return EquipmentController:GetEquippedItems()[itemType]
end

function EquipmentController:EquipItem(id)
	--Equip item with id
	local EquipmentService = knit.GetService("EquipmentService")
	EquipmentService:EquipItem(id)
end

function EquipmentController:ListenForItemType(itemType)
	if itemTypeAddedEvents[itemType] then
		return itemTypeAddedEvents[itemType]
	end

	itemTypeAddedEvents[itemType] = signal.new()
	return itemTypeAddedEvents[itemType]
end

function EquipmentController:KnitStart()
	local CacheController = knit.GetController("CacheController")
	local lastEquipment = {}

	CacheController.Signals.EquipmentChanged:Connect(function()
		EquipmentController.Signals.EquipmentChanged:Fire()

		local newEquipment = EquipmentController:GetEquippedItems()
		for itemType, id in newEquipment do
			if not itemTypeAddedEvents[itemType] then
				continue
			end

			if lastEquipment[itemType] ~= id then
				itemTypeAddedEvents[itemType]:Fire()
			end
		end
	end)
end

function EquipmentController:KnitInit() end

return EquipmentController

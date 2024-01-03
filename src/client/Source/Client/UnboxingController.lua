--[[
UnboxingController
2023, 12, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local UnboxableData = ReplicatedStorage.Data.Unboxables

local UnboxingController = knit.CreateController({
	Name = "UnboxingController",
	Signals = {},
})

function UnboxingController:GetUnboxable(unboxable)
	if not unboxable then
		return
	end

	local data = UnboxableData:FindFirstChild(unboxable)
	if not data then
		return
	end

	if not data:IsA("ModuleScript") then
		return
	end

	return require(data)
end

function UnboxingController:GetLootFromUnboxable(unboxableId, lootIndex)
	local data = UnboxingController:GetUnboxable(unboxableId)
	if not data then
		return
	end

	return data.DropList[lootIndex]
end

function UnboxingController:KnitStart() end

function UnboxingController:KnitInit() end

return UnboxingController

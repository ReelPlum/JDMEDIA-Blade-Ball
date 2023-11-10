--[[
Single
2023, 10, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local module = {}

function module.Equip(character, model)
	local BodyService = knit.GetService("BodyService")
	local j = janitor.new()

	local knf = BodyService:EquipOnBodyPart(character, "LowerTorso", model, model.EquipOffset.Value, "EquippedKnife")

	j:Add(knf)

	return j
end

return module

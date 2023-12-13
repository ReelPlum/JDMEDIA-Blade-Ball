--[[
AnimationService
2023, 10, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local AnimationService = knit.CreateService({
	Name = "AnimationService",
	Client = {},
	Signals = {},
})

function AnimationService:PlayDeflectAnimation(user, animation)
	--Plays deflect animation on user
	if not user.Player.Character then
		return
	end

	--Get equipped knife
	local EquipmentService = knit.GetService("EquipmentService")
	local knife = EquipmentService:GetEquippedItemOfType(user, "Knife")

	local ItemService = knit.GetService("ItemService")
	local data = ItemService:GetItemData(knife)
	if not data then
		warn(`❗Failed to get {user.Player.Name}'s knife {knife}`)
		return
	end

	--Spawn dust effect in

	--Spawn slash effect in

	--Play sound for knife if a sound is attached
	require(ReplicatedStorage.Common.Animations[data.Animation])(user)
end

function AnimationService:KnitStart() end

function AnimationService:KnitInit() end

return AnimationService

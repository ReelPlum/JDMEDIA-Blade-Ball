--[[
AbilityService
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local AbilityService = knit.CreateService({
	Name = "AbilityService",
	Client = {
		UsedAbility = knit.CreateSignal(),
	},
	Signals = {},
})

local abilities = {}

function AbilityService.Client:UseAbility(player, cameraLookVector, characterLookVector)
	--Executes player's equipped ability
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	user:WaitForDataLoaded()

	return AbilityService:ExecuteAbility(user, cameraLookVector, characterLookVector)
end

local function CheckCooldown(user)
	if not user.LastAbilityUse then
		return true
	end

	return tick() - user.LastAbilityUse >= GeneralSettings.Game.Cooldowns.Ability
end

function AbilityService:ExecuteAbility(user, cameraLookVector, characterLookVector)
	--Executes ability for user.
	if not CheckCooldown(user) then
		return false
	end

	local EquipmentService = knit.GetService("EquipmentService")
	local ability = EquipmentService:GetEquippedItemOfType(user, "Ability")

	if not ability then
		warn("Users equipped ability was nil")
		return false
	end
	if not abilities[ability] then
		warn(ability .. " was not found")
		return false
	end

	--Use ability
	local finished = abilities[ability].Execute(user, cameraLookVector, characterLookVector)
	if finished then
		user.LastAbilityUse = tick()
	end
	return finished
end

function AbilityService:KnitStart() end

function AbilityService:KnitInit()
	for _, module in ReplicatedStorage.Common.Abilities:GetChildren() do
		abilities[module.Name] = require(module)
	end
end

return AbilityService

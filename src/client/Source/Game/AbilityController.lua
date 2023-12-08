--[[
AbilityController
2023, 12, 08
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local AbilityController = knit.CreateController({
	Name = "AbilityController",
	Signals = {},
})

function AbilityController:UseAbility(ability)
	local m = AbilityController:GetAbilityModule(ability)

	if not m then
		return
	end
	if not m.ExecuteClient then
		return
	end

	m.ExecuteClient()
end

function AbilityController:GetAbilityModule(ability)
	if not ability then
		return
	end

	local module = ReplicatedStorage.Common.Abilities:FindFirstChild(ability)
	if not module then
		return
	end

	if not module:IsA("ModuleScript") then
		return
	end

	return require(module)
end

function AbilityController:KnitStart()
	local AbilityService = knit.GetService("AbilityService")

	AbilityService.UsedAbility:Connect(function(ability)
		warn(ability)
		AbilityController:UseAbility(ability)
	end)
end

function AbilityController:KnitInit() end

return AbilityController

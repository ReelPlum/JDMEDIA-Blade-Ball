--[[
BodyService
2023, 10, 22
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local BodyService = knit.CreateService({
	Name = "BodyService",
	Client = {},
	Signals = {},
})

function BodyService:EquipOnBodyPart(character, bodypart, item)
	--Equips item on bodypart.
	--If a offset attachment is found in the model, then that will be used to offset the item from the bodypart
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		if not player:HasAppearanceLoaded() then
			player.CharacterAppearanceLoaded:Wait()
		end
	end

	local BP = character:FindFirstChild(bodypart)
	if not BP then
		return
	end

	local clone = item:Clone()
	clone.Parent = character

	local offset = CFrame.new(0, 0, 0)
	if clone:FindFirstChild("Offset") then
		offset = clone:FindFirstChild("Offset").CFrame
	end

	local constraint = Instance.new("WeldConstraint")
	constraint.Parent = BP
	constraint.Part0 = BP

	clone:PivotTo(BP.CFrame * offset)
	if clone:IsA("Model") then
		--Constraint the model together
	else
		clone.Anchored = false
		clone.CanCollide = false

		constraint.Part1 = clone
	end
end

function BodyService:KnitStart() end

function BodyService:KnitInit() end

return BodyService

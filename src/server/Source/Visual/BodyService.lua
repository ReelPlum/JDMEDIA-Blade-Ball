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

function BodyService:EquipOnBodyPart(character, bodypart, item, offset, name)
	--Equips item on bodypart.
	--If a offset attachment is found in the model, then that will be used to offset the item from the bodypart
	if not character then
		return
	end
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

	local j = janitor.new()

	local clone = j:Add(item:Clone())
	clone.Name = name or "AttachedTo" .. BP
	clone.Parent = character

	if clone:IsA("Model") then
		if not clone.PrimaryPart then
			--No primarypart
			warn(
				"No primarypart was set to "
					.. clone:GetFullName()
					.. " while trying to add it to the body part "
					.. bodypart
			)
			return
		end
	end
	if not offset then
		offset = CFrame.new(0, 0, 0)
	end

	local constraint = j:Add(Instance.new("WeldConstraint"))
	constraint.Parent = BP
	constraint.Part0 = BP

	clone:PivotTo(BP.CFrame * offset)
	if clone:IsA("Model") then
		if #clone:GetDescendants() > 1 then
			--Constraint weld the model together
			for _, part in clone:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end
				part.CanCollide = false
				part.Anchored = false
				if part == clone.PrimaryPart then
					continue
				end
				local weld = j:Add(Instance.new("WeldConstraint"))
				weld.Parent = clone.PrimaryPart
				weld.Part0 = clone.PrimaryPart
				weld.Part1 = part
			end
		end

		constraint.Part1 = clone.PrimaryPart
	else
		clone.Anchored = false
		clone.CanCollide = false

		constraint.Part1 = clone
	end

	return j
end

function BodyService:KnitStart() end

function BodyService:KnitInit() end

return BodyService

--[[
ExtendedCharacter
2023, 10, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ExtendedCharacter = {}
ExtendedCharacter.__index = ExtendedCharacter

function ExtendedCharacter.new(user)
	local self = setmetatable({}, ExtendedCharacter)

	self.Janitor = janitor.new()
	self.CharacterJanitor = self.Janitor:Add(janitor.new())

	self.User = user
	self.Character = user.Character

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ExtendedCharacter:Init()
	if self.User.Character then
		self.Character = self.User.Character
		self:ListenToCharacter()
	end

	self.Janitor:Add(self.User.Player.CharacterAdded:Connect(function(character)
		self.Character = character
		self:ListenToCharacter()
	end))
end

function ExtendedCharacter:ListenToCharacter()
	self.CharacterJanitor:Cleanup()

	if not self.Character then
		return
	end

	--Create knife on hip
	local EquippedKnife = ReplicatedStorage.Assets.Models.Knives.DefaultKnife

	local BodyService = knit.GetService("BodyService")
	BodyService:EquipOnBodyPart(self.Character, "LowerTorso", EquippedKnife)

	--
end

function ExtendedCharacter:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ExtendedCharacter

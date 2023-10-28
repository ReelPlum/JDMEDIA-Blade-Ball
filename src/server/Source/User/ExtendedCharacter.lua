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

	self.EquippedKnife = nil

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

	local EquipmentService = knit.GetService("EquipmentService")
	self:EquipKnife(EquipmentService:GetEquippedItemOfType(self.User, "Knife"))
end

function ExtendedCharacter:EquipKnife(knife)
	if self.EquippedKnife then
		self.EquippedKnife:Destroy()
	end

	--Create knife on hip
	local ItemService = knife.GetService("ItemService")
	local data = ItemService:GetItem(knife)

	if not data then
		warn("Could not find item "..knife)
		return
	end

	local EquippedKnifeModel = data.Model

	if not EquippedKnifeModel then
		warn(knife.. " did not have a model")
		return
	end

	local BodyService = knit.GetService("BodyService")
	self.EquippedKnife = BodyService:EquipOnBodyPart(self.Character, "LowerTorso", EquippedKnifeModel)
end

function ExtendedCharacter:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ExtendedCharacter

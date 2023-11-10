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
	self.Character = user.Player.Character

	self.EquippedKnife = nil

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ExtendedCharacter:Init()
	if self.User.Character then
		self.Character = self.User.Player.Character
		self:ListenToCharacter()
	end

	self.Janitor:Add(self.User.Player.CharacterAdded:Connect(function(character)
		self.Character = character
		self:ListenToCharacter()
	end))

	local EquipmentService = knit.GetService("EquipmentService")
	self.Janitor:Add(EquipmentService.Signals.ItemEquipped:Connect(function(user, itemType)
		if user ~= self.User then
			return
		end

		if itemType ~= "Knife" then
			return
		end

		self:EquipKnife()
	end))
end

function ExtendedCharacter:ListenToCharacter()
	self.CharacterJanitor:Cleanup()
	self.EquippedKnife = nil

	if not self.Character then
		return
	end

	self:EquipKnife()
end

function ExtendedCharacter:EquipKnife()
	local EquipmentService = knit.GetService("EquipmentService")
	local knife = EquipmentService:GetEquippedItemOfType(self.User, "Knife")

	if not self.Character then
		return
	end
	if self.EquippedKnife then
		self.EquippedKnife:Cleanup()
	end

	--Create knife on hip
	local ItemService = knit.GetService("ItemService")
	local data = ItemService:GetItemData(knife)

	if not data then
		return
	end

	local EquippedKnifeModel = data.Model

	if not EquippedKnifeModel then
		warn(knife .. " did not have a model")
		return
	end

	local equipModule = script.KnifeEquips:FindFirstChild(data.KnifeType)
	if not equipModule then
		warn("could not find knifetype " .. data.KnifeType)
		return
	end

	local knf = require(equipModule).Equip(self.Character, EquippedKnifeModel)
	self.EquippedKnife = self.CharacterJanitor:Add(knf)
end

function ExtendedCharacter:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ExtendedCharacter

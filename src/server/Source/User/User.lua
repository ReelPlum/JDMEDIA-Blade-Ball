--[[
User
2023, 04, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ExtendedCharacter = require(script.Parent.ExtendedCharacter)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)
local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local User = {}
User.ClassName = "User"
User.__index = User

function User.new(player)
	local self = setmetatable({}, User)

	self.Janitor = janitor.new()

	self.Player = player

	self.Ready = false
	self.LoadingData = false
	self.DataLoaded = false
	self.Data = nil

	self.ExtendedCharacter = self.Janitor:Add(ExtendedCharacter.new(self))

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		DataLoaded = self.Janitor:Add(signal.new()),
		FirstJoin = self.Janitor:Add(signal.new()),
		Locked = self.Janitor:Add(signal.new()),
		Unlocked = self.Janitor:Add(signal.new()),
	}

	self:Init()
	self:LoadData()

	return self
end

function User:Init()
	self.Character = self.Player.Character
	self.Janitor:Add(self.Player.CharacterAdded:Connect(function(character)
		self.Character = character
	end))
end

function User:LoadData()
	--Load users data
	if self.LoadingData then
		return
	end

	self.LoadingData = true

	local DataService = knit.GetService("DataService")

	warn("Loading data...")
	DataService:RequestData(self.Player):andThen(function(data)
		self.Data = data.Data
		self._d = data

		if self.Data.FirstJoin then
			--Players first join!
			self.Signals.FirstJoin:Fire()
			self.Data.FirstJoin = false

			--Give items
			local ItemService = knit.GetService("ItemService")
			local inventory = ItemService:GetUsersInventory(self)

			for _, item in GeneralSettings.User.StartItems do
				ItemService:GiveItemToInventory(inventory, item, 1, {
					[MetadataTypes.Types.Untradeable] = true,
				})
			end

			ItemService:SaveInventory(self, inventory)
		end

		self.DataLoaded = true
		self.Signals.DataLoaded:Fire()
	end)
end

function User:WaitForDataLoaded()
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	return true
end

function User:Lock(bool)
	if bool == nil then
		bool = not self.Locked
	end

	if self.Locked == bool then
		return
	end

	self.Locked = bool

	if bool then
		self.Signals.Locked:Fire()
	else
		self.Signals.Unlocked:Fire()
	end
end

function User:Destroy()
	if self.Locked then
		self.Signals.Unlocked:Wait()
	end

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return User

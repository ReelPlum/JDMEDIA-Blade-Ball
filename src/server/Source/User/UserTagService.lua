--[[
UserTagService
2023, 10, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local UserTagService = knit.CreateService({
	Name = "UserTagService",
	Client = {
		UserTags = knit.CreateProperty(),
	},
	Signals = {},
})

local Cache = {}

local function UpdateCache(user, tag)
	Cache[user.Player.UserId] = tag

	UserTagService.Client.UserTags:Set(Cache)
end

function UserTagService:UpdateUsersTag(user)
	--Gets user's current tag
	local EquipmentService = knit.GetService("EquipmentService")
	local EquippedTag = EquipmentService:GetEquippedItemOfType(user, "Tag")

	--Update Equipped tag cache
	UpdateCache(user, EquippedTag)
end

function UserTagService:KnitStart()
	local UserService = knit.GetService("UserService")
	local EquipmentService = knit.GetService("EquipmentService")

	for _, user in UserService:GetUsers() do
		self:UpdateUsersTag(user)
	end

	UserService.Signals.UserAdded:Connect(function(user)
		self:UpdateUsersTag(user)
	end)

	UserService.Signals.UserRemoving:Connect(function(user)
		Cache[user.Player.UserId] = nil
		UserTagService.Client.UserTags:Set(Cache)
	end)

	EquipmentService.Signals.ItemEquipped:Connect(function(user, itemType)
		if itemType ~= "Tag" then
			return
		end

		self:UpdateUsersTag(user)
	end)
end

function UserTagService:KnitInit() end

return UserTagService

--[[
EquipmentService
27, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local EquipmentService = knit.CreateService({
	Name = "EquipmentService",
	Client = {
		EquippedItems = knit.CreateProperty({}),
	},
	Signals = {
		ItemEquipped = signal.new(),
	},
})

function EquipmentService.Client:EquipItem(player, itemId)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	EquipmentService:EquipItemById(user, itemId)
end

local function Update(user)
	--Update user when new item is equipped
	EquipmentService.Client.EquippedItems:SetFor(user.Player, user.Data.Equipped)
end

local function SetupUser(user)
	--Check if user has equipped anything
	user:WaitForDataLoaded()

	local ItemService = knit.GetService("ItemService")
	for _, item in GeneralSettings.User.DefaultEquippedItems do
		local data = ItemService:GetItemData(item)
		if not data then
			warn("The default equipped item " .. item .. " could not be found...")
		end

		if EquipmentService:GetEquippedItemOfType(user, data.ItemType) then
			continue
		end

		EquipmentService:EquipItem(user, item)
	end

	--Load equipment on user
	Update(user)

	EquipmentService.Client.EquippedItems:SetFor(user.Player, user.Data.Equipped)
end

function EquipmentService:EquipItemById(user, id)
	local ItemService = knit.GetService("ItemService")

	local invData = ItemService:GetUsersDataFromId(user, id)
	if not invData then
		return warn("No inventory data for " .. id)
	end

	local data = ItemService:GetItemData(invData.Item)
	if not data then
		return warn("No data for item " .. invData.Item)
	end

	user.Data.Equipped[data.ItemType] = id

	EquipmentService.Signals.ItemEquipped:Fire(user, data.ItemType)
	Update(user)
	return true
end

function EquipmentService:EquipItem(user, item)
	user:WaitForDataLoaded()

	if user.Game then
		warn("cannot equip while in a game...")
		return
	end

	local ItemService = knit.GetService("ItemService")
	local id = ItemService:GetOneItemOfUser(user, item)
	if not id then
		return
	end

	return EquipmentService:EquipItemById(user, id)
end

function EquipmentService:GetEquippedItemOfType(user, type)
	local ItemService = knit.GetService("ItemService")
	local id = EquipmentService:GetIdOfEquippedItemOfType(user, type)

	return ItemService:GetUsersItemFromId(user, id)
end

function EquipmentService:GetIdOfEquippedItemOfType(user, type)
	user:WaitForDataLoaded()

	return user.Data.Equipped[type]
end

function EquipmentService:KnitStart()
	local UserService = knit.GetService("UserService")
	local ItemService = knit.GetService("ItemService")

	for _, user in UserService:GetUsers() do
		task.spawn(function()
			SetupUser(user)
		end)
	end

	UserService.Signals.UserAdded:Connect(SetupUser)

	ItemService.Signals.UsersInventoryChanged:Connect(function(user)
		--Check for equipped items
		for itemType, id in user.Data.Equipped do
			if not ItemService:GetUsersItemFromId(user, id) then
				--Equip default item
				EquipmentService:EquipItem(user, GeneralSettings.User.DefaultEquippedItems[itemType])
			end
		end
	end)
end

function EquipmentService:KnitInit() end

return EquipmentService

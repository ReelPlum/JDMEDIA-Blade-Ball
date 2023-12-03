--[[
ItemCopiesService
2023, 12, 01
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local ItemCopiesService = knit.CreateService({
	Name = "ItemCopiesService",
	Client = {
		Copies = knit.CreateProperty({}),
	},
	Signals = {},
})

local Cache = {}
local ItemCache = {}

function ItemCopiesService:SaveCache()
	if RunService:IsStudio() then
		return
	end

	for item, amount in Cache do
		ItemCopiesService.Collection:UpdateOne({
			["Item"] = item,
		}, {
			["$inc"] = {
				Amount = amount,
			},
		}, true)

		Cache[item] = nil
	end
end

function ItemCopiesService:SyncItemCopies()
	--Syncs data
	local GlobalItems = table.clone(ItemCache)
	local ServerItems = table.clone(Cache)

	for item, amount in ServerItems do
		if not GlobalItems[item] then
			GlobalItems[item] = 0
		end

		GlobalItems[item] += amount
	end

	ItemCopiesService.Client.Copies:Set(GlobalItems)
	print(GlobalItems)
end

function ItemCopiesService:GetDataFromDatabase()
	--Get database data
	local data = ItemCopiesService.Collection:FindMany()

	ItemCache = {}
	for _, d in data do
		ItemCache[d.Item] = d.Amount
	end

	ItemCopiesService:SyncItemCopies()
end

function ItemCopiesService:KnitStart()
	local ItemService = knit.GetService("ItemService")

	ItemService.Signals.ItemCreated:Connect(function(item, quantity)
		local data = ItemService:GetItemData(item)
		if not table.find(GeneralSettings.ItemTypesToTrackCopiesOf, data.ItemType) then
			return
		end

		if not Cache[item] then
			Cache[item] = 0
		end

		Cache[item] += quantity

		ItemCopiesService:SyncItemCopies()
	end)

	ItemService.Signals.ItemDestroyed:Connect(function(item, quantity)
		local data = ItemService:GetItemData(item)
		if not table.find(GeneralSettings.ItemTypesToTrackCopiesOf, data.ItemType) then
			return
		end

		if not Cache[item] then
			Cache[item] = 0
		end

		Cache[item] -= quantity

		ItemCopiesService:SyncItemCopies()
	end)

	task.spawn(function()
		--Update database
		while true do
			ItemCopiesService:GetDataFromDatabase()
			task.wait(60)
			ItemCopiesService:SaveCache()
		end
	end)

	game:BindToClose(function()
		ItemCopiesService:SaveCache()
	end)
end

function ItemCopiesService:KnitInit()
	local DataService = knit.GetService("DataService")
	local Rongo = DataService:GetRongo()

	local Cluster = Rongo:GetCluster("Cluster0")
	local Database = Cluster:GetDatabase("Items")
	ItemCopiesService.Collection = Database:GetCollection("ItemCopies")
end

return ItemCopiesService

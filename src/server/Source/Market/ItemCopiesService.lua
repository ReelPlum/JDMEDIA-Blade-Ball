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

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)
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

	for t, data in Cache do
		for item, amount in data do
			ItemCopiesService.Collection:UpdateOne({
				["Item"] = item,
				["Type"] = t,
			}, {
				["$inc"] = {
					Amount = amount,
				},
			}, true)

			data[item] = nil
		end

		Cache[t] = nil
	end
end

function ItemCopiesService:SyncItemCopies()
	--Syncs data

	local ToShare = {}

	for t, data in ItemCache do
		if not ToShare[t] then
			ToShare[t] = {}
		end

		for item, d in data do
			ToShare[t][item] = d
		end
	end

	for t, data in Cache do
		if not ToShare[t] then
			ToShare[t] = {}
		end
		if typeof(data) ~= "table" then
			Cache[t] = nil
			continue
		end
		if not data then
			continue
		end

		for item, d in data do
			if not ToShare[t][item] then
				if ItemCache[t] then
					ToShare[t][item] = ItemCache[t][item] or 0
				else
					ToShare[t][item] = 0
				end
			end
			ToShare[t][item] += d
		end
	end

	ItemCopiesService.Client.Copies:Set(ToShare)
end

function ItemCopiesService:GetDataFromDatabase()
	--Get database data
	local data = ItemCopiesService.Collection:FindMany()

	ItemCache = {}
	for _, d in data do
		if not d.Type then
			continue
		end

		if not ItemCache[d.Type] then
			ItemCache[d.Type] = {}
		end

		ItemCache[d.Type][d.Item] = d.Amount
	end

	ItemCopiesService:SyncItemCopies()
end

function ItemCopiesService:KnitStart()
	local ItemService = knit.GetService("ItemService")

	ItemService.Signals.ItemCreated:Connect(function(item, quantity, metadata)
		local data = ItemService:GetItemData(item)
		if not table.find(GeneralSettings.ItemTypesToTrackCopiesOf, data.ItemType) then
			return
		end

		if not Cache["Normal"] then
			Cache["Normal"] = {}
		end

		local c = Cache["Normal"]

		if metadata[MetadataTypes.Types.Strange] then
			if not Cache["Strange"] then
				Cache["Strange"] = {}
			end
			c = Cache["Strange"]
		end

		if not c[item] then
			c[item] = 0
		end

		c[item] += quantity

		ItemCopiesService:SyncItemCopies()
	end)

	ItemService.Signals.ItemDestroyed:Connect(function(item, quantity, metadata)
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

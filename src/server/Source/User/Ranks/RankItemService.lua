--[[
RankItemService
2023, 12, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local RankItemService = knit.CreateService({
	Name = "RankItemService",
	Client = {},
	Signals = {},
})

function RankItemService:CheckUser(user)
	user:WaitForDataLoaded()

	local RankService = knit.GetService("RankService")
	local ItemService = knit.GetService("ItemService")

	for rank, items in user.Data.RankItems do
		if not RankService:UserHasRank(user, rank) then
			--Remove items from users inventory
			for _, id in items do
				ItemService:RemoveItemWithIdFromUsersInventory(user, id)
			end

			user.Data.RankItems[rank] = nil
		end
	end
end

function RankItemService:GiveRankItem(user, rank, item, quantity, metadata)
	local itemMetadata = {
		[MetadataTypes.Types.Untradeable] = true,
	}

	for index, value in metadata do
		itemMetadata[index] = value
	end

	user:WaitForDataLoaded()

	local ItemService = knit.GetService("ItemService")
	local addedItems = ItemService:GiveUserItem(user, item, quantity, itemMetadata)

	if not user.Data.RankItems[rank] then
		user.Data.RankItems[rank] = {}
	end

	for id, _ in addedItems do
		table.insert(user.Data.RankItems[rank], id)
	end
end

function RankItemService:KnitStart() end

function RankItemService:KnitInit() end

return RankItemService

--[[
RankService
2023, 12, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local RankData = ReplicatedStorage.Data.Ranks

local RankService = knit.CreateService({
	Name = "RankService",
	Client = {},
	Signals = {},
})

function RankService:UserHasRank(user, rank)
	local data = RankService:GetRankData(rank)

	if not data then
		return
	end

	local groupRank = user.Player:GetRankInGroup(data.Group)
	for _, r in data.Ranks do
		if groupRank == r then
			return true
		end
	end
	return false
end

function RankService:GetRankData(rank)
	if not rank then
		return
	end

	local data = RankData:FindFirstChild(rank)
	if not data then
		return
	end

	if not data:IsA("ModuleScript") then
		return
	end

	return require(data)
end

function RankService:KnitStart()
	local UserService = knit.GetService("UserService")
	local ItemService = knit.GetService("ItemService")
	local TemporaryItemsService = knit.GetService("TemporaryItemsService")

	local function HandleUser(user)
		user:WaitForDataLoaded()

		for _, r in RankData:GetChildren() do
			if not r:IsA("ModuleScript") then
				continue
			end
			local rank = r.Name
			local data = RankService:GetRankData(rank)

			if not RankService:UserHasRank(user, rank) then
				if user.Data.State[rank] then
					data.Destroy(user)
					user.Data.State[rank] = nil
				end
				continue
			end
			data.Execute(user)

			local items = data.ItemCache
			if not items then
				items = {}
				for _, item in data.Items do
					if not item:IsA("ModuleScript") then
						continue
					end
					if items[item.Name] then
						error(`The item {item} was already created for rank {rank}. Please use the same module!`)
					end

					print(item)
					local itemData = require(item)
					items[item.Name] = itemData
				end
				data.ItemCache = items
			end

			--Give items
			if HttpService:JSONEncode(items) == user.Data.State[rank] then
				continue
			end

			local itemsCache = user.Data.State[rank]
			if not itemsCache then
				itemsCache = {}
			else
				itemsCache = HttpService:JSONDecode(itemsCache)
			end

			user.Data.State[rank] = HttpService:JSONEncode(items)

			for item, data in itemsCache do
				if not items[item] then
					--Remove items
					if user.Data.RankItems[rank] then
						local TemporaryItems =
							TemporaryItemsService:GetTemporaryItemsWithID(user, user.Data.RankItems[rank])
						for id, itm in TemporaryItems do
							if item == itm then
								--Remove item
								TemporaryItemsService:RemoveItemFromTemporaryItems(user, user.Data.RankItems[rank], id)
							end
						end
					end
				end
			end

			for item, itemData in items do
				if itemData == itemsCache[item] then
					continue
				elseif itemsCache[item] ~= nil then
					--Remove old items
					print("Not equal")
					if user.Data.RankItems[rank] then
						local TemporaryItems =
							TemporaryItemsService:GetTemporaryItemsWithID(user, user.Data.RankItems[rank])
						for id, itm in TemporaryItems do
							if item == itm then
								--Remove item
								TemporaryItemsService:RemoveItemFromTemporaryItems(user, user.Data.RankItems[rank], id)
							end
						end
					end
				end

				if user.Data.RankItems[rank] then
					TemporaryItemsService:GiveTemporaryItem(
						user,
						item,
						itemData.Quantity,
						itemData.Metadata,
						user.Data.RankItems[rank]
					)
					continue
				end

				local ID = TemporaryItemsService:GiveTemporaryItem(user, item, itemData.Quantity, itemData.Metadata)
				user.Data.RankItems[rank] = ID
			end
		end

		--RankItemService:CheckUser(user)
		for _, rank in RankData:GetChildren() do
			if not rank:IsA("ModuleScript") then
				continue
			end

			if not RankService:UserHasRank(user, rank.Name) then
				if user.Data.RankItems[rank.Name] then
					TemporaryItemsService:RemoveAllTemporaryItemsWithID(user, user.Data.RankItems[rank.Name])
					user.Data.RankItems[rank.Name] = nil
				end
				continue
			end

			--Give items
			local data = RankService:GetRankData(rank.Name)
			for _, item in data.Items do
				local d = require(item)
				if not user.Data.RankItems[rank.Name] then
					local ID = TemporaryItemsService:GiveTemporaryItem(user, item.Name, d.Quantity, d.Metadata)
					user.Data.RankItems[rank.Name] = ID
					continue
				end
			end
		end
	end

	for _, user in UserService:GetUsers() do
		HandleUser(user)
	end

	UserService.Signals.UserAdded:Connect(function(user)
		--Get users ranks and run their functions
		HandleUser(user)
	end)
end

function RankService:KnitInit() end

return RankService

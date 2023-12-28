--[[
RankService
2023, 12, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

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
	local RankItemService = knit.GetService("RankItemService")

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

			--Give items
			if user.Data.State[rank] then
				continue
			end
			user.Data.State[rank] = true
			for _, item in data.Items do
				if not item:IsA("ModuleScript") then
					continue
				end
				local itemData = require(item)
				RankItemService:GiveRankItem(user, rank, item.Name, itemData.Quantity, itemData.Metadata)
			end
		end

		RankItemService:CheckUser(user)
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

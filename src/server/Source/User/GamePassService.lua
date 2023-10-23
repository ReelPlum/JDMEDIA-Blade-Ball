--[[
GamePassService
2023, 10, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketPlaceService = game:GetService("MarketplaceService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local GamePassData = require(ReplicatedStorage.Data.GamePassData)

local GamePassService = knit.CreateService({
	Name = "GamePassService",
	Client = {
		GamePasses = knit.CreateProperty({}),
	},
	Signals = {},
})

local CachedGamePasses = {}

function GamePassService:CheckUsersGamePasses(user)
	if not CachedGamePasses[user] then
		CachedGamePasses[user] = {}
	end

	for index, gamePass in GamePassData do
		--Check if MainId is owned
		if table.find(CachedGamePasses[user], index) then
			continue
		end

		if MarketPlaceService:UserOwnsGamePassAsync(user.Player.UserId, gamePass.MainId) then
			table.insert(CachedGamePasses[user], index)
			continue
		end

		--Check is any of the OtherIds are owned
		for _, id in gamePass.OtherIds do
			if MarketPlaceService:UserOwnsGamePassAsync(user.Player.UserId, id) then
				table.insert(CachedGamePasses[user], index)
				break
			end
		end
	end

	GamePassService.Client.GamePasses:SetFor(user.Player, CachedGamePasses[user])

	return CachedGamePasses[user]
end

function GamePassService:GetGamePass(id)
	for index, gamePass in GamePassData do
		--Check if MainId is owned
		if gamePass.MainId == id then
			return gamePass, index
		end

		--Check is any of the OtherIds are owned
		for _, otherId in gamePass.OtherIds do
			if otherId == id then
				return gamePass, index
			end
		end
	end
end

function GamePassService:KnitStart()
	--Cache all GamePasses owned by users and sync them to respective client.
	local UserService = knit.GetService("UserService")

	UserService.Signals.UserRemoving:Connect(function(user)
		CachedGamePasses[user] = nil
	end)

	UserService.Signals.UserAdded:Connect(function(user)
		GamePassService:CheckUsersGamePasses(user)
	end)

	MarketPlaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
		local user = UserService:WaitForUser(player)

		if not wasPurchased then
			return
		end
		if not CachedGamePasses[user] then
			GamePassService:CheckUsersGamePasses(user)
			return
		end

		local data, index = GamePassService:GetGamePass(gamePassId)
		if not data then
			return
		end

		if table.find(CachedGamePasses[user], index) then
			return
		end

		table.insert(CachedGamePasses[user], index)
		GamePassService.Client.GamePasses:SetFor(player, CachedGamePasses[user])
	end)
end

function GamePassService:KnitInit() end

return GamePassService

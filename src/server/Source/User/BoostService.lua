--[[
BoostService
2023, 12, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local BoostData = ReplicatedStorage.Data.Boosts

local BoostService = knit.CreateService({
	Name = "BoostService",
	Client = {},
	Signals = {},
})

local function AddTables(a, b)
	for index, value in b do
		if not a[index] then
			a[index] = value
			continue
		end

		a[index] += value
	end

	return a
end

function BoostService:GetAllBoosts()
	return BoostData:GetChildren()
end

function BoostService:GetUsersRebirthBoosts(user)
	--Returns boost for user
	local RebirthService = knit.GetService("RebirthService")

	local rebirthLevel = RebirthService:GetUsersRebirthLevel(user)
	local data = RebirthService:GetDataForRebirthLevel(rebirthLevel)

	if not data then
		return {}
	end

	return data.Boosts
end

function BoostService:GetUsersFruitBoosts(user) end

function BoostService:GetServerBoosts() end

function BoostService:GetUsersBoosts(user)
	local boosts = {}

	for _, boost in BoostService:GetAllBoosts() do
		boosts[boost.Name] = 0
	end

	AddTables(boosts, BoostService:GetUsersRebirthBoosts(user))

	return boosts
end

function BoostService:KnitStart() end

function BoostService:KnitInit() end

return BoostService

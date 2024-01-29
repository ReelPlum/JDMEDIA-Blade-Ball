--[[
RobuxPackService
2024, 01, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local PackData = ReplicatedStorage.Data.RobuxPacks

local RobuxPackService = knit.CreateService({
	Name = "RobuxPackService",
	Client = {
		AvailablePacks = knit.CreateProperty({}),
	},
	Signals = {},
})

function RobuxPackService:BoughtPack(user, pack)
	user:WaitForDataLoaded()

	local data = RobuxPackService:GetPackData(pack)
	if not data then
		return
	end

	--Check if pack can be bought
	if not RobuxPackService:IsPackAvailable(user, pack) then
		return false
	end

	user.Data.BoughtRobuxPacks[pack] = DateTime.now().UnixTimestamp

	local ItemService = knit.GetService("ItemService")
	local CurrencyService = knit.GetService("CurrencyService")

	--Give items for pack
	for _, item in data.Items do
		if item.Type == "Item" then
			--Give item
			ItemService:GiveUserItem(user, item.Item, item.Quantity, item.Metadata)
		elseif item.Type == "Currency" then
			--Give currency
			CurrencyService:GiveCurrency(user, item.Currency, item.Quantity)
		else
			warn("could not find type " .. item.Type)
		end
	end
end

function RobuxPackService:GetPackData(pack)
	if not pack then
		return
	end

	local data = PackData:FindFirstChild(pack)
	if not data then
		return
	end

	if not data:IsA("ModuleScript") then
		return
	end
	return require(data)
end

function RobuxPackService:IsPackAvailable(user, pack)
	local data = RobuxPackService:GetPackData(pack)
	if not data then
		return false
	end

	if data.RequiredPack then
		if not user.Data.BoughtRobuxPacks[data.RequiredPack] then
			return false
		end
	end

	if data.CanBeBoughtOnce then
		if user.Data.BoughtRobuxPacks[pack] then
			return false
		end
	end

	return true
end

function RobuxPackService:UpdateAvailablePacks(user)
	local availablePacks = {}

	for _, pack in PackData:GetChildren() do
		if not pack:IsA("ModuleScript") then
			return false
		end

		if RobuxPackService:IsPackAvailable(user, pack.Name) then
			table.insert(availablePacks, pack.Name)
		end
	end

	RobuxPackService.Client.AvailablePacks:SetFor(user.Player, availablePacks)
end

function RobuxPackService:KnitStart()
	local UserService = knit.GetService("UserService")

	for _, user in UserService:GetUsers() do
		RobuxPackService:UpdateAvailablePacks(user)
	end

	UserService.Signals.UserAdded:Connect(function(user)
		RobuxPackService:UpdateAvailablePacks(user)
	end)
end

function RobuxPackService:KnitInit() end

return RobuxPackService

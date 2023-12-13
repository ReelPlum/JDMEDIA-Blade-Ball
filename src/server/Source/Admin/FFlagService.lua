--[[
FFlagService
2023, 12, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MessagingService = game:GetService("MessagingService")
local MemoryStoreService = game:GetService("MemoryStoreService")

local fflagStore = MemoryStoreService:GetSortedMap("FFlags")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local FFlagService = knit.CreateService({
	Name = "FFlagService",
	Client = {
		FFlagUpdated = knit.CreateSignal(),
	},
	Signals = {
		FFlagUpdated = signal.new(),
	},

	FFlags = {},
})

function FFlagService.Client:GetFFlags(player)
	return FFlagService.FFlags
end

function FFlagService:GetFFlag(fflag)
	return FFlagService.FFlags[fflag]
end

function FFlagService:SetFFlag(fflag, value)
	if FFlagService.FFlags[fflag] == value then
		return
	end

	FFlagService.FFlags[fflag] = value

	FFlagService.Client.FFlagUpdated:FireAll(fflag, value)
	FFlagService.Signals.FFlagUpdated:Fire(fflag, value)
end

function FFlagService:ToggleFFlag(fflag, bool)
	if bool == nil then
		bool = not FFlagService:GetFFlag(fflag)
	end

	FFlagService:SetFFlag(fflag, bool)

	--Tell everyone fflag has been set
	MessagingService:PublishAsync("FFlags", fflag .. ":" .. tostring(bool))

	local success, msg = pcall(function()
		fflagStore:UpdateAsync("Global", function(data)
			if not data then
				data = {}
			end

			data[fflag] = bool

			return data
		end, 10 * 24 * 60 * 60)
	end)
end

function FFlagService:KnitStart()
	task.spawn(function()
		task.wait(5)

		FFlagService:ToggleFFlag("Test", true)
	end)
end

function FFlagService:KnitInit()
	--Set FFlags to already set fflags
	local success, result = nil, nil
	while not success do
		success, result = pcall(function()
			return fflagStore:GetAsync("Global")
		end)

		if not success then
			task.wait(5)
		end
	end

	--Use result now
	FFlagService.FFlags = result or {}

	--Listen for FFlag updates
	MessagingService:SubscribeAsync("FFlags", function(message)
		local data = string.split(message.Data, ":")

		local fflag = data[1]
		local value = if string.lower(data[2]) == "true" then true else false

		FFlagService:SetFFlag(fflag, value)
	end)
end

return FFlagService

--[[
LoadingController
2023, 10, 31
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local LoadingController = knit.CreateController({
	Name = "LoadingController",
	Signals = {
		DataLoaded = signal.new(),
	},

	DataLoaded = false,
})

function LoadingController:PreloadGame()
	ContentProvider:PreloadAsync(ReplicatedStorage.Assets:GetDescendants(), function() end)
	warn("⭐Successfully preloaded " .. #ReplicatedStorage.Assets:GetDescendants() .. " assets!⭐")
end

local requiredLoaded = {
	"Currencies",
	"Tags",
	"Equipment",
	"Level",
	"TradeRequests",
	"UntradeableUsers",
}

--Rewrite this to be non dependent on cachecontroller and instead call IsLoaded on all the controllers instead.

function LoadingController:KnitStart()
	LoadingController:PreloadGame()

	local CacheController = knit.GetController("CacheController")
	local j = janitor.new()
	--Listen for cache loads
	j:Add(RunService.Heartbeat:Connect(function()
		for _, index in requiredLoaded do
			if not CacheController.Cache[index] then
				return
			end
		end

		--Fully loaded
		j:Destroy()
		LoadingController.DataLoaded = true
		LoadingController.Signals.DataLoaded:Fire()
	end))
end

function LoadingController:KnitInit() end

return LoadingController

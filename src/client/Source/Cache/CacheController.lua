--[[
CacheController
2023, 10, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local CacheController = knit.CreateController({
	Name = "CacheController",
	Signals = {
		TagsUpdated = signal.new(),
	},
	Cache = {},
})

function CacheController:KnitStart()
	local UserTagService = knit.GetService("UserTagService")

	UserTagService.UserTags:Observe(function(tags)
		self.Cache.Tags = tags
		self.Signals.TagsUpdated:Fire(tags)
	end)
end

function CacheController:KnitInit() end

return CacheController

--[[
ItemIndexService
2023, 12, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemIndexService = knit.CreateService({
	Name = "ItemIndexService",
	Client = {},
	Signals = {},
})

function ItemIndexService:KnitStart()
	local ItemService = knit.GetService("ItemService")

	ItemService.Signals.ItemAdded:Connect(function(user, item)
		--Check for index
		if table.find(user.Data.ItemIndex, item) then
			return
		end
		table.insert(user.Data.ItemIndex, item)
	end)
end

function ItemIndexService:KnitInit() end

return ItemIndexService

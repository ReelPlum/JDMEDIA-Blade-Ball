--[[
ShopService
26, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ShopService = knit.CreateService({
    Name = 'ShopService',
    Client = {},
    Signals = {
    },
})

function ShopService:PurchaseBundle(user, bundleId)
    --Makes user purchase bundle
end

function ShopService:PurchaseItem(user, shopId)
    --Makes user purchase item
end

function ShopService:Unbox(user, unboxableId)
    --Unbox unboxable
end

function ShopService:KnitStart()
end

function ShopService:KnitInit()
end

return ShopService
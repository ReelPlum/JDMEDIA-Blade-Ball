--[[
AdminService
2023, 10, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local cmdr = require(ReplicatedStorage.Packages.Cmdr)

local AdminService = knit.CreateService({
	Name = "AdminService",
	Client = {},
	Signals = {},
})

function AdminService:WipeUser(userId) end

function AdminService:MuteUser(userId) end

function AdminService:BanUser(userId) end

function AdminService:KnitStart() end

function AdminService:KnitInit()
	--Initialize CMDR
	cmdr:RegisterHooksIn(script.Parent.Hooks)
	cmdr:RegisterTypesIn(script.Parent.Types)
	cmdr:RegisterCommandsIn(script.Parent.Commands)
end

return AdminService

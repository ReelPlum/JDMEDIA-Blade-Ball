--[[
init
2023, 12, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Inventory = {}
Inventory.ClassName = "Inventory"
Inventory.__index = Inventory

function Inventory.new(template, parent)
	local self = setmetatable({}, Inventory)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent

	self.ItemTypes = {}
	self.Pages = {}
	self.SortFunction = nil
	self.ItemUI = {}
	self.SearchTerm = nil

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function Inventory:Init()
	--UI
	self.UI = self.Janitor:Add(self.Template:Clone())
	self.UI.Parent = self.Parent

	--Sort buttons

	--Create navigation buttons

	--Close button

	--Search
end

function Inventory:ChangePage(newPage)
	--Change page
end

function Inventory:ChangeItemTypes(itemTypes)
	--Change to new item types
end

function Inventory:Search(searchTerm)
	--Search for items
end

function Inventory:Sort(sortFunction)
	--Sort items with sort function
end

function Inventory:UpdateStacks()
	--Update all item stacks
end

function Inventory:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Inventory

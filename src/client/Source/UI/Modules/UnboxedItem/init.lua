--[[
init
2023, 12, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Item = require(script.Item)

local UnboxedItem = {}
UnboxedItem.ClassName = "UnboxedItem"
UnboxedItem.__index = UnboxedItem

function UnboxedItem.new(template, parent)
	local self = setmetatable({}, UnboxedItem)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent
	
	self.Items = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function UnboxedItem:Init()
	--Create UI
	local InputController = knit.GetController("InputController")

	if self.Template:FindFirstChild(InputController.Platform) then
		self.UI = self.Janitor:Add(self.Template:FindFirstChild(InputController.Platform):Clone())
	else
		self.UI = self.Janitor:Add(self.Template["Normal"]:Clone())
	end

	self.UI.Parent = self.Parent
end

function UnboxedItem:AddItem(unboxData, model, strange)
	--Data for unboxed item

	local item = self.Janitor:Add(Item.new(self, unboxData, model, strange))

	table.insert(self.Items, item)
	self.Janitor:Add(item.Signals.Destroying:Connect(function()
		local i = table.find(self.Items, item)
		if not i then
			return
		end
		table.remove(self.Items, i)

		self:UpdateItems()
	end))

	self:UpdateItems()
end

function UnboxedItem:UpdateItems()
	--Update shown items.
	for index, item in self.Items do
		item:Position(index)
	end

	for _, i in self.UI:GetChildren() do
		if tonumber(i.Name) then
			if tonumber(i.Name) > math.ceil(#self.Items/3) then
				i:Destroy()
			end
		end
	end
end

function UnboxedItem:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return UnboxedItem

--[[
ToolTip
2023, 11, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Types = require(script.Types)
local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local ToolTip = {}
ToolTip.ClassName = "ToolTip"
ToolTip.__index = ToolTip

function ToolTip.new(parent)
	local self = setmetatable({}, ToolTip)

	self.Janitor = janitor.new()
	self.ElementJanitor = self.Janitor:Add(janitor.new())

	self.Parent = parent

	self.Actors = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		VisibleChanged = self.Janitor:Add(signal.new()),
		ActorAdded = self.Janitor:Add(signal.new()),
		ActorRemoved = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ToolTip:Init()
	self.UI = self.Janitor:Add(ReplicatedStorage.Assets.UI.ToolTip:Clone())
	self.UI.Parent = self.Parent

	local config = self.UI.Config
	self.Holder = config:WaitForChild("Holder").Value
	self.BorderColor = config:WaitForChild("BorderColor").Value

	self:Update(self.Data)

	self:Loop()
	self:SetVisible(false)
end

function ToolTip:Loop()
	self.Janitor:Add(RunService.RenderStepped:Connect(function()
		if not self.Visible then
			return
		end
		--Position UI
		local position = UserInputService:GetMouseLocation()
		self.UI.Position = UDim2.new(0, position.X, 0, position.Y)
	end))
end

function ToolTip:CreateTextElement(data, priority)
	if not Types[data.Type] then
		return
	end
	local label = Types[data.Type](self, data, priority)

	if not label then
		return
	end
	return self.ElementJanitor:Add(label)
end

function ToolTip:Update(data)
	--Add elements
	self.ElementJanitor:Cleanup()

	if not data then
		self:SetVisible(false)
		return
	end

	local rankings = {
		["Header"] = 1,
		["Rarity"] = 2,
		[MetadataTypes.Types.Enchant] = 3,
		[MetadataTypes.Types.Strange] = 4,
		[MetadataTypes.Types.StrangeParts] = 5,
		["UnboxChances"] = 6,

		["Copies"] = 9,
		[MetadataTypes.Types.Untradeable] = 10,
		[MetadataTypes.Types.UnboxedBy] = 11,
	}

	local toRemove = {}
	for i, d in data do
		if not rankings[d.Type] then
			table.insert(toRemove, d)
		end
	end

	for _, d in toRemove do
		table.remove(data, table.find(data, d))
	end

	table.sort(data, function(a, b)
		--Check if ranked
		return rankings[a.Type] <= rankings[b.Type]
	end)

	for index, text in data do
		local label = self:CreateTextElement(text, index)
		if not label then
			continue
		end

		if text.Type == "Rarity" then
			self.ElementJanitor:Add(text.Data.Effect(text.Data, self.BorderColor))
		end

		if not label then
			continue
		end
		label.Parent = self.Holder
	end
	--Set border color

	--Set size
	local size = self.Holder:WaitForChild("UIListLayout").AbsoluteContentSize
	self.UI.Size = UDim2.new(0, size.X + 10, 0, size.Y + 10)
end

function ToolTip:CheckForActor()
	--Check if actor is available
	if not self.Actors[1] then
		self:SetVisible(false)
		return
	end

	local data = self.Actors[1]
	self:Update(data)
	self:SetVisible(true)
end

function ToolTip:AddActor(data)
	table.insert(self.Actors, data)

	if #self.Actors <= 1 then
		self:CheckForActor()
	end

	self.Signals.ActorAdded:Fire(#self.Actors)
	return #self.Actors
end

function ToolTip:RemoveActor(data)
	local index = table.find(self.Actors, data)
	if not index then
		return
	end

	table.remove(self.Actors, index)

	self:CheckForActor()

	self.Signals.ActorRemoved:Fire(index)
	return index
end

function ToolTip:ClearAllActors()
	self.Actors = {}
	self:CheckForActor()
end

function ToolTip:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Signals.VisibleChanged:Fire(bool)

	self.Visible = bool
	self.UI.Visible = bool
end

function ToolTip:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ToolTip

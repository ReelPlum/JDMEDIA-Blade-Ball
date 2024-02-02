--[[
Rebirth
2024, 01, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ToolTip = require(script.Parent.Common.ToolTip)
local ItemContainer = require(script.Parent.Common.ItemContainer)
local ItemStacks = require(ReplicatedStorage.Common.ItemsStacks)
local IntToRomanNumerals = require(ReplicatedStorage.Common.IntToRomanNumerals)

local SortFunctions = script.Parent.Common.SortFunctions
local SortUniqueness = require(SortFunctions.SortUniqueness)

local rebirthData = ReplicatedStorage.Data.Rebirths

local function GetRebirthData(rebirth)
	if not rebirth then
		return
	end

	local data = rebirthData:FindFirstChild(rebirth)
	if not data then
		return
	end
	if not data:IsA("ModuleScript") then
		return
	end

	return require(data)
end

local Rebirth = {}
Rebirth.ClassName = "Rebirth"
Rebirth.__index = Rebirth
Rebirth.UIType = "Menu"

function Rebirth.new(template, parent)
	local self = setmetatable({}, Rebirth)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Rebirth:Init()
	--UI
	local InputController = knit.GetController("InputController")

	if self.Template:FindFirstChild(InputController.Platform) then
		self.UI = self.Janitor:Add(self.Template:FindFirstChild(InputController.Platform):Clone())
	else
		self.UI = self.Janitor:Add(self.Template["Normal"]:Clone())
	end

	self.UI.Parent = self.Parent

	self.ToolTip = self.Janitor:Add(ToolTip.new(self.Parent))

	local config = self.UI.Config

	self.CloseButton = config.CloseButton.Value
	self.ProgressLabel = config.Progress.Value
	self.ProgressBar = config.ProgressBar.Value
	self.RebirthButton = config.RebirthButton.Value
	self.RebirthLevel = config.RebirthLevel.Value
	self.Rewards = config.Rewards.Value

	--Create rewards item container
	self.ItemContainer =
		self.Janitor:Add(ItemContainer.new(self.Rewards, ReplicatedStorage.Assets.UI.Item, self.ToolTip, false))

	self.ItemContainer.GetItemInformation = function(item)
		if self.Testing then
			return require(ReplicatedStorage.Data.Items[item])
		end

		local ItemController = knit.GetController("ItemController")
		return ItemController:GetItemData(item)
	end

	self.ItemContainer:UpdateSort(SortUniqueness)

	--Buttons
	self.Janitor:Add(self.CloseButton.MouseButton1Click:Connect(function()
		--Close
		self:SetVisible(false)
	end))

	self.Janitor:Add(self.RebirthButton.MouseButton1Click:Connect(function()
		--Rebirth
		local RebirthService = knit.GetService("RebirthService")

		RebirthService:Rebirth()
	end))

	--Listen for updates
	local CacheController = knit.GetController("CacheController")

	local numberOfLevels = 1
	for _, level in ReplicatedStorage.Data.Levels:GetChildren() do
		if not level:IsA("ModuleScript") then
			continue
		end
		numberOfLevels += 1
	end

	self.Janitor:Add(CacheController.Signals.RebirthLevelChanged:Connect(function(rebirthLevel)
		--Update rebirth level
		self:SetRebirthLevel(rebirthLevel)
	end))
	if CacheController.Cache.Rebirth then
		self:SetRebirthLevel(CacheController.Cache.Rebirth)
	else
		self:SetRebirthLevel(0)
	end

	self.Janitor:Add(CacheController.Signals.LevelChanged:Connect(function(level)
		--Update progress
		self:SetRebirthProgress((level - 1) / numberOfLevels)
	end))
	if CacheController.Cache.Level then
		self:SetRebirthProgress((CacheController.Cache.Level - 1) / numberOfLevels)
	else
		self:SetRebirthProgress(0 / numberOfLevels)
	end

	self:SetVisible(false)
end

function Rebirth:SetRebirthLevel(rebirth)
	--Update UI for level
	local data = GetRebirthData(rebirth + 1)
	if not data then
		--Set
		self:LoadRewards({})
		self:SetRebirthAvailable(false)
		self.RebirthLevel.Text = "Rebirth " .. IntToRomanNumerals(rebirth) .. " (MAX)"
		self.MaxRebirth = true

		return
	end

	self:LoadRewards({})
	self:SetRebirthAvailable(false)
	self.RebirthLevel.Text = `Rebirth {IntToRomanNumerals(rebirth)} → Rebirth {IntToRomanNumerals(rebirth + 1)}`

	--Load rewards
	self:LoadRewards(data.Rewards)
end

function Rebirth:SetRebirthProgress(progress)
	--Sets progress to next rebirth UI. Displays rewards for next rebirth & progressbar for levels
	self.ProgressBar:TweenSize(UDim2.new(progress, 0, 1, 0), "Out", "Quint", 0.05)
	self.ProgressLabel.Text = math.floor(progress * 100) .. "%"

	if progress >= 1 then
		self:SetRebirthAvailable(true)
	else
		return
	end
end

function Rebirth:SetRebirthAvailable(bool)
	--Automatically sets rebirth screen with rewards and boosts displayed
	if self.MaxRebirth then
		bool = false
	end

	self.RebirthButton.Visible = bool
end

function Rebirth:LoadRewards(rewards)
	--Loads given rewards in UI
	local items = {}

	for _, data in rewards do
		if data.Type == "Item" then
			for i = 1, data.Quantity do
				local id = HttpService:GenerateGUID(false)
				items[id] = data.Item
			end
		end
	end

	local stacks, lookup = ItemStacks.GenerateStacks(items)
	self.ItemContainer:UpdateWithStacks(stacks, lookup)
end

function Rebirth:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Visible = self.Visible
end

function Rebirth:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Rebirth

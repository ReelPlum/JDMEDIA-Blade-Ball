--[[
init
2023, 11, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local UnboxingFrame = require(script.UnboxingFrame)
local Item = require(script.Parent.Common.Item)
local ToolTip = require(script.Parent.Common.ToolTip)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local Unboxing = {}
Unboxing.ClassName = "Unboxing"
Unboxing.__index = Unboxing

function Unboxing.new(uiTemplate)
	local self = setmetatable({}, Unboxing)

	self.Janitor = janitor.new()
	self.UnboxJanitor = self.Janitor:Add(janitor.new())

	self.UITemplate = uiTemplate

	self.UnboxingQueue = {}
	self.CurrentlyUnboxing = false

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Unboxing:Init()
	--Setup ui
	self.UI = self.Janitor:Add(self.UITemplate:Clone())
	self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")
	self.ToolTip = self.Janitor:Add(ToolTip.new(self.UI))

	self.Frames = {}
	table.insert(self.Frames, self.UI.Frame.Holder)
	table.insert(self.Frames, self.UI.Frame.CanvasGroup.Items)

	self.UnboxingFrame = UnboxingFrame.new(self, self.Frames)

	--Listen for unboxes
	local ShopController = knit.GetController("ShopController")
	self.Janitor:Add(ShopController.Signals.Unboxed:Connect(function(unboxableId, unboxedItemIndex, IsStrange)
		--
		table.insert(self.UnboxingQueue, { unboxableId, unboxedItemIndex, IsStrange })
		self:CheckQueue()
	end))

	self.Janitor:Add(self.UnboxingFrame.Signals.Finished:Connect(function(unboxable, unboxedItem, IsStrange)
		--Show unboxed item frame
		local ShopController = knit.GetController("ShopController")
		local data = ShopController:GetLootFromUnboxable(unboxable, unboxedItem)

		if data.Type == "Item" then
			local d = table.clone(data.Item)
			if IsStrange then
				if not d.Metadata then
					d.Metadata = {}
				end

				d.Metadata[MetadataTypes.Types.Strange] = 0
			end

			local i = self.UnboxJanitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, d, function()
				return
			end, self.ToolTip, 1))
			i.UI.Parent = self.UI.UnboxedItem.Frame.Frame
			i.UI.Position = UDim2.new(0.5, 0, 0.5, 0)
		elseif data.Type == "Currency" then
			local ui = self.UnboxJanitor:Add(ReplicatedStorage.Assets.UI.Item:Clone())
			ui.Parent = self.UI.UnboxedItem.Frame.Frame
			ui.Position = UDim2.new(0.5, 0, 0.5, 0)
			ui.ItemName.Text = data.Amount
		end

		self.UI.UnboxedItem.Visible = true
	end))

	--Buttons
	self.Janitor:Add(self.UI.UnboxedItem.Frame.ClaimButton.MouseButton1Click:Connect(function()
		--Claim
		self.CurrentlyUnboxing = false
		self.UI.UnboxedItem.Visible = false
		self.UnboxingFrame.UnboxingJanitor:Cleanup()
		self.UI.Enabled = false

		local UIController = knit.GetController("UIController")
		UIController:ShowGameUI()

		self.UnboxJanitor:Cleanup()

		task.wait(1)
		self:CheckQueue()
	end))
end

function Unboxing:CheckQueue()
	if self.CurrentlyUnboxing then
		return
	end

	if not self.UnboxingQueue[1] then
		return
	end

	local data = self.UnboxingQueue[1]
	table.remove(self.UnboxingQueue, 1)

	self:Unbox(data[1], data[2], data[3])
end

function Unboxing:Unbox(unboxableId, unboxedItem, IsStrange)
	--
	self.UnboxJanitor:Cleanup()
	self.CurrentlyUnboxing = true

	self.UI.UnboxedItem.Visible = false
	self.UI.Frame.Visible = true
	self.UI.Enabled = true

	local UIController = knit.GetController("UIController")
	UIController:HideAllUI()

	self.UnboxingFrame:AnimateUnboxing(unboxableId, unboxedItem, IsStrange)
end

function Unboxing:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Unboxing

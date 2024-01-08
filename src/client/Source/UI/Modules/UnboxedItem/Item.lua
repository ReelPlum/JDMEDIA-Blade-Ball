--[[
Item
2023, 12, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Module3D = require(ReplicatedStorage.Common.Module3D)

local Item = {}
Item.ClassName = "Item"
Item.__index = Item

function Item.new(holder, unboxData, model, strange)
	local self = setmetatable({}, Item)

	self.Janitor = janitor.new()

	self.Holder = holder
	self.UnboxData = unboxData
	self.Model = self.Janitor:Add(model)
	self.Strange = strange

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Item:Init()
	--Create UI
	self.UI = self.Janitor:Add(self.Holder.UI.Container:Clone())
	self.UI.Name = "UnboxedItem"
	self.UI.Parent = self.Holder.UI

	local Offset = CFrame.new()
	if self.UnboxData.Type == "Item" then
		--Set UI
		local ItemController = knit.GetController("ItemController")
		local ItemData = ItemController:GetItemData(self.UnboxData.Item.Item)
		self.UI.Display.PetName.Text = ItemData.DisplayName

		local rarityData = ItemController:GetRarityData(ItemData.Rarity)
		self.UI.Display.Rarity.Text = rarityData.DisplayName
		self.Janitor:Add(rarityData.Effect(rarityData, self.UI.Display.Rarity))
		if ItemData.Offset then
			Offset = ItemData.Offset
		end
	end

	if self.Model:IsA("BasePart") then
		self.Model.CanCollide = false
		self.Model.Anchored = true
	end
	for _, i in self.Model:GetDescendants() do
		if i:IsA("BasePart") then
			i.CanCollide = false
			i.Anchored = true
		end
	end

	self.Model:PivotTo(CFrame.new(0, 0, 0))

	self.Controller3D = self.Janitor:Add(Module3D:Attach3D(self.UI.Item, self.Model), "End")
	self.Controller3D:SetActive(true)
	self.Controller3D:SetCFrame(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0))

	task.spawn(function()
		task.wait(5)
		local i = 0

		self.Loop = self.Janitor:Add(RunService.RenderStepped:Connect(function(dt)
			i += dt

			local a = TweenService:GetValue(i / 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			self.Controller3D:SetCFrame(CFrame.new(0, 0, a * 10) * CFrame.Angles(0, math.rad(90), 0))

			if i >= 0.5 then
				self:Destroy()
			end
		end))
	end)

	--Play particle effect at item location & ANIMATE ITEM.
	local i = 0

	self.Loop = self.Janitor:Add(RunService.RenderStepped:Connect(function(dt)
		i += dt

		local a = TweenService:GetValue(i / 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		self.Controller3D:SetCFrame(CFrame.new(0, 0, (1 - a) * 10) * CFrame.Angles(0, math.rad(90), 0))

		if i >= 0.5 then
			self.Loop:Disconnect()
		end
	end))
end

function Item:Position(index)
	--Calculate position for UI
	self.Index = index

	local y = math.ceil(index / 4)
	local parent = self.Holder.UI:FindFirstChild(y)
	if not parent then
		parent = self.Holder.UI.YHolder:Clone()
		parent.Parent = self.Holder.UI
		parent.Visible = true
		parent.Name = y
	end

	--
	self.UI.Parent = parent
	self.UI.Visible = true

	--
	local size = (workspace.CurrentCamera.ViewportSize.Y / math.ceil(#self.Holder.Items / 4))
		/ workspace.CurrentCamera.ViewportSize.Y
	print(size)
	for _, i in self.Holder.UI:GetChildren() do
		if i:IsA("Frame") then
			if i.Visible then
				i.Size = UDim2.new(1, 0, math.min(size, .75), 0)
			end
		end
	end
end

function Item:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Item

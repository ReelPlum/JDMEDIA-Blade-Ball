--[[
Item
2023, 12, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ViewportFrameModel = require(ReplicatedStorage.Common.ViewportFrameModel)

local Item = {}
Item.ClassName = "Item"
Item.__index = Item

function Item.new(template, parent, testing)
	local self = setmetatable({}, Item)

	self.Janitor = janitor.new()
	self.ItemJanitor = self.Janitor:Add(janitor.new())

	self.Template = template
	self.Parent = parent
	self.Testing = testing

	self.Enabled = true
	self.OnClick = nil

	self.Data = nil
	self.StackSize = 0

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Item:Init()
	--Create UI
	self.UI = self.Janitor:Add(self.Template:Clone())
	self.UI.Parent = self.Parent

	--Set presets
	self.Button = self.UI.Config.Button.Value
	self.ViewportFrame = self.UI.Config.ViewportFrame.Value
	self.ItemImage = self.UI.Config.ItemImage.Value
	self.ItemName = self.UI.Config.ItemName.Value
	self.StackText = self.UI.Config.StackSize.Value
	self.EquippedFrame = self.UI.Config.Equipped.Value

	self.EquippedDefaultSize = self.EquippedFrame.Size

	--More ui
	self.Camera = self.Janitor:Add(Instance.new("Camera"))
	self.Camera.Parent = self.ViewportFrame
	self.ViewportFrame.CurrentCamera = self.Camera

	self.VPF = ViewportFrameModel.new(self.ViewportFrame, self.Camera)

	--
	self.Button.MouseButton1Click:Connect(function()
		if not self.OnClick then
			return
		end

		self.OnClick()
	end)

	self.Button.MouseEnter:Connect(function()
		--Show tool tip
	end)

	self.Button.MouseLeave:Connect(function()
		--Hide tool tip
	end)

	--Setup
	self:SetEquipped(false)
end

function Item:SetParent(parent)
	self.UI.Parent = parent
end

function Item:UpdateStack(stackSize)
	--Change stack size
	self.StackSize = stackSize

	if self.StackSize <= 0 then
		self.UI.Visible = false
		return
	end

	self.UI.Visible = true

	if self.StackSize == 1 then
		self.StackText.Visible = false
		return
	end

	self.StackText.Visible = true
	self.StackText.Text = `x{self.StackSize}`
end

function Item:SetEmpty()
	--Set item to empty
	self.ViewportFrame.Visible = false
	self.ItemImage.Visible = true
end

function Item:UpdateData(newData)
	--Update item with new data
	if not newData then
		self:SetEmpty()
		return
	end

	self.Data = newData

	if self.Testing then
		return
	end

	local ItemController = knit.GetController("ItemController")
	local itemData = ItemController:GetItemData(self.Data.Item)
	if not itemData then
		return
	end

	--Set item data
	self:UpdateWithItemData(itemData)
end

function Item:UpdateWithItemData(itemData)
	if not itemData then
		self:SetEmpty()
		return
	end

	self.ItemJanitor:Cleanup()

	--Set name
	self.ItemName.Text = itemData.DisplayName

	if itemData.Image then
		self.ViewportFrame.Visible = false
		self.ItemImage.Visible = true

		--Set image
		self.ItemImage.Image = itemData.Image
	elseif itemData.Model then
		self.ViewportFrame.Visible = true
		self.ItemImage.Visible = false

		--Put in model
		self.ViewportModel = self.ItemJanitor:Add(itemData.Model:Clone())
		self.ViewportModel.Parent = self.ViewportFrame
		self.ViewportModel:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0))
		--Make item fit, and then apply offset.
		self.VPF:SetModel(self.ViewportModel)
		local cf = self.VPF:GetMinimumFitCFrame(CFrame.new(0, 0, 0))
		if itemData.Offset then
			cf = cf * itemData.Offset
		end
		self.Camera.CFrame = cf
	end

	if not self.Testing then
		--Rarity
		local ItemController = knit.GetController("ItemController")
		local rarity = ItemController:GetRarityData(itemData.Rarity)
		if not rarity then
			return
		end

		self.ItemJanitor:Add(rarity.Effect(rarity, self.Button))
	else
		local rarity = require(ReplicatedStorage.Data.Rarities[itemData.Rarity])
		print(rarity)
		self.ItemJanitor:Add(rarity.Effect(rarity, self.Button))
	end
end

function Item:SetEquipped(bool)
	if bool == nil then
		bool = not self.Equipped
	end

	self.Equipped = bool

	self.EquippedFrame.Visible = self.Equipped

	self.EquippedFrame.Size = UDim2.new(0, 0, 0, 0)
	if self.Equipped then
		self.EquippedFrame:TweenSize(self.EquippedDefaultSize, "Out", "Back", 0.1, true)
	end
end

function Item:SetEnabled(bool)
	if bool == nil then
		bool = not self.Enabled
	end

	self.Enabled = bool

	if self.Enabled then
		self.ItemImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
		self.ViewportFrame.ImageColor3 = Color3.fromRGB(255, 255, 255)
	else
		self.ItemImage.ImageColor3 = Color3.fromRGB(0, 0, 0)
		self.ViewportFrame.ImageColor3 = Color3.fromRGB(0, 0, 0)
	end
end

function Item:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Item

--[[
Item
2023, 11, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local FormatNumber = require(ReplicatedStorage.Packages.FormatNumber)

local abbreviations = FormatNumber.Main.Notation.compactWithSuffixThousands({
	"K",
	"M",
	"B",
	"T",
})
local formatter = FormatNumber.Main.NumberFormatter.with():Notation(abbreviations)
local ViewportFrameModel = require(ReplicatedStorage.Common.ViewportFrameModel)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)
local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local Item = {}
Item.ClassName = "Item"
Item.__index = Item

function Item.new(UI, data, clicked, tooltip, stackSize)
	local self = setmetatable({}, Item)

	self.Janitor = janitor.new()
	self.ItemJanitor = self.Janitor:Add(janitor.new())

	self.UI = self.Janitor:Add(UI:Clone())
	self.Clicked = clicked
	self.Data = data
	self.ToolTip = tooltip
	self.StackSize = stackSize or 0

	self.Camera = self.Janitor:Add(Instance.new("Camera"))
	self.Camera.Parent = workspace
	self.UI.ItemViewport.CurrentCamera = self.Camera

	self.VPF = ViewportFrameModel.new(self.UI.ItemViewport, self.Camera)

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Item:Init()
	--Setup Visuals for UI
	self:Update(self.Data, self.StackSize)

	--Events
	self.Janitor:Add(self.UI.MouseEnter:Connect(function()
		--Hover animation

		--Show tooltip and get information to display on tooltip
		self.ToolTip:AddActor(self.ToolTipData)
	end))

	self.Janitor:Add(self.UI.MouseLeave:Connect(function()
		--Hover animation

		--Tell tooltip that mouse is not on this item anymore
		self.ToolTip:RemoveActor(self.ToolTipData)
	end))

	self.Janitor:Add(self.UI.MouseButton1Click:Connect(function()
		--Click Animation

		--Clicked
		self.Clicked()
	end))

	local CacheController = knit.GetController("CacheController")
	self.Janitor:Add(CacheController.Signals.ItemCopiesChanged:Connect(function()
		self:Update(self.Data, self.StackSize)
	end))

	self:Update(self.Data, self.StackSize)
end

function Item:Update(information, stackSize, click)
	--Updates with new data

	if not information then
		warn("Got no information...")
		return
	end

	warn("Updating item!")

	self.StackSize = stackSize or 0
	self.ItemJanitor:Cleanup()

	local ItemController = knit.GetController("ItemController")
	local index = self.ToolTip:RemoveActor(self.ToolTipData)

	local itemData = ItemController:GetItemData(information.Item)
	if not itemData then
		return
	end

	self.Data = information
	if click then
		self.Clicked = click
	end
	local CacheController = knit.GetController("CacheController")
	local rarityData = ItemController:GetRarityData(itemData.Rarity)

	if stackSize then
		if stackSize <= 0 then
			self.UI.Visible = false
			return
		end
		if stackSize > 1 then
			self.UI.StackSize.Visible = true
			self.UI.StackSize.Text = "x" .. formatter:Format(stackSize)
		else
			self.UI.StackSize.Visible = false
		end
	else
		self.UI.StackSize.Visible = false
	end

	--Setup data for tooltip
	self.ToolTipData = {}
	table.insert(self.ToolTipData, {
		Type = "Header",
		Text = itemData.DisplayName,
		Item = self.Data.Item,
	})
	table.insert(self.ToolTipData, {
		Type = "Rarity",
		Data = rarityData,
		Item = self.Data.Item,
	})
	--Add metadata
	if self.Data.Metadata then
		for metadata, data in self.Data.Metadata do
			table.insert(self.ToolTipData, { Type = metadata, Data = data, Item = self.Data.Item })
		end
	end

	if table.find(GeneralSettings.ItemTypesToTrackCopiesOf, itemData.ItemType) then
		local amount = 0
		if CacheController.Cache.ItemCopies then
			amount = CacheController.Cache.ItemCopies[self.Data.Item]
		end

		table.insert(self.ToolTipData, {
			Type = "Copies",
			Copies = amount,
			Item = self.Data.Item,
		})
	end

	if index then
		self.ToolTip:AddActor(self.ToolTipData)
	end

	--self.UI:WaitForChild("ItemImage").Image = itemData.Image
	self.UI.ItemName.Text = itemData.DisplayName

	if itemData.Image then
		self.UI.ItemViewport.Visible = false
		self.UI.ItemImage.Visible = true
		self.UI.ItemImage.Image = itemData.Image
	elseif itemData.Model then
		self.UI.ItemViewport.Visible = true
		self.UI.ItemImage.Visible = false

		--Put in model
		self.ViewportModel = self.ItemJanitor:Add(itemData.Model:Clone())
		self.ViewportModel.Parent = self.UI.ItemViewport
		self.ViewportModel:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0))
		--Make item fit, and then apply offset.
		self.VPF:SetModel(self.ViewportModel)
		local cf = self.VPF:GetMinimumFitCFrame(CFrame.new(0, 0, 0))
		if itemData.Offset then
			cf = cf * itemData.Offset
		end
		self.Camera.CFrame = cf
	else
		self.UI.ItemImage.Visible = false
		self.UI.ItemViewport.Visible = false
	end
	self.ItemJanitor:Add(rarityData.Effect(rarityData, self.UI))
end

function Item:Destroy()
	self.ToolTip:RemoveActor(self.ToolTipData)

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Item

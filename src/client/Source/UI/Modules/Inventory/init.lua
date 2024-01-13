--[[
init
2023, 12, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemContainer = require(script.Parent.Common.ItemContainer)
local ItemInteractionMenu = require(script.Parent.Common.ItemInteractionMenu)
local ToolTip = require(script.Parent.Common.ToolTip)

local SortFunctions = script.Parent.Common.SortFunctions
local SortName = require(SortFunctions.SortName)
local SortRarity = require(SortFunctions.SortRarity)
local SortUniqueness = require(SortFunctions.SortUniqueness)

local ItemTypes = script.ItemTypes

local Inventory = {}
Inventory.ClassName = "Inventory"
Inventory.__index = Inventory

function Inventory.new(template, parent, testing)
	local self = setmetatable({}, Inventory)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent

	self.ItemTypes = {}
	self.Pages = {}
	self.SortFunction = nil
	self.ItemUI = {}
	self.SearchTerm = nil
	self.InteractionMenu =
		self.Janitor:Add(ItemInteractionMenu.new(ReplicatedStorage.Assets.UI.ItemInteractionMenu, self.Parent))

	self.Janitor:Add(self.InteractionMenu.Signals.VisibilityChanged:Connect(function(bool)
		self.ToolTip:Disable(bool)
	end))

	self.Testing = testing

	self.Pages = {
		["Knives"] = {
			-- ItemTypes = {
			-- 	"Knife",
			-- },
			ItemTypes = { "Knife" },
			Rank = 3,
		},
		["Abilities"] = {
			-- ItemTypes = {
			-- 	"Knife",
			-- },
			ItemTypes = { "Ability" },
			Rank = 2,
		},
		["Cosmetics"] = {
			ItemTypes = { "Tag", "Ball", "Unboxable", "Autograph", "NameTag", "Book" },
			Rank = 1,
		},
	}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Inventory:Init()
	--UI
	local InputController = knit.GetController("InputController")

	if self.Template:FindFirstChild(InputController.Platform) then
		self.UI = self.Janitor:Add(self.Template:FindFirstChild(InputController.Platform):Clone())
	else
		self.UI = self.Janitor:Add(self.Template["Normal"]:Clone())
	end

	self.UI.Parent = self.Parent

	self.ToolTip = self.Janitor:Add(ToolTip.new(self.Parent))

	--Get ui
	local config = self.UI.Config
	self.ItemContainer = config:WaitForChild("ScrollingFrame").Value
	self.NavigationButtons = config:WaitForChild("NavigationButtons").Value
	self.SearchBar = config:WaitForChild("Search").Value
	self.CloseButton = config:WaitForChild("CloseButton").Value
	self.UniquenessSort = config:WaitForChild("UniquenessSort").Value
	self.NameSort = config:WaitForChild("NameSort").Value
	self.RaritySort = config:WaitForChild("RaritySort").Value

	self.DefaultButtonColor = self.NavigationButtons:WaitForChild("Button").BackgroundColor3

	--Create container
	self.ItemContainer = self.Janitor:Add(
		ItemContainer.new(self.ItemContainer, ReplicatedStorage.Assets.UI.Item, self.ToolTip, self.Testing)
	)
	self.ItemContainer.GetItemInformation = function(item)
		if self.Testing then
			return require(ReplicatedStorage.Data.Items[item])
		end

		local ItemController = knit.GetController("ItemController")
		return ItemController:GetItemData(item)
	end

	self.ItemContainer.OnClick = function(ids, data)
		--Handle use
		if self.Testing then
			return
		end

		local ItemController = knit.GetController("ItemController")
		local itemData = ItemController:GetItemData(data.Item)

		if not ItemTypes:FindFirstChild(itemData.ItemType) then
			return
		end

		local useData = require(ItemTypes:FindFirstChild(itemData.ItemType))
		useData.Use(ids, data)
	end

	self.ItemContainer.OnRightClick = function(ids, data)
		--Show interaction menu
		local pos = UserInputService:GetMouseLocation()

		if self.Testing then
			self.InteractionMenu:SetData(
				require(ItemTypes:FindFirstChild("Knife")).Interactions,
				ids,
				UDim2.new(0, pos.X, 0, pos.Y)
			)
			return
		end

		local ItemController = knit.GetController("ItemController")
		local itemData = ItemController:GetItemData(data.Item)

		if not ItemTypes:FindFirstChild(itemData.ItemType) then
			return
		end

		local useData = require(ItemTypes:FindFirstChild(itemData.ItemType))

		local interactions = {}
		for index, interaction in useData.Interactions do
			if not interaction.Check(data, itemData, ids, self.Equipped) then
				continue
			end

			table.insert(interactions, interaction)
		end

		--Show interaction frame
		self.InteractionMenu:SetData(interactions, ids, UDim2.new(0, pos.X, 0, pos.Y), data)
	end

	--Sort buttons
	self.ItemContainer:UpdateSort(SortRarity)

	self.Janitor:Add(self.NameSort.MouseButton1Click:Connect(function()
		self.ItemContainer:UpdateSort(SortName)
	end))

	self.Janitor:Add(self.RaritySort.MouseButton1Click:Connect(function()
		self.ItemContainer:UpdateSort(SortRarity)
	end))

	self.Janitor:Add(self.UniquenessSort.MouseButton1Click:Connect(function()
		self.ItemContainer:UpdateSort(SortUniqueness)
	end))

	--Create navigation buttons
	self.NavigationButtons.Button.Visible = false
	for name, data in self.Pages do
		local button = self.Janitor:Add(self.NavigationButtons.Button:Clone())
		button.Name = name
		button.Parent = self.NavigationButtons
		button.LayoutOrder = -data.Rank
		button.Visible = true

		self.Janitor:Add(button.MouseButton1Click:Connect(function()
			self:ChangePage(name)
		end))
	end

	--Close button
	self.Janitor:Add(self.CloseButton.MouseButton1Click:Connect(function()
		self:SetVisible(false)
	end))

	--Search
	self.Janitor:Add(self.SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
		self.ItemContainer:UpdateSearchTerm(self.SearchBar.ContentText)
	end))

	--Listen for inventory updates
	if self.Testing then --Do not do it in testing mode tho
		self.ItemContainer:UpdateEquippedItems({ 1 })
		self:ChangePage("Testing")
		self:SetVisible(true)
		return
	end

	self:ChangePage("Knives")
	self:SetVisible(true)

	local ItemController = knit.GetController("ItemController")
	local EquipmentController = knit.GetController("EquipmentController")

	self.Janitor:Add(ItemController.Signals.StacksUpdated:Connect(function()
		local stacks, lookup = ItemController:GetInventoryInStacks()
		self:UpdateWithStack(stacks, lookup)
	end))

	self.Janitor:Add(EquipmentController.Signals.EquipmentChanged:Connect(function()
		self.ItemContainer:UpdateEquippedItems(EquipmentController:GetEquippedItems())
	end))
end

function Inventory:ChangePage(newPage)
	--Change page
	if not self.Pages[newPage] then
		return
	end

	for page, _ in self.Pages do
		local button = self.NavigationButtons:FindFirstChild(page)
		if page == newPage then
			if button then
				local color = Vector3.new(
					self.DefaultButtonColor.r * 255,
					self.DefaultButtonColor.g * 255,
					self.DefaultButtonColor.b * 255
				) - Vector3.new(100, 100, 100)
				color =
					Vector3.new(math.clamp(color.X, 0, 255), math.clamp(color.Y, 0, 255), math.clamp(color.Z, 0, 255))

				button.BackgroundColor3 = Color3.fromRGB(color.X, color.Y, color.Z)
				continue
			end
		end

		if button then
			button.BackgroundColor3 = self.DefaultButtonColor
		end
	end

	self.CurrentPage = newPage
	self.ItemContainer:UpdateItemTypes(self.Pages[newPage].ItemTypes)
end

function Inventory:UpdateWithStack(stack, lookup)
	--Update item data
	self.ItemContainer:UpdateWithStacks(stack, lookup)
end

function Inventory:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.ToolTip:ClearAllActors()
	self.InteractionMenu:SetVisible(false)

	self.Visible = bool
	self.UI.Visible = bool
end

function Inventory:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Inventory

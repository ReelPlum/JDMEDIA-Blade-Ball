--[[
WorldItem
2024, 01, 24
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ViewportFrameModel = require(ReplicatedStorage.Common.ViewportFrameModel)

local WorldItem = {}
WorldItem.ClassName = "WorldItem"
WorldItem.__index = WorldItem

function WorldItem.new(shopId, data, instance)
	local self = setmetatable({}, WorldItem)

	self.Janitor = janitor.new()

	self.ShopId = shopId
	self.Data = data
	self.WorldInstance = instance

	self.Enabled = true

	if not self.WorldInstance:FindFirstChildOfClass("ProximityPrompt") then
		warn("Could not find prompt for world store " .. self.WorldInstance:GetFullName())
		return self
	end

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function WorldItem:Init()
	--Create in world
	local ItemController = knit.GetController("ItemController")
	local UnboxingController = knit.GetController("UnboxingController")

	local itemData = ItemController:GetItemData(self.Data.Item)

	if not itemData.Model then
		warn("World item needs a model for item!")
		return
	end

	self.Model = self.Janitor:Add(itemData.Model:Clone())

	if self.Model:IsA("BasePart") then
		self.Model.CanCollide = false
		self.Model.Anchored = true
	end
	for _, v in self.Model:GetDescendants() do
		if not v:IsA("BasePart") then
			continue
		end
		v.CanCollide = false
		v.Anchored = true
	end

	self.Model.Parent = workspace

	local size = self.WorldInstance:GetExtentsSize()

	local modelSize
	if self.Model:IsA("Model") then
		modelSize = self.Model:GetExtentsSize()
	elseif self.Model:IsA("BasePart") then
		modelSize = self.Model.Size
	end

	self.ModelCenter =
		CFrame.new(0, size.Y / 2 + modelSize.Y / 2 + math.max(modelSize.X, modelSize.Y, modelSize.Z) / 2 + 0.5, 0)

	--Listen for proximity
	local prompt = self.WorldInstance:FindFirstChildOfClass("ProximityPrompt")
	prompt.Style = Enum.ProximityPromptStyle.Custom

	self.UI = self.Janitor:Add(ReplicatedStorage.Assets.UI.WorldItem:Clone())
	self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")
	self.UI.Adornee = self.WorldInstance
	self.UI.Enabled = false

	local Config = self.UI.Config
	self.Button = Config.Button.Value
	self.Title = Config.Title.Value
	self.Price = Config.Price.Value
	self.Holder = Config.Holder.Value

	--Create UI for purchaseable items. If item is an unboxable then create unboxable items
	if itemData.ItemType == "Unboxable" then
		--Create ui
		local unboxableData = UnboxingController:GetUnboxable(itemData.Unboxable)
		--Create chance uis
		local chances = {}
		local totalWeight = 0

		for _, itemData in unboxableData.DropList do
			totalWeight += itemData.Weight
		end

		for _, v in unboxableData.DropList do
			local itemData = ItemController:GetItemData(v.Item.Item)

			local f
			if itemData.Image then
				f = self.Janitor:Add(Instance.new("ImageLabel"))
				f.Image = itemData.Image
				local uicorner = Instance.new("UICorner")
				uicorner.CornerRadius = UDim.new(0, 5)
				uicorner.Parent = f
			elseif itemData.Model then
				f = self.Janitor:Add(Instance.new("ViewportFrame"))
				f.Size = UDim2.new(0, 50, 0, 50)
				f.Visible = false
				f.Parent = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChildOfClass("ScreenGui")

				local UICorner = Instance.new("UICorner")
				UICorner.Parent = f
				UICorner.CornerRadius = UDim.new(1, 0)

				local m = itemData.Model:Clone()
				m.Parent = f
				local c = Instance.new("Camera")
				c.Parent = f
				f.CurrentCamera = c

				m:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0))

				local VPF = ViewportFrameModel.new(f, c)
				VPF:SetModel(m)
				local cf = VPF:GetMinimumFitCFrame(CFrame.new(0, 0, 0))
				if itemData.Offset then
					cf = cf * itemData.Offset
				end
				c.CFrame = cf
			else
				f = self.Janitor:Add(Instance.new("Frame"))
			end
			f.LayoutOrder = (v.Weight / totalWeight) * 100

			local label = self.Janitor:Add(Instance.new("TextLabel"))
			label.Text = math.floor((v.Weight / totalWeight) * 100) .. "%"
			label.Size = UDim2.new(1, 0, 0.25, 0)
			label.AnchorPoint = Vector2.new(0.5, 1)
			label.Position = UDim2.new(0.5, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.TextScaled = true
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.Parent = f

			local UIStroke = Instance.new("UIStroke")
			UIStroke.Parent = label
			UIStroke.Thickness = 3

			f.Parent = self.Holder
			f.Visible = true
		end
	else
		--Hide ui
		self.Holder.Visible = false
		self.UI.Size = UDim2.new(self.UI.Size.X.Scale, 0, self.UI.Size.Y.Scale * (1 - self.Holder.Size.Y.Scale), 0)
	end

	self.Title.Text = itemData.DisplayName

	--Set price
	self.Price.Label.Text = self.Data.Price.Amount
	--set image also

	--Set activation button
	self.Button.MouseButton1Down:Connect(function()
		prompt:InputHoldBegin()
	end)

	self.Button.MouseButton1Up:Connect(function()
		prompt:InputHoldEnd()
	end)

	local buttonSize = self.Button.Size
	self.Janitor:Add(prompt.TriggerEnded:Connect(function()
		--self.Button:TweenSize(buttonSize, "Out", "Back", 0.1, true)
	end))

	local UIController = knit.GetController("UIController")
	self.Janitor:Add(prompt.Triggered:Connect(function()
		if not self.Enabled then
			return
		end

		--self.Button:TweenSize(buttonSize - UDim2.new(0.2, 0, 0.2, 0), "Out", "Back", 0.05, true)

		warn("Hi")
		--Purchase item
		--prompt.Enabled = false
		self.Enabled = false

		local ShopService = knit.GetService("ShopService")
		ShopService:PurchaseItem(self.ShopId):andThen(function(items)
			if not items then
				--prompt.Enabled = true
				self.Enabled = true
				return
			end

			--if unboxable ask if they want to unbox it
			if itemData.ItemType == "Unboxable" then
				--Ask if player would want to unbox unboxable automatically
				local confirmUI = UIController:GetUI("ConfirmationPrompt")
				confirmUI:SetVisible(true, nil, function()
					local ids = {}
					for id, _ in items do
						table.insert(ids, id)
					end

					local UnboxingService = knit.GetService("UnboxingService")

					UnboxingService:UnboxItem(ids)

					--prompt.Enabled = true
					self.Enabled = true
				end, function()
					--prompt.Enabled = true
					self.Enabled = true
				end, `You just bought the unboxable {itemData.DisplayName}! Would you like to unbox it now?`)
			end
		end)
	end))

	self.Janitor:Add(prompt.PromptShown:Connect(function()
		--Show billboard gui with price, purchase & rarities
		warn("Show")
		self.UI.Enabled = true
	end))

	self.Janitor:Add(prompt.PromptHidden:Connect(function()
		--Hide billboard gui with price, purchase & rarities
		warn("Hide")
		self.UI.Enabled = false
	end))

	--Show UI upon near
	local x = 0
	local y = 0
	local z = 0

	local dx = math.random(-2000, 2000) / 100
	local dy = math.random(-2000, 2000) / 100
	local dz = math.random(-2000, 2000) / 100

	self.Janitor:Add(RunService.RenderStepped:Connect(function(dt)
		--Animate model float
		x += dt
		y += dt
		z += dt

		self.Model:PivotTo(
			self.WorldInstance:GetPivot()
				* self.ModelCenter
				* CFrame.new(0, math.sin(y) * 0.25, 0)
				* CFrame.Angles(math.rad(x * dx), -math.rad(y * dy), -math.rad(z * dz))
		)
	end))
end

function WorldItem:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return WorldItem

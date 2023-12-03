--[[
init
2023, 11, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Loading = {}
Loading.ClassName = "Loading"
Loading.__index = Loading

function Loading.new(uiTemplate)
	local self = setmetatable({}, Loading)

	self.Janitor = janitor.new()
	self.AnimationJanitor = self.Janitor:Add(janitor.new())

	self.UITemplate = uiTemplate

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Loading:Init()
	local LoadingController = knit.GetController("LoadingController")

	if RunService:IsStudio() then
		local UserService = knit.GetService("UserService")
		UserService:Ready()

		return
	end

	self.UI = self.Janitor:Add(self.UITemplate:Clone())
	self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

	self:SetVisible(true)

	self:StartAnimation()

	--Wait for data loaded
	if not LoadingController.DataLoaded then
		LoadingController.Signals.DataLoaded:Wait()
	end

	--Wait for character loaded
	if not LocalPlayer:HasAppearanceLoaded() then
		LocalPlayer.CharacterAppearanceLoaded:Wait()
	end

	self.UI.Frame:TweenPosition(UDim2.new(0, 0, -1, 0), "In", "Linear", 0.25, true)
	task.wait(0.3)

	self:SetVisible(false)

	local UserService = knit.GetService("UserService")
	UserService:Ready()
end

function Loading:StartAnimation()
	--Wait for fully loaded
	self.UI.Frame.Bar.Visible = false
	self.UI.Frame.JDGamesLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.UI.Frame.JDGamesLogo.Size = UDim2.new(0, 0, 0, 0)
	self.UI.Frame.JDGamesLogo.Rotation = -35

	ContentProvider:PreloadAsync({ self.UI.Frame.JDGamesLogo, ReplicatedStorage.Assets.Sounds.IntroSound })

	--Launch animation
	ReplicatedStorage.Assets.Sounds.IntroSound:Play()
	task.wait(0.4)
	--self.UI.Frame.JDGamesLogo:TweenSize(UDim2.new(0.3, 0, 1, 0), "Out", "Back", 0.4, true)
	local Tween = TweenService:Create(
		self.UI.Frame.JDGamesLogo,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(0.3, 0, 1, 0),
			Rotation = 0,
		}
	)
	Tween:Play()

	ReplicatedStorage.Assets.Sounds.IntroSound.Ended:Wait()
	self.UI.Frame.JDGamesLogo:TweenPosition(UDim2.new(0.5, 0, 0.4, -10), "Out", "Quint", 0.1, true)

	--Waiting animation
	self.UI.Frame.Bar.Frame.Size = UDim2.new(0, 0, 1, 0)
	self.UI.Frame.Bar.Visible = true

	task.spawn(function()
		while self.Visible do
			self.UI.Frame.Bar.Frame.AnchorPoint = Vector2.new(0, 0)
			self.UI.Frame.Bar.Frame.Position = UDim2.new(0, 0, 0, 0)
			self.UI.Frame.Bar.Frame:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quint", 0.25, true)
			task.wait(0.3)
			self.UI.Frame.Bar.Frame.AnchorPoint = Vector2.new(1, 0)
			self.UI.Frame.Bar.Frame.Position = UDim2.new(1, 0, 0, 0)
			self.UI.Frame.Bar.Frame:TweenSize(UDim2.new(0, 0, 1, 0), "Out", "Quint", 0.3, true)
			task.wait(0.35)
			self.UI.Frame.Bar.Frame:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quint", 0.25, true)
			task.wait(0.3)
			self.UI.Frame.Bar.Frame:TweenSizeAndPosition(
				UDim2.new(0, 0, 1, 0),
				UDim2.new(0, 0, 0, 0),
				"Out",
				"Quint",
				0.3,
				true
			)
			task.wait(0.35)
		end
	end)
end

function Loading:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.AnimationJanitor:Cleanup()

	self.Visible = bool
	self.UI.Enabled = self.Visible
end

function Loading:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Loading

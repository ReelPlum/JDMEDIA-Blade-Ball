--[[
BallController
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local BallController = knit.CreateController({
	Name = "BallController",
	Signals = {
		LocalPlayerTargeted = signal.new(),
		BallChangedTarget = signal.new(),
	},

	BallsTargetingLocalPlayer = {},
})

local highlights = {}
local particles = {}

local function GetBall(id: string): PVInstance | nil
	for _, ball in CollectionService:GetTagged("Ball") do
		if ball:GetAttribute("Id") == id then
			return ball
		end
	end

	return nil
end

local function IsTagetLocalPlayer(target: Model): boolean
	return target == LocalPlayer.Character
end

local function CreateHighlight()
	local highlight = Instance.new("Highlight")
	highlight.Parent = ReplicatedStorage

	return highlight
end

local function HighlightBall(ball)
	-- local particleEmitter = ball.Attachment:FindFirstChild("TargetEmitter")
	-- if particleEmitter then
	-- 	particleEmitter.Enabled = true
	-- end

	ball.BillboardGui.Enabled = true

	ball.Material = Enum.Material.Neon
	ball.Color = Color3.fromRGB(0, 255, 64)
end

local function UnhighlightBall(ball)
	-- local particleEmitter = ball.Attachment:FindFirstChild("TargetEmitter")
	-- if particleEmitter then
	-- 	particleEmitter.Enabled = false
	-- end

	ball.BillboardGui.Enabled = false

	ball.Material = Enum.Material.Glass
	ball.Color = Color3.fromRGB(0, 231, 58)
end

function BallController:GetNearestBall(position)
	local closests, lowestDist = nil, math.huge

	for _, ball in CollectionService:GetTagged("Ball") do
		local dist = (ball.CFrame.Position - position).Magnitude
		if dist < lowestDist then
			closests = ball
			lowestDist = dist
		end
	end

	return closests, closests:GetAttribute("Id")
end

function BallController:KnitStart()
	local BallService = knit.GetService("BallService")

	BallService.TargetChanged:Connect(function(id, target)
		local ball = GetBall(id)
		if not ball then
			warn("Ball not found")
			return
		end

		if not highlights[ball] then
			highlights[ball] = CreateHighlight()

			highlights[ball].Destroying:Connect(function()
				highlights[ball] = nil
			end)
		end

		highlights[ball].Adornee = target

		if not particles[ball] then
			particles[ball] = ReplicatedStorage.Assets.VFX.TargetEmitter:Clone()

			particles[ball].Destroying:Connect(function()
				particles[ball] = nil
			end)
		end
		if target:IsA("Model") then
			particles[ball].Parent = target.PrimaryPart
		else
			particles[ball].Parent = target
		end

		BallController.Signals.BallChangedTarget:Fire(ball, target)

		if IsTagetLocalPlayer(target) then
			BallController.Signals.LocalPlayerTargeted:Fire(ball)

			if not table.find(BallController.BallsTargetingLocalPlayer, ball) then
				table.insert(BallController.BallsTargetingLocalPlayer, ball)
			end

			HighlightBall(ball)
			return
		end

		--Remove from target list
		if table.find(BallController.BallsTargetingLocalPlayer, ball) then
			table.remove(
				BallController.BallsTargetingLocalPlayer,
				table.find(BallController.BallsTargetingLocalPlayer, ball)
			)
		end

		UnhighlightBall(ball)
	end)

	CollectionService:GetInstanceRemovedSignal("Ball"):Connect(function(ball)
		if table.find(BallController.BallsTargetingLocalPlayer, ball) then
			table.remove(
				BallController.BallsTargetingLocalPlayer,
				table.find(BallController.BallsTargetingLocalPlayer, ball)
			)
		end

		if highlights[ball] then
			highlights[ball]:Destroy()
			highlights[ball] = nil
		end
		if particles[ball] then
			particles[ball]:Destroy()
			particles[ball] = nil
		end
	end)
end

function BallController:KnitInit() end

return BallController

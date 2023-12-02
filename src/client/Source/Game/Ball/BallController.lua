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
		BallAdded = signal.new(),
		BallRemoved = signal.new(),
	},

	BallsTargetingLocalPlayer = {},
})

local highlights = {}
local particles = {}

local balls = {}
local targets = {}

local function GetBall(id: string): PVInstance | nil
	-- for _, ball in CollectionService:GetTagged("Ball") do
	-- 	if ball:GetAttribute("Id") == id then
	-- 		return ball
	-- 	end
	-- end

	return balls[id]
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

	local billboard = ball:FindFirstChild("BillboardGui")
	if not billboard then
		return
	end

	billboard.Enabled = true

	ball.Material = Enum.Material.Neon
end

local function UnhighlightBall(ball)
	-- local particleEmitter = ball.Attachment:FindFirstChild("TargetEmitter")
	-- if particleEmitter then
	-- 	particleEmitter.Enabled = false
	-- end

	local billboard = ball:FindFirstChild("BillboardGui")
	if not billboard then
		return
	end
	billboard.Enabled = false

	ball.Material = Enum.Material.Glass
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

	if not closests then
		return
	end

	return closests, closests:GetAttribute("Id")
end

function BallController:KnitStart()
	local BallService = knit.GetService("BallService")

	local function BallAdded(id, target)
		if not target then
			return
		end
		targets[id] = target

		local ball = GetBall(id)
		if not ball then
			warn("Ball not found")
			return
		end
		if not ball:IsDescendantOf(workspace) then
			return
		end

		warn("Target changed!")
		if not highlights[ball] then
			highlights[ball] = CreateHighlight()

			highlights[ball].Destroying:Connect(function()
				highlights[ball] = nil
			end)
		end

		highlights[ball].Adornee = target

		warn(ball:GetFullName())
		ball:WaitForChild("Highlight").Enabled = true

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

		if IsTagetLocalPlayer(target) then
			warn("Localplayer targeted!")
			BallController.Signals.LocalPlayerTargeted:Fire(ball)

			if not table.find(BallController.BallsTargetingLocalPlayer, ball) then
				table.insert(BallController.BallsTargetingLocalPlayer, ball)
			end

			HighlightBall(ball)
			return
		end

		BallController.Signals.BallChangedTarget:Fire(ball, target)

		--Remove from target list
		if table.find(BallController.BallsTargetingLocalPlayer, ball) then
			table.remove(
				BallController.BallsTargetingLocalPlayer,
				table.find(BallController.BallsTargetingLocalPlayer, ball)
			)
		end

		UnhighlightBall(ball)
	end

	BallService.TargetChanged:Connect(function(id, target)
		BallAdded(id, target)
	end)

	CollectionService:GetInstanceAddedSignal("Ball"):Connect(function(ball)
		if not ball:IsDescendantOf(workspace) then
			return
		end

		warn("BALL ADDED!")
		BallController.Signals.BallAdded:Fire(ball)

		local id = ball:GetAttribute("Id")
		balls[id] = ball
		BallAdded(id, targets[id])
	end)

	CollectionService:GetInstanceRemovedSignal("Ball"):Connect(function(ball)
		if table.find(BallController.BallsTargetingLocalPlayer, ball) then
			table.remove(
				BallController.BallsTargetingLocalPlayer,
				table.find(BallController.BallsTargetingLocalPlayer, ball)
			)
		end

		BallController.Signals.BallRemoved:Fire(ball)

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

--[[
BallController
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local BallController = knit.CreateController({
	Name = "BallController",
	Signals = {
		LocalPlayerTargeted = signal.new(),
		BallChangedTarget = signal.new(),
	},

	BallsTargetingLocalPlayer = {},
})

local highlights = {}

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
	local particleEmitter = ball.Attachment:FindFirstChild("TargetEmitter")
	if particleEmitter then
		particleEmitter.Enabled = true
	end

	ball.Material = Enum.Material.Neon
	ball.Color = Color3.fromRGB(122, 0, 0)
end

local function UnhighlightBall(ball)
	local particleEmitter = ball.Attachment:FindFirstChild("TargetEmitter")
	if particleEmitter then
		particleEmitter.Enabled = false
	end

	ball.Material = Enum.Material.Marble
	ball.Color = Color3.fromRGB(99, 95, 98)
end

function BallController:KnitStart()
	local BallService = knit.GetService("BallService")

	BallService.TargetChanged:Connect(function(id, target)
		local ball = GetBall(id)
		if not ball then
			warn("Ball not found")
			return
		end

		local highlight = highlights[ball]
		if not highlight then
			highlights[ball] = CreateHighlight()
		end

		highlights[ball].Adornee = target

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

		if not highlights[ball] then
			return
		end

		highlights[ball]:Destroy()
		highlights[ball] = nil
	end)
end

function BallController:KnitInit() end

return BallController

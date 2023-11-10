--[[
BallService
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local BallClass = require(script.Parent.Ball)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local HITCOOLDOWN = GeneralSettings.Game.Cooldowns.Hit

local BallService = knit.CreateService({
	Name = "BallService",
	Client = {
		TargetChanged = knit.CreateSignal(),
	},
	Signals = {},
})

local Balls = {}

function BallService.Client:HitBall(player, id, cameraLookVector: Vector3, characterLookVector: Vector3)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	if not cameraLookVector then
		return
	end

	if not characterLookVector then
		return
	end

	if not typeof(cameraLookVector) == "Vector3" then
		return
	end
	if not typeof(characterLookVector) == "Vector3" then
		return
	end

	cameraLookVector = cameraLookVector.Unit
	characterLookVector = characterLookVector.Unit

	return BallService:HitBall(user, id, cameraLookVector, characterLookVector)
end

function BallService:CreateNewBall(location: CFrame, currentGame)
	--Creates new ball at the given location.
	--It also destroys the old ball
	-- CurrentBall = BallClass.new(location, ReplicatedStorage.Ball, function()
	-- 	return currentGame:GetUsers()
	-- end)
	local ball = BallClass.new(location, ReplicatedStorage.Ball, function()
		return currentGame:GetUsers()
	end)
	Balls[ball.Id] = ball

	ball.Signals.TargetChanged:Connect(function(target)
		BallService.Client.TargetChanged:FireAll(ball.Id, target.Character)
	end)

	task.spawn(function()
		task.wait(2)
		ball:Respawn()
	end)

	return ball
end

local function CheckUsersCooldown(user)
	if not user.LastHit then
		return true
	end

	return tick() - user.LastHit >= HITCOOLDOWN
end

function BallService:HitBall(user, id, cameraLookVector, characterLookVector)
	--Hits ball. Based on camera & character lookVector
	local ball = Balls[id]
	if not ball then
		return
	end

	if not CheckUsersCooldown(user) then
		return false
	end

	if not user.Character then
		return false
	end
	if not user.Character:IsDescendantOf(workspace) then
		return false
	end

	user.LastHit = tick()

	--Play hit animation here

	--Play slash sound here
	local SoundService = knit.GetService("SoundService")
	SoundService:PlaySoundOnPart(ReplicatedStorage.Assets.Sounds.Block, user.Character)

	--Hit here
	ball:Hit(user, cameraLookVector, characterLookVector)
	return true
end

function BallService:DespawnBall(id)
	--Despawns current bladeball
	if not Balls[id] then
		return
	end

	Balls[id]:Destroy()
	Balls[id] = nil
end

function BallService:KnitStart()
	--Loop updating ball
	RunService.Heartbeat:Connect(function(deltaTime)
		for _, ball in Balls do
			if not ball then
				return
			end
			if ball.Destroyed then
				return
			end

			ball:Update(deltaTime)
		end
	end)
end

function BallService:KnitInit() end

return BallService

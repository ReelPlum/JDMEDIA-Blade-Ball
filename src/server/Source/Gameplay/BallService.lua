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

local CurrentBall = nil

function BallService.Client:HitBall(player, cameraLookVector: Vector3, characterLookVector: Vector3)
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

	BallService:HitBall(user, cameraLookVector, characterLookVector)
end

function BallService:CreateNewBall(location: CFrame, currentGame)
	--Creates new ball at the given location.
	--It also destroys the old ball
	BallService:DespawnBall()

	CurrentBall = BallClass.new(location, ReplicatedStorage.Ball, function()
		return currentGame:GetUsers()
	end)
	CurrentBall.Signals.TargetChanged:Connect(function(target)
		BallService.Client.TargetChanged:FireAll(CurrentBall.Id, target.Character)
	end)

	task.spawn(function()
		task.wait(2)
		CurrentBall:Respawn()
	end)

	return CurrentBall
end

local function CheckUsersCooldown(user)
	if not user.LastHit then
		return true
	end

	return tick() - user.LastHit >= HITCOOLDOWN
end

function BallService:HitBall(user, cameraLookVector, characterLookVector)
	--Hits ball. Based on camera & character lookVector
	if not CurrentBall then
		return
	end

	if not CheckUsersCooldown(user) then
		return false
	end

	user.LastHit = tick()

	--Hit here
	CurrentBall:Hit(user, cameraLookVector, characterLookVector)
	return true
end

function BallService:DespawnBall()
	--Despawns current bladeball
	if not CurrentBall then
		return
	end

	CurrentBall:Destroy()
	CurrentBall = nil
end

function BallService:KnitStart()
	--Loop updating ball
	RunService.Heartbeat:Connect(function(deltaTime)
		if not CurrentBall then
			return
		end
		if CurrentBall.Destroyed then
			return
		end

		CurrentBall:Update(deltaTime)
	end)
end

function BallService:KnitInit() end

return BallService

--[[
Ball
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Ball = {}
Ball.__index = Ball

local BALLHITDISTANCE = 1
local BUFFERTIME = 10 / 1000 --in seconds
local BALLRADIUS = 2

function Ball.new(spawnCFrame: CFrame, model: PVInstance, currentGame)
	local self = setmetatable({}, Ball)

	self.Janitor = janitor.new()

	self.Model = model
	self.SpawnPosition = spawnCFrame
	self.Game = currentGame

	self.Position = Vector3.new(0, 0, 0)
	self.Velocity = Vector3.new(0, 0, 0)
	self.Acceleration = Vector3.new(0, 0, 0)

	self.BufferStarted = false
	self.Target = nil
	self.Speed = 1

	self.HitBuffer = 0 --Players get .1 seconds to hit ball before killed to balance out bad internet connections and desync.

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),

		TargetChanged = self.Janitor:Add(signal.new()),
		Hit = self.Janitor:Add(signal.new()),
		HitTarget = self.Janitor:Add(signal.new()),
	}

	return self
end

function Ball:Respawn()
	--Respawns ball at spawn
	self.Position = self.SpawnPosition
	self.Velocity = Vector3.new(0, 0, 0)
	self.Acceleration = Vector3.new(0, 0, 0)

	self:RandomTarget(self.Game.Users)
end

function Ball:SetTarget(user)
	--Sets target for ball
	self.BufferStarted = false

	self.Target = user
	self.Signals.TargetChanged:Fire(user)
end

function Ball:Update(dt)
	--Updates position etc. for ball
	self.Acceleration = self:GetDirectionalVector().Unit * self.Speed
	self.Velocity += self.Acceleration * dt

	local newPosition = self.Position + self.Velocity
	self:CheckForHit(newPosition)
	self.Position = newPosition

	--Render at new position
end

local function GetPointOnLine(a, b, p)
	local heading = (b - a)
	local magnitudeMax = heading.magnitude
	heading = heading.Unit

	local lhs = p - a
	local dotP = lhs:Dot(heading)
	dotP = math.clamp(dotP, 0, magnitudeMax)
	return a + heading * dotP
end

function Ball:CheckForHit(newPosition)
	--Check if target is between new and old position.
	--If true then start buffer time.
	if self.BufferStarted then
		return
	end

	if not self.Target then
		return
	end

	local character = self.Target.Player.Character
	if not character then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end
	local pos = rootPart.CFrame.Position

	local pointOnLine = GetPointOnLine(self.Position, newPosition, pos)
	--Check distance between point and actual position

	if (pointOnLine - pos).Magnitude > BALLRADIUS then
		return
	end

	--Start buffer
	task.spawn(function()
		self.BufferStarted = true
		local target = self.Target

		task.wait(BUFFERTIME)
		if not (self.Target == target) then
			return
		end

		--Kill
		self.Game:UserHit(self.Target)
		self:Respawn()
	end)
end

function Ball:GetDirectionalVector(): Vector3
	--Gets vector facing towards target from ball
	if not self.Target then
		return math.huge
	end

	local character = self.Target.Player.Character
	if not character then
		return math.huge
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return math.huge
	end

	return (rootPart.CFrame.Position - self.Position)
end

function Ball:GetDistanceToTarget(): number
	return self:GetDirectionalVector().Magnitude
end

local function GetMixedLookVector(user, cameraLookVector: Vector3): Vector3
	local character = user.Player.Character
	if not character then
		return Vector3.new(cameraLookVector.X, 0, 0), Vector3.new()
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return Vector3.new(cameraLookVector.X, 0, 0), Vector3.new()
	end

	local characterLookVector = rootPart.CFrame.lookVector

	return Vector3.new(cameraLookVector.X, characterLookVector.Y, characterLookVector.Z), characterLookVector
end

function Ball:Hit(user, cameraLookVector)
	if not (self.Target == user) then
		return
	end

	--Check distance
	local distance = self:GetDistanceToTarget()
	if distance < BALLHITDISTANCE then
		return
	end

	--Make user hit ball
	local mixedLookVector, characterLookVector = GetMixedLookVector(user, cameraLookVector)
	self.Velocity = self:GetImpulse(mixedLookVector)

	self:GetNextTarget(self.Game.Users, characterLookVector)
end

function Ball:GetImpulse(mixedLookVector): Vector3
	--Returns impulse from the given mixedLookVector.
	--Used on hit

	--A mixed lookVector is a lookVector that has the x value of the camera and the y and z from the player. This makes it possible to shoot the ball upwards.
	local impulse = mixedLookVector.Unit * self.Speed
	return impulse
end

local function DotUser(user, lookVector, ballPosition): number
	local character = user.Player.Character
	if not character then
		return math.huge
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return math.huge
	end

	local ballToCharacter = (rootPart.CFrame.Position - ballPosition).Unit

	return ballToCharacter:Dot(lookVector)
end

function Ball:GetNextTarget(users, lookVector)
	--Gets next target.
	local highestDot, currentTarget = -math.huge, nil
	for _, user in users do
		local dot = DotUser(user, lookVector, self.Position)
		if dot > highestDot then
			highestDot = dot
			currentTarget = user
		end
	end

	if not currentTarget then
		--What? Shouldn't happen because there will always be players :/
		self:RandomTarget(users)
		return
	end

	self:SetTarget(currentTarget)
end

function Ball:RandomTarget(users)
	--Choses random target for ball
	self:SetTarget(users[math.random(1, #users)])
end

function Ball:Pause() end

function Ball:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Ball

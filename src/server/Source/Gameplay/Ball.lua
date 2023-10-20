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

local BALLHITDISTANCE = 20
local BUFFERTIME = 100 / 1000 --in seconds
local BALLRADIUS = 2

function Ball.new(spawnCFrame: CFrame, model: PVInstance, currentGame)
	local self = setmetatable({}, Ball)

	self.Janitor = janitor.new()
	self.BallJanitor = self.Janitor:Add(janitor.new())

	self.Model = model
	self.SpawnPosition = spawnCFrame
	self.Game = currentGame

	self.Position = Vector3.new(0, 0, 0)
	self.Velocity = Vector3.new(0, 0, 0)
	self.Acceleration = Vector3.new(0, 0, 0)
	self.Impulse = Vector3.new(1, 2, 0)

	self.BufferStarted = false
	self.Target = nil
	self.Speed = 1

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),

		TargetChanged = self.Janitor:Add(signal.new()),
		Hit = self.Janitor:Add(signal.new()),
		HitTarget = self.Janitor:Add(signal.new()),
	}

	return self
end

function Ball:CreateBall()
	self.BallJanitor:Cleanup()

	self.BallModel = self.BallJanitor:Add(self.Model:Clone())
	self.BallModel.Parent = workspace
end

function Ball:Respawn()
	--Respawns ball at spawn
	self.Position = self.SpawnPosition.Position
	self.Velocity = Vector3.new(0, 0, 0)
	self.Acceleration = Vector3.new(0, 0, 0)
	self.Speed = 1

	self:SetImpulse(Vector3.new(math.random(-2, 2), math.random(0, 2), math.random(-2, 2)))

	self:RandomTarget(self.Game.Users)

	self:CreateBall()
end

function Ball:SetTarget(user)
	--Sets target for ball
	self.BufferStarted = false

	self.Target = user
	self.Signals.TargetChanged:Fire(user)
end

function Ball:Update(dt)
	if not self.BallModel then
		return
	end

	--Updates position etc. for ball
	if not self.BufferStarted then
		self.Acceleration = self:GetDirectionalVector().Unit * self.Speed

		self.Velocity = self.Acceleration + self.Impulse
	end

	local newPosition = self.Position + self.Velocity
	self:CheckForHit(newPosition)

	self.Position = newPosition

	self.Impulse /= 1 + (2 * dt)

	--Render at new position
	self.BallModel.CFrame = CFrame.new(self.Position, self.Position + self.Acceleration)
end

local function GetPointOnLine(a, b, p)
	local success, msg, msg2 = pcall(function()
		local heading = (b - a)
		local magnitudeMax = heading.magnitude
		heading = heading.Unit

		if magnitudeMax ~= magnitudeMax then
			magnitudeMax = 1
		end

		local lhs = p - a
		local dotP = lhs:Dot(heading)
		dotP = math.clamp(dotP, 0, magnitudeMax)
		return a + heading * dotP, magnitudeMax
	end)

	if success then
		return msg
	end

	warn("erorr")
	return Vector3.new()
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
		return Vector3.new()
	end

	local character = self.Target.Player.Character
	if not character then
		return Vector3.new()
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return Vector3.new()
	end

	return (rootPart.CFrame.Position - self.Position)
end

function Ball:GetDistanceToTarget(): number
	return self:GetDirectionalVector().Magnitude
end

local function GetMixedLookVector(user, cameraLookVector: Vector3): Vector3
	local character = user.Player.Character
	if not character then
		return Vector3.new(0, cameraLookVector.Y, 0), Vector3.new()
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return Vector3.new(0, cameraLookVector.Y, 0), Vector3.new()
	end

	local characterLookVector = rootPart.CFrame.lookVector

	return Vector3.new(characterLookVector.X, cameraLookVector.Y, characterLookVector.Z), characterLookVector
end

function Ball:Hit(user, cameraLookVector, characterLookVector)
	if not (self.Target == user) then
		return
	end

	warn("Trying hit")

	--Check distance
	local distance = self:GetDistanceToTarget()
	if distance > BALLHITDISTANCE then
		warn(distance)
		return
	end

	--Make user hit ball
	local mixedLookVector = GetMixedLookVector(user, cameraLookVector)
	self:SetImpulse(self:GetImpulse(mixedLookVector))

	self.Speed += 0.05
	self:GetNextTarget(self.Game.Users, characterLookVector)

	warn("Successfully hit")
end

function Ball:SetImpulse(impulse)
	--Maybe have impulse boosts from a perk / weapons

	self.Impulse = impulse.Unit * Vector3.new(self.Speed * 1.25, self.Speed * 2, self.Speed * 1.25)
end

function Ball:GetImpulse(mixedLookVector): Vector3
	--Returns impulse from the given mixedLookVector.
	--Used on hit

	--A mixed lookVector is a lookVector that has the x value of the camera and the y and z from the player. This makes it possible to shoot the ball upwards.
	local impulse = mixedLookVector.Unit
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
		if user == self.Target then
			continue
		end

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
	self.Destroyed = true

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Ball

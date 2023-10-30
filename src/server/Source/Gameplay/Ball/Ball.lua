--[[
Ball
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local Ball = {}
Ball.__index = Ball

local BALLHITDISTANCE = GeneralSettings.Game.Ball.HitRadius
local BUFFERTIME = GeneralSettings.Game.Ball.BufferTime --in seconds
local BALLRADIUS = GeneralSettings.Game.Ball.KillRadius

function Ball.new(spawnCFrame: CFrame, model: PVInstance, targetCallback: () -> { any })
	local self = setmetatable({}, Ball)

	self.Janitor = janitor.new()
	self.BallJanitor = self.Janitor:Add(janitor.new())

	self.Id = HttpService:GenerateGUID(false)

	self.Model = model
	self.SpawnPosition = spawnCFrame
	self.TargetCallback = targetCallback

	self.Position = Vector3.new(0, 0, 0)
	self.Velocity = Vector3.new(0, 0, 0)
	self.Acceleration = Vector3.new(0, 0, 0)
	self.Impulse = Vector3.new(1, 2, 0)

	self.BufferStarted = false
	self.Target = nil
	self.Speed = GeneralSettings.Game.Ball.StartSpeed
	self.LastTarget = nil
	self.LastHit = 0

	self.Hits = {}
	self.Kills = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),

		TargetChanged = self.Janitor:Add(signal.new()),
		Hit = self.Janitor:Add(signal.new()),
		HitTarget = self.Janitor:Add(signal.new()),
	}

	self:CreateBall()

	return self
end

function Ball:CreateBall()
	self.BallJanitor:Cleanup()

	self.BallModel = self.BallJanitor:Add(self.Model:Clone())

	self.BallModel:SetAttribute("Id", self.Id)
	self.BallModel:AddTag("Ball")
	self.BallModel:PivotTo(self.SpawnPosition)

	self.BallModel.Parent = workspace
end

function Ball:Respawn()
	--Respawns ball at spawn
	self.Position = self.SpawnPosition.Position
	self.Velocity = Vector3.new(0, 0, 0)
	self.Acceleration = Vector3.new(0, 0, 0)
	self.Speed = GeneralSettings.Game.Ball.StartSpeed
	self.LastTarget = nil
	self.LastHit = 0

	local impulseRange = GeneralSettings.Game.Ball.ImpulseRange

	self:SetImpulse(
		Vector3.new(
			math.random(impulseRange.X.Min, impulseRange.X.Max),
			math.random(impulseRange.Y.Min, impulseRange.Y.Max),
			math.random(impulseRange.Z.Min, impulseRange.Z.Max)
		)
	)

	self:RandomTarget(self.TargetCallback())
end

function Ball:SetTarget(user)
	--Sets target for ball
	self.BufferStarted = false

	self.LastTarget = self.Target

	self.Target = user
	self.Signals.TargetChanged:Fire(user)
end

function Ball:Update(dt, accelerationSet)
	if not self.BallModel then
		return
	end

	if not self.Target then
		return
	end

	--Updates position etc. for ball
	if not self.BufferStarted and tick() - self.LastHit > 0.25 then
		self.Acceleration = self:GetDirectionalVector().Unit * self.Speed
		self.Velocity = (self.Acceleration + self.Impulse)

		self.Impulse /= 1 + (2 * dt)
	end

	if GeneralSettings.Game.Ball.Collisions then
		local t = {}

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = t
		raycastParams.CollisionGroup = GeneralSettings.Game.Ball.CollisionGroup

		local rayResult = workspace:Raycast(self.Position, self.Velocity * dt, raycastParams)

		if rayResult and rayResult.Position and rayResult.Normal then
			--Calculate collision deflect.
			self.LastHit = tick()

			local position = self.Position + self.Velocity.Unit * rayResult.Distance

			local dist = (position - self.Position).Magnitude
			local percentage = (dist / dt) / self.Speed

			local reflect = (self.Velocity.Unit - (2 * self.Velocity.Unit:Dot(rayResult.Normal) * rayResult.Normal))
			self:CheckForHit(position)

			reflect += Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)) / 10

			self.Position = position
			self.Velocity = reflect * self.Velocity.Magnitude
			self.Impulse = reflect * self.Velocity.Magnitude

			self:Update(dt * percentage)
			return
		else
			local newPosition = self.Position + self.Velocity * dt
			self:CheckForHit(newPosition)

			self.Position = newPosition
		end
	else
		local newPosition = self.Position + self.Velocity * dt
		self:CheckForHit(newPosition)

		self.Position = newPosition
	end

	self.BallModel.Mesh.Scale = Vector3.new(1, 1, 1 + math.max(self.Velocity.Magnitude / self.Speed - 1, 0))

	-- if self.Position.Y - BALLRADIUS <= 0 then
	-- 	self.Impulse += Vector3.new(0, 10, 0) * dt * self.Speed
	-- end

	--Render at new position
	self.BallModel:PivotTo(CFrame.new(self.Position, self.Position + self.Velocity * dt))
end

local function GetPointOnLine(a, b, p)
	local heading = (b - a)
	local magnitudeMax = heading.magnitude
	heading = heading.Unit

	if magnitudeMax ~= magnitudeMax then
		return nil
	end

	local lhs = p - a
	local dotP = lhs:Dot(heading)
	dotP = math.clamp(dotP, 0, magnitudeMax)
	return a + heading * dotP, magnitudeMax
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

	local character = self.Target.Character
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
	if not pointOnLine then
		return
	end

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
		self.Signals.HitTarget:Fire(self.Target)
		self:Respawn()

		if self.LastTarget then
			if not self.Kills[self.LastTarget] then
				self.Kills[self.LastTarget] = 0
			end

			self.Kills[self.LastTarget] += 1

			--Get last targets kill animation
		end
		--Play kill animation

		--Play kill sound
		local SoundService = knit.GetService("SoundService")
		SoundService:PlaySoundOnPart(ReplicatedStorage.Assets.Sounds.BallKill, self.Target.Character)
	end)
end

function Ball:GetDirectionalVector(): Vector3
	--Gets vector facing towards target from ball
	if not self.Target then
		return Vector3.new()
	end

	local character = self.Target.Character
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
	local character = user.Character
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

	self.Speed += 1
	self:GetNextTarget(self.TargetCallback(), characterLookVector)

	self.Signals.Hit:Fire(user)

	--Play hit sound
	local SoundService = knit.GetService("SoundService")
	SoundService:PlaySoundOnPart(ReplicatedStorage.Assets.Sounds.BallHit, self.BallModel)

	--Play hit animation
	local AnimationService = knit.GetService("AnimationService")
	AnimationService:PlayDeflectAnimation(user, ReplicatedStorage.Assets.Animations.DefaultDeflect)

	--Count hits by user on ball
	if not self.Hits[user] then
		self.Hits[user] = 0
	end
	self.Hits[user] += 1
end

local function DotUser(user, lookVector, ballPosition): number
	local character = user.Character
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

function Ball:SetImpulse(impulse)
	self.Impulse = impulse.Unit * Vector3.new(self.Speed * 2, self.Speed * 3, self.Speed * 2)
end

function Ball:GetImpulse(mixedLookVector): Vector3
	--Returns impulse from the given mixedLookVector.
	--Used on hit

	--A mixed lookVector is a lookVector that has the x value of the camera and the y and z from the player. This makes it possible to shoot the ball upwards.
	local impulse = mixedLookVector.Unit
	return impulse
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
	if #users <= 0 then
		return
	end

	--Choses random target for ball
	self:SetTarget(users[math.random(1, #users)])
end

function Ball:Destroy()
	self.Destroyed = true

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Ball

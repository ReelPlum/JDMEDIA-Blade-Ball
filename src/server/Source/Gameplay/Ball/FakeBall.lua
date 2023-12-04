--[[
FakeBall
2023, 11, 16
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local FakeBall = {}
FakeBall.ClassName = "FakeBall"
FakeBall.__index = FakeBall

function FakeBall.new(direction, location, speed, lifeTime, model)
	local self = setmetatable({}, FakeBall)

	self.Janitor = janitor.new()

	self.Speed = speed
	self.Direction = direction.unit * self.Speed
	self.Location = location
	self.LifeTime = lifeTime

	self.Model = model

	self.CreatedTime = tick()
	self.Id = HttpService:GenerateGUID(false)

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:CreateModel()

	return self
end

function FakeBall:CreateModel()
	--Create model for ball
	self.BallModel = self.Janitor:Add(self.Model:Clone())

	self.BallModel:PivotTo(CFrame.new(self.Location))

	self.BallModel.Parent = workspace
end

function FakeBall:Update(dt)
	--Update position of ball
	if self:CheckTime() then
		return
	end

	if not self.BallModel then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.CollisionGroup = GeneralSettings.Game.Ball.CollisionGroup

	--local rayResult = workspace:Spherecast(self.Position, BALLRADIUS, self.Velocity * dt, raycastParams)
	local rayResult = workspace:Raycast(self.Location, self.Direction * dt, raycastParams)

	if rayResult and rayResult.Position and rayResult.Normal then
		--Calculate collision deflect.
		self.LastHit = tick()

		task.spawn(function()
			local dust = self.Janitor:Add(ReplicatedStorage.Assets.VFX.Dust:Clone())
			dust.Parent = workspace
			dust.Position = rayResult.Position

			task.wait()
			dust.Effect:Emit(15)
			local sound = self.Janitor:Add(ReplicatedStorage.Assets.Sounds.BallGroundHit:Clone())
			sound.Parent = dust
			sound:Play()

			Debris:AddItem(dust, dust.Effect.Lifetime.Max + 1)
		end)

		local position = self.Location + self.Direction.Unit * rayResult.Distance

		local dist = (position - self.Location).Magnitude
		local percentage = (dist / dt) / self.Speed

		local reflect = (self.Direction.Unit - (2 * self.Direction.Unit:Dot(rayResult.Normal) * rayResult.Normal))

		reflect += Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)) / 10

		self.Location = position
		self.Direction = reflect * self.Direction.Magnitude

		self:Update(dt * percentage)
		return
	else
		local newPosition = self.Location + self.Direction * dt

		self.Location = newPosition
	end

	self.BallModel.Mesh.Scale = Vector3.new(1, 1, 1 + math.max(self.Direction.Magnitude / self.Speed - 1, 0))
	self.BallModel:PivotTo(CFrame.new(self.Location, self.Location + self.Direction * dt))
end

function FakeBall:CheckTime()
	--Check for lifetime of ball
	if tick() - self.CreatedTime > self.LifeTime then
		local BallService = knit.GetService("BallService")
		BallService:DespawnBall(self.Id)
		return true
	end
end

function FakeBall:Destroy()
	--Unregister ball
	task.spawn(function()
		self.BallModel.Parent = ReplicatedStorage

		task.wait(3)

		self.Signals.Destroying:Fire()
		self.Janitor:Destroy()
		self = nil
	end)
end

return FakeBall

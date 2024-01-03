--[[
WorldUnboxablesService
2023, 12, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local WorldUnboxablesService = knit.CreateService({
	Name = "WorldUnboxablesService",
	Client = {
		SpawnUnboxable = knit.CreateSignal(),
	},
	Signals = {},
})

local unboxables = {}
local toCreate = {}

function WorldUnboxablesService:Unbox(user, unboxable, unboxed, strange)
	--Create a unboxable and choose a location
	local origin = user.Player.Character.HumanoidRootPart.CFrame.Position
	local location = (CFrame.new(origin) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0) * CFrame.new(
		0,
		0,
		-math.random(500, 1000) / 100
	)).Position

	table.insert(toCreate, {
		Unboxable = unboxable,
		Unboxed = unboxed,
		Strange = strange,
		User = user,
		Location = location,
		Origin = origin,
	})
end

function WorldUnboxablesService:KnitStart()
	RunService.Heartbeat:Connect(function(deltaTime)
		for i, data in toCreate do
			while true do
				local sum = Vector3.new()
				local n = 0

				for _, pos in unboxables do
					local d = (data.Location - pos).Magnitude
					if d > 15 then
						continue
					end

					n += 1
					sum += (data.Location - pos)
				end
				if n >= 1 then
					data.Location = data.Location + (sum / n).Unit * 5
				else
					break
				end
			end

			local id = HttpService:GenerateGUID(false)

			unboxables[id] = data.Location

			WorldUnboxablesService.Client.SpawnUnboxable:FireAll(
				data.User.Player,
				data.Origin,
				Vector3.new(data.Location.X, data.Origin.Y, data.Location.Z),
				data.Unboxable,
				data.Unboxed,
				data.Strange
			)

			task.spawn(function()
				task.wait(5)
				unboxables[id] = nil
			end)
			toCreate[i] = nil
		end
	end)
end

function WorldUnboxablesService:KnitInit() end

return WorldUnboxablesService

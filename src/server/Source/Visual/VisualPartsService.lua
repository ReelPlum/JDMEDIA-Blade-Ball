--[[
VisualPartsService
2023, 10, 31
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Debris = game:GetService("Debris")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local VisualPartsService = knit.CreateService({
	Name = "VisualPartsService",
	Client = {},
	Signals = {},
})

function VisualPartsService:SetFloorDecal(location, texture, size: Vector2, lifetime)
	--Creates floor decal at location
	local j = janitor.new()

	--Get floor normal
	local params = RaycastParams.new()
	params.CollisionGroup = "BallGround"

	local ray = workspace:Raycast(location, Vector3.new(0, -1, 0) * 100, params)
	if not ray then
		return
	end
	if not ray.Position then
		return
	end

	local part = j:Add(Instance.new("Part"))
	part.Size = Vector3.new(size.X, 0.1, size.Y)
	part.Transparency = 1

	local decal = j:Add(Instance.new("Decal"))
	decal.Parent = part
	decal.Face = Enum.NormalId.Top
	decal.Texture = texture

	part.CFrame = CFrame.new(ray.Position, ray.Position + ray.Normal) * CFrame.new(0, math.rad(90), 0)

	Debris:AddItem(part, lifetime)
end

function VisualPartsService:CreateCrack(location, material, length, direction, t)
	--Creates crack starting at location going in direction
end

function VisualPartsService:CreateCrater(location, material, radius, t)
	--Creates crater at location with radius
end

function VisualPartsService:AddSplatter(location, normal, texture, size)
	local j = janitor.new()

	local part = j:Add(Instance.new("Part"))
	part.Size = Vector3.new(size.X, size.Y, 0.01)
	part.CanCollide = false
	part.Anchored = true
	part.Parent = workspace
	part.Transparency = 1
	local decal = j:Add(Instance.new("Decal"))
	decal.Parent = part
	decal.Texture = texture
	decal.Face = "Front"

	part.CFrame = CFrame.new(location, location + normal)

	return j
end

function VisualPartsService:KnitStart() end

function VisualPartsService:KnitInit() end

return VisualPartsService

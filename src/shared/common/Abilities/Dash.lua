--[[
Dash
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local janitor = require(ReplicatedStorage.Packages.Janitor)
local knit = require(ReplicatedStorage.Packages.Knit)

local force = 2500

return {
	DisplayName = "Dash",

	CooldownTime = 5,

	Levels = {
		[1] = {
			Force = 2500,
		},
	},

	ExecuteClient = function()
		local j = janitor.new()
		local LocalPlayer = Players.LocalPlayer

		local character = LocalPlayer.Character
		if not character then
			return
		end

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then
			return
		end

		local moveDirection = humanoid.MoveDirection

		local track

		local relMoveDirection = rootPart.CFrame:PointToObjectSpace(rootPart.CFrame.Position + moveDirection.Unit)

		if moveDirection.Magnitude <= 0 then
			--Forward
			moveDirection = rootPart.CFrame.lookVector
			track = humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Dash.DashFront)

			warn("STill")
		else
			if math.abs(relMoveDirection.X) > math.abs(relMoveDirection.Z) then
				--Left or right
				if relMoveDirection.X < 0 then
					--Left
					track = humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Dash.DashLeft)
				else
					--Right
					track = humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Dash.DashRight)
				end
			else
				if relMoveDirection.Z > 0 then
					--Back
					track = humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Dash.DashBack)
				else
					--Front
					track = humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Dash.DashFront)
				end
			end
		end

		if not track then
			return
		end
		j:Add(track)
		track:Play()

		local attachment = j:Add(Instance.new("Attachment"))
		attachment.Parent = rootPart

		local m = rootPart.AssemblyMass

		local ClientPhysicsService = knit.GetService("ClientPhysicsService")

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { character }

		local ray = workspace:Raycast(
			(rootPart.CFrame * CFrame.new(0, -rootPart.Size.Y / 2, 0)).Position,
			Vector3.new(0, -1, 0) * (humanoid.HipHeight + 0.1),
			params
		)

		--Check if grounded.
		local f = force
		if not ray then
			--Not grounded
			warn("Ungrounded")
			f = force * 0.75
		end

		--Check if character is in the air. If they are in the air then apply a smaller force, and play another animation
		local ClientPhysicsController = knit.GetController("ClientPhysicsController")

		ClientPhysicsController:ApplyImpulseOnCharacter(moveDirection.Unit * Vector3.new(f, 0, f))

		task.spawn(function()
			task.wait(0.25)
			track:Stop()
			--humanoid.PlatformStand = false
			j:Destroy()
		end)
	end,
	ExecuteServer = function(user, cameraLookVector, characterLookVector)
		--Use dash

		return true
	end,
}

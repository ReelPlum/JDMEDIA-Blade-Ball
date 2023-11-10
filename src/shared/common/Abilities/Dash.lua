--[[
Dash
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local janitor = require(ReplicatedStorage.Packages.Janitor)
local knit = require(ReplicatedStorage.Packages.Knit)

local force = 2500

return {
	DisplayName = "Dash",

	Execute = function(user, cameraLookVector, characterLookVector)
		--Use dash
		local j = janitor.new()
		local character = user.Character
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
		if moveDirection.Magnitude <= 0 then
			return
		end

		local track

		local relMoveDirection = rootPart.CFrame:PointToObjectSpace(rootPart.CFrame.Position + moveDirection.Unit)

		if math.abs(relMoveDirection.X) > math.abs(relMoveDirection.Z) then
			--Left or right
			if relMoveDirection.X < 0 then
				--Left
				print("Left")
				track = humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Dash.DashLeft)
			else
				--Right
				print("Right")
				track = humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Dash.DashRight)
			end
		else
			if relMoveDirection.Z > 0 then
				--Back
				print("Back")
				track = humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Dash.DashBack)
			else
				--Front
				print("Front")
				track = humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Dash.DashFront)
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

		-- local vectorForce = j:Add(Instance.new("VectorForce"))
		-- vectorForce.Parent = rootPart
		-- vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
		-- vectorForce.Attachment0 = attachment
		-- vectorForce.Force = moveDirection.Unit * Vector3.new(force, 0, force)

		--humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		--humanoid.PlatformStand = true
		--local force = m * 25

		local ClientPhysicsService = knit.GetService("ClientPhysicsService")
		ClientPhysicsService:ApplyImpulseOnCharacter(user, moveDirection.Unit * Vector3.new(force, 0, force))

		task.spawn(function()
			task.wait(0.25)
			track:Stop()
			--humanoid.PlatformStand = false
			j:Destroy()
		end)

		return true
	end,
}

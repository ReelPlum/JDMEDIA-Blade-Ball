--[[
Hit
2023, 10, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local janitor = require(ReplicatedStorage.Packages.Janitor)
local knit = require(ReplicatedStorage.Packages.Knit)

return function(user)
	--Play hit animation on character
	local animation = ReplicatedStorage.Assets.Animations.DefaultDeflect

	local track = user.Player.Character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(animation)

	local j = janitor.new()

	local holsteredKnife = user.Player.Character:FindFirstChild("EquippedKnife")
	if not holsteredKnife then
		track:Play()

		user.ExtendedCharacter:EquipKnife()
		warn("trying to equip knife again..")

		return
	end

	track:GetMarkerReachedSignal("Equip"):Connect(function()
		warn("Equip")
		if not user.Player.Character then
			warn("No character")
			return
		end

		--
		local EquipmentService = knit.GetService("EquipmentService")
		local knife = EquipmentService:GetEquippedItemOfType(user, "Knife")

		local ItemService = knit.GetService("ItemService")
		local data = ItemService:GetItemData(knife)
		warn(knife)
		if not data then
			warn("No data")
			return
		end

		local EquippedKnifeModel = data.Model

		if not EquippedKnifeModel then
			warn(knife .. " did not have a model")
			return
		end

		holsteredKnife.Parent = ReplicatedStorage
		local BodyService = knit.GetService("BodyService")
		local jan, knf = BodyService:EquipOnBodyPart(
			user.Player.Character,
			"RightHand",
			EquippedKnifeModel,
			EquippedKnifeModel.HandleOffset.Value,
			"HittingKnife"
		)
		j:Add(jan)

		print("Hit")
		for _, i in knf:GetDescendants() do
			if i:IsA("Trail") then
				print("Enabled")
				i.Enabled = true
			end
		end
	end)

	track:GetMarkerReachedSignal("Swing"):Connect(function()
		--Start swing effects on knife
	end)

	track:GetMarkerReachedSignal("SwingEnded"):Connect(function()
		--Stop swing effects on knife
	end)

	track:GetMarkerReachedSignal("Holster"):Connect(function()
		--Holster knife back in place
		holsteredKnife.Parent = user.Player.Character
		j:Cleanup()
	end)

	track.Stopped:Connect(function()
		--Stopped for some reason?
		holsteredKnife.Parent = user.Player.Character
		j:Cleanup()

		track:Destroy()
	end)

	track.Ended:Connect(function()
		--Finished.
		holsteredKnife.Parent = user.Player.Character
		j:Cleanup()

		track:Destroy()
	end)

	track:Play()
end

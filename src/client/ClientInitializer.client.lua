--[[
ClientInitializer.client
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Source = script.Parent:WaitForChild("Source")

local Knit = require(ReplicatedStorage.Packages.Knit)
local start = tick()

--Add services
for _, v in pairs(Source:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:match("Controller$") then
		require(v)
	end
end

--Add components
for _, v in pairs(Source:GetDescendants()) do
	if v:IsA("Folder") and v.Name == "Components" then
		for _, c in pairs(v:GetChildren()) do
			require(c)
		end
	end
end

--Start knit on the server.
Knit.Start():andThen(function()
  local t = tick() - start

	print("Client started ✅")
  print(string.format("🌟 Client initialization took %.2f second(s)! 🌟", t))
end):catch(warn)
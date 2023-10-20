--[[
ServerInitializer.server
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(
	assert(
		ReplicatedStorage:FindFirstChild("Packages"):FindFirstChild("Knit"),
		"Could not find knit. Please insert into ReplicatedStorage using toolbox"
	)
)
local start = tick()

--Add services
for _, v in pairs(script.Parent.Source:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:match("Service$") then
		require(v)
	end
end

--Add components
for _, v in pairs(script.Parent.Source:GetDescendants()) do
	if v:IsA("Folder") and v.Name == "Components" then
		for _, c in pairs(v:GetChildren()) do
			require(c)
		end
	end
end

--Start knit on the server.
local Rates = {}
local limit = 1 / 10

local function RateLimit(player: Player)
	local rate = Rates[player]
	Rates[player] = tick()

	if not rate then
		return true
	end

	if tick() - rate < limit then
		--Rate limit player
		return false
	end
	return true
end

Knit.Start({
	Inbound = { RateLimit },
})
	:andThen(function()
		local t = tick() - start

		print("Server started ✅")
		print(string.format("🌟 Server initialization took %.2f second(s)! 🌟", t))
	end)
	:catch(warn)

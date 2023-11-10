--[[
Before
2023, 11, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Groups = {}
for _, v in ReplicatedStorage.Common.AdminGroups:GetChildren() do
	Groups[v.Name] = require(v)
end

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		if Groups[context.Group] then
			return Groups[context.Group](context)
		end
	end)
end

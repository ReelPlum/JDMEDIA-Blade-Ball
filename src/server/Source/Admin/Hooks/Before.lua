--[[
Before
2023, 11, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local Groups = {}
for _, v in script.Parent:GetChildren() do
	Groups[v.Name] = require(v)
end

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		if Groups[context.Group] then
			return Groups[context.Group](context)
		end
	end)
end

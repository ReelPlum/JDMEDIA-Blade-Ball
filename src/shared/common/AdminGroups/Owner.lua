--[[
Owners
2023, 11, 10
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]
local Owners = {
	60083248,
	-1,
	-2,
	4242824,
	1823037,
}

return function(context)
	if not table.find(Owners, context.Executor.UserId) then
		return "You do not have permission to run this command!"
	end
end

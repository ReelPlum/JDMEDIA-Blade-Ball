--[[
SortUniqueness
2023, 12, 15
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local Rankings = { --Higher is better
	[MetadataTypes.Types.Strange] = 10,
	[MetadataTypes.Types.StrangeParts] = 10,
	[MetadataTypes.Types.Untradeable] = -1,
}

return function(data, container)
	if not data.Metadata then
		return 1
	end

	local n = 0
	for index, _ in data.Metadata do
		if not Rankings[index] then
			continue
		end

		n -= Rankings[index]
	end

	return n
end

--[[
TimeFormat
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local module = {}

function module.FormatSeconds(s)
	-- local Minutes = (seconds - seconds % 60) / 60
	-- seconds = seconds - Minutes * 60
	-- local Hours = (Minutes - Minutes % 60) / 60
	-- Minutes = Minutes - Hours * 60
	-- return Format(Hours) .. ":" .. Format(Minutes) .. ":" .. Format(seconds)

	local min = (s - s % 60) / 60
	s = s - min * 60
	local h = (min - min % 60) / 60
	min = min - h * 60
	local d = (h - h % 24) / 24
	h = h - d * 24

	s = tostring(math.floor(s))
	min = tostring(math.floor(min))
	h = tostring(math.floor(h))
	d = tostring(math.floor(d))

	print(s)
	print(min)
	print(h)
	print(d)

	if #s < 2 then
		s = "0" .. s
	end
	if #min < 2 then
		min = "0" .. min
	end
	if #h < 2 then
		h = "0" .. h
	end
	if #d < 2 then
		d = "0" .. d
	end

	return `{d}:{h}:{min}:{s}`
end

return module

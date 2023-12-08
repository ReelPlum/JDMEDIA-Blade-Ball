--[[
DataCompressionService
2023, 11, 06
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local StringCompress = require(ReplicatedStorage.Common.StringCompress)
local Binary = require(ReplicatedStorage.Common.Binary)

local DataCompressionService = knit.CreateService({
	Name = "DataCompressionService",
	Client = {},
	Signals = {},
})

function DataCompressionService:DecompressData(data)
	--Decompress data
	--local compressed = Binary.BinaryToString(data)
	local decompressed
	if data.Method == "waffleLZW" then
		decompressed = StringCompress.Decompress(HttpService:JSONEncode(data.Data))
	elseif data.Method == "None" then
		decompressed = data.Data
	end

	return decompressed
end

function DataCompressionService:CompressData(data)
	--Compress data
	-- local compressed = StringCompress.Compress(data)

	-- return { Data = compressed, Method = "waffleLZW" }

	return { Data = data, Method = "None" }

	--return Binary.StringToBinary(compressed)
end

function DataCompressionService:KnitStart() end

function DataCompressionService:KnitInit() end

return DataCompressionService

--[[
CodeService
2024, 01, 12
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local codeData = ReplicatedStorage.Data.Codes

local CodeService = knit.CreateService({
	Name = "CodeService",
	Client = {
		UserRedeemedCode = knit.CreateSignal(),
	},
	Signals = {},
})

function CodeService.Client:RedeemCode(player, code)
	if not typeof(code) == "string" then
		return
	end

	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	CodeService:RedeemCode(user, code)
end

function CodeService:GetCode(code)
	--Return code data
	if not code then
		return
	end

	local data = codeData:FindFirstChild(code)
	if not data then
		return
	end

	if not data:IsA("ModuleScript") then
		return
	end

	return require(data)
end

function CodeService:HasUserRedeemedCode(user, code)
	--Check if user has redeemed code
	user:WaitForDataLoaded()

	if user.RedeemedCodes[string.lower(code)] then
		return true
	end

	return false
end

function CodeService:RedeemCode(user, code)
	--Check if code exists
	local data = CodeService:GetCode(code)
	if not data then
		return
	end

	code = string.lower(code)

	--Check if user has redeemed code
	if CodeService:HasUserRedeemedCode(user, code) then
		return
	end

	--Give rewards for code
	local ItemService = knit.GetService("ItemService")
	local CurrencyService = knit.GetService("CurrencyService")

	for i, reward in data.Rewards do
		if reward.Type == "Item" then
			--Give item
			ItemService:GiveUserItem(user, reward.Item.Item, reward.Quantity, reward.Item.Metadata)
		elseif reward.Type == "Currency" then
			--Give currency
			CurrencyService:GiveCurrency(user, reward.Currency, reward.Amount)
		else
			warn("❗Could not give reward " .. i .. " for code " .. code)
		end
	end

	--Save reedemed
	user.RedeemedCodes[string.lower(code)] = DateTime.now().UnixTimestamp
end

function CodeService:KnitStart() end

function CodeService:KnitInit() end

return CodeService

--[[
ProfileStoreTemplate
2023, 04, 16
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	JoinDate = DateTime.now().UnixTimestamp,
	FirstJoin = true,

	Subscriptions = {}, --Users active subscriptions for their last play session.
	PurchaseHistory = {}, --All developer product purchases made by user

	RankItems = {},
	State = {},

	ItemsInInventory = 0,
	Currencies = {}, --Users currencies
	Stats = {}, --Users stats
	Inventory = nil, --Users inventory with all their items
	Equipped = {}, --Users equipped items
	Achievements = {
		Progress = {},
		Completed = {},
	},
	ItemIndex = {},
	TemporaryItems = {},

	RandomEnchant = nil,
	LeaderboardRewards = {},
	RedeemedCodes = {},

	Moderation = {
		CurrentBan = nil,
		--[[
		CurrentBan = {
			Reason: string,
			Time: unix timestamp,
			Moderator: userid
		}
		]]
	},
}

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

	Currencies = {}, --Users currencies
	Stats = {}, --Users stats
	Inventory = nil, --Users inventory with all their items
	Equipped = {}, --Users equipped items

	RandomEnchant = nil,
	LeaderboardRewards = {},

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

--[[
LeaderboardsData
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	["DailyWins"] = {
		Type = "Daily", --"AllTime", "Monthly", "Weekly", "Daily", "ServerOnly"
		Tag = "DailyWinsLeaderboard",
		Stat = "Wins",

		Header = "Most wins today",
	},

	["Wins"] = {
		Type = "AllTime", --"AllTime", "Monthly", "Weekly", "Daily", "ServerOnly"
		Tag = "AllTimeWinsLeaderboard",
		Stat = "Wins",

		Header = "All time wins",
	},

	["LocalWins"] = {
		Type = "ServerOnly", --"AllTime", "Monthly", "Weekly", "Daily", "ServerOnly"
		Tag = "ServerWinsLeaderboard",
		Stat = "Wins",

		Header = "Wins in server",
	},

	["MonthlyWins"] = {
		Type = "Monthly", --"AllTime", "Monthly", "Weekly", "Daily", "ServerOnly"
		Tag = "MonthlyWinsLeaderboard",
		Stat = "Wins",

		Header = "Most wins this month",
	},

	["WeeklyWins"] = {
		Type = "Weekly", --"AllTime", "Monthly", "Weekly", "Daily", "ServerOnly"
		Tag = "WeeklyWinsLeaderboard",
		Stat = "Wins",

		Header = "Most wins this week",
	},
}

--[[
ShutdownService
2023, 09, 19
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ShutdownService = knit.CreateService({
	Name = "ShutdownService",
	Client = {
		Rebooting = knit.CreateProperty(false),
	},
	Signals = {},
})

function ShutdownService:KnitStart()
	task.spawn(function()
		if game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0 then
			--Reserved server
			ShutdownService.Client.Rebooting:Set(true)

			task.wait(2)

			--Move players back to main game
			local waitTime = 5

			Players.PlayerAdded:Connect(function(player)
				TeleportService:Teleport(game.PlaceId, player)

				task.wait(waitTime)
				waitTime = waitTime / 2
			end)

			for _, player in Players:GetPlayers() do
				TeleportService:Teleport(game.PlaceId, player)

				task.wait(waitTime)
				waitTime = waitTime / 2
			end
		else
			game:BindToClose(function()
				--Server is closing. Move every player to reserved server
				if #Players:GetPlayers() <= 0 then
					return
				end

				if RunService:IsStudio() then
					return
				end

				--Tell clients server is rebooting. They should show some kind nice looking UI :)
				ShutdownService.Client.Rebooting:Set(true)

				task.wait(2)

				--Move to reserved server
				local reservedServerCode = TeleportService:ReserveServer(game.PlaceId)

				TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, Players:GetPlayers())

				Players.PlayerAdded:Connect(function(player)
					--Move to reserved server
					TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, { player })
				end)

				while #Players:GetPlayers() > 0 do
					task.wait(1)
				end
			end)
		end
	end)
end

function ShutdownService:KnitInit() end

return ShutdownService

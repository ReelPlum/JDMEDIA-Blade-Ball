--[[
SoftShutdown
2023, 09, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local SoftShutdown = {}
SoftShutdown.__index = SoftShutdown

function SoftShutdown.new(UI)
	local self = setmetatable({}, SoftShutdown)

	self.Janitor = janitor.new()

	self.UI = UI
	self.Visible = false

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:SetVisible(false)

	local CacheController = knit.GetController("CacheController")
	self.Janitor:Add(CacheController.Signals.Rebooting:Connect(function(value)
		if value then
			self:SetVisible(true)
			return
		end
		self:SetVisible(false)
	end))
	if CacheController.Cache.Rebooting then
		self:SetVisible(true)
	end

	return self
end

function SoftShutdown:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Enabled = bool
end

function SoftShutdown:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return SoftShutdown

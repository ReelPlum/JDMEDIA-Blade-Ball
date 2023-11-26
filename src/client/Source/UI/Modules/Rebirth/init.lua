--[[
Rebirth
24, 11, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]


local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Rebirth = {}
Rebirth.ClassName = 'Rebirth'
Rebirth.__index = Rebirth

function Rebirth.new(uiTemplate)
    local self = setmetatable({}, Rebirth)
    
    self.Janitor = janitor.new()
    
    self.UITemplate = uiTemplate

    self.Signals = {
        Destroying = self.Janitor:Add(signal.new()),
    }
    
    
    return self
end

function Rebirth:Init()
    self.UI = self.Janitor:Add(self.UITemplate:Clone())
    self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

    --Update UI to check if rankup is available

    --Buttons
    self.Janitor:Add(self.UI.Main.Frame.RankupButton.MouseButton1Click:Connect(function()
        --Rebirth
        local RebirthService = knit.GetService("RebirthService")
        RebirthService:Rebirth()
    end))

    self.Janitor:Add(self.UI.OnRebirth.Frame.Accept.MouseButton1Click:Connect(function()
        --Go through rewards

        --Confirm all cases and open them
    end))

    --On rebirth.
    local RebirthService = knit.GetService("RebirthService")
    self.Janitor:Add(RebirthService.OnRebirth:Connect(function(level)
        --User rebirthed
        --Show Rebirth rewards UI


        --Confetti
    end))
end

function Rebirth:Destroy()
    self.Signals.Destroying:Fire()
    self.Janitor:Destroy()
    self = nil
end

return Rebirth
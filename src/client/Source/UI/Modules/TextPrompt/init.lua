--[[
init
05, 01, 2024
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local TextPrompt = {}
TextPrompt.ClassName = 'TextPrompt'
TextPrompt.__index = TextPrompt

function TextPrompt.new(parent, template)
    local self = setmetatable({}, TextPrompt)
    
    self.Janitor = janitor.new()
    
    self.Template = template
    self.Parent = parent

    self.MaxInputLength = 100
    self.OnComplete = nil

    self.Signals = {
        Destroying = self.Janitor:Add(signal.new()),
    }
    
    self:Init()

    return self
end

function TextPrompt:Init()
    --Create UI


    --Buttons
    self.Janitor:Add(self.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
        self.InputBox.Text = string.sub(self.InputBox.Text, 1, self.MaxInputLength)
    end))

    self.Janitor:Add(self.CompleteButton.MouseButton1Click:Connect(function()
        if not self.OnComplete(self.InputBox.Text) then
            return
        end

        if self.ReturnUI then
            self.ReturnUI:SetVisible(true)
        end
        self:SetVisible(false)
    end))

    self.Janitor:Add(self.CancelButton.MouseButton1Click:Connect(function()
        if self.ReturnUI then
            self.ReturnUI:SetVisible(true)
        end
        self:SetVisible(false)
    end))

end

function TextPrompt:AskInput(maxInputLength, onComplete)
    --
    self.MaxInputLength = maxInputLength
    self.OnComplete = onComplete
end

function TextPrompt:SetVisible(bool, returnUI)
    if bool == nil then
        bool = not self.Visible
    end

    self.ReturnUI = returnUI

    self.Visible = bool
    self.UI.Visible = bool
end

function TextPrompt:Destroy()
    self.Signals.Destroying:Fire()
    self.Janitor:Destroy()
    self = nil
end

return TextPrompt
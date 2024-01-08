--[[
CharacterController
07, 01, 2024
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local CharacterController = knit.CreateController({
    Name = 'CharacterController',
    Signals = {},
})

function CharacterController:ShareLookAt()
    --Share lookat data
    local character = LocalPlayer.Character
    if not character then
        return
    end
    local rootpart = character:WaitForChild("HumanoidRootPart")

    local lookat = (Camera.CFrame * CFrame.new(0, 0, -5)).Position - Camera.CFrame.Position
    local lookatCheck = rootpart.CFrame:PointToObjectSpace(rootpart.CFrame.Position + lookat)
    lookatCheck = Vector3.new(lookatCheck.X, lookatCheck.Y, math.min(lookatCheck.Z, 0))

    if character:FindFirstChild("IKTarget") then
        character:FindFirstChild("IKTarget").CFrame = rootpart.CFrame * CFrame.new(lookatCheck)
    end

    local CharacterService = knit.GetService("CharacterService")
    CharacterService.ShareLookAt:Fire(lookatCheck)
end

local function HandleCharacter(character)
    if not character then
        return
    end

    local ik = Instance.new("IKControl")
    local target = Instance.new("Part")
    target.CanCollide = false
    target.Anchored = true
    target.Transparency = 1
    target.Name = "IKTarget"
    target.Parent = character

    ik.Parent = character
    ik.ChainRoot = character:WaitForChild("UpperTorso")
    ik.EndEffector = character:WaitForChild("UpperTorso")
    ik.Target = target
    ik.Type = Enum.IKControlType.LookAt
    ik.SmoothTime = 0
end

function CharacterController:ListenToPlayer(player)
    HandleCharacter(player.Character)

    player.CharacterAdded:Connect(HandleCharacter)
end

function CharacterController:KnitStart()
    Players.PlayerAdded:Connect(function(player)
        CharacterController:ListenToPlayer(player)
    end)
    for _, player in Players:GetPlayers() do
        CharacterController:ListenToPlayer(player)
    end

    RunService.RenderStepped:Connect(function(deltaTime)
        CharacterController:ShareLookAt()
    end)

    local CharacterService = knit.GetService("CharacterService")
    CharacterService.ShareLookAt:Connect(function(player, vector)
        if player == LocalPlayer then
            return
        end

        if player.Character then
            if player.Character:FindFirstChild("IKTarget") then
                player.Character:FindFirstChild("IKTarget").CFrame = player.Character:WaitForChild("HumanoidRootPart").CFrame * CFrame.new(vector)
            end
        end
    end)
end

function CharacterController:KnitInit()
    
end

return CharacterController
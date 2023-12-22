--[[
Item.story
2023, 12, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local Item = ReplicatedStorage.Assets.UI.Item
local ItemClass = require(StarterPlayerScripts.Client.Source.UI.Modules.Common.Item)

return function(target)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 1, 0)
	holder.BackgroundTransparency = 1

	--Create item
	local itm = ItemClass.new(Item, holder, true)
	itm:UpdateWithItemData(require(ReplicatedStorage.Data.Items.TestItem))
	itm:SetEnabled(true)
	itm.OnClick = function()
		itm:SetEquipped()
	end

	local button = Instance.new("TextButton")
	button.BackgroundTransparency = 0
	button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	button.TextColor3 = Color3.fromRGB(0, 0, 0)
	button.TextScaled = true
	button.Size = UDim2.new(0, 100, 0, 50)
	button.MouseButton1Click:Connect(function()
		itm:SetEnabled()
	end)

	local stack = 1
	itm:UpdateStack(stack)
	button.MouseButton2Click:Connect(function()
		stack += 1
		itm:UpdateStack(stack)
	end)

	button.Position = UDim2.new(1, -10, 0, 10)
	button.AnchorPoint = Vector2.new(1, 0)
	button.Parent = holder

	holder.Parent = target

	return function()
		holder:Destroy()
		itm:Destroy()
	end
end

--[[
Types
2023, 11, 14
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local TextService = game:GetService("TextService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")

local knit = require(ReplicatedStorage.Packages.Knit)
local FormatNumber = require(ReplicatedStorage.Packages.FormatNumber)
local ViewportFrameModel = require(ReplicatedStorage.Common.ViewportFrameModel)

local abbreviations = FormatNumber.Main.Notation.compactWithSuffixThousands({
	"K",
	"M",
	"B",
	"T",
})
local formatter = FormatNumber.Main.NumberFormatter.with():Notation(abbreviations)
-- Round to whichever results in longest out of integer and 3 significant digits.
-- 1.23K  12.3K  123K
-- If you prefer rounding to certain decimal places change it to something like Precision.maxFraction(1) to round it to 1 decimal place

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)
local EnchantsData = require(ReplicatedStorage.Data.EnchantsData)
local IntToRomanNumerals = require(ReplicatedStorage.Common.IntToRomanNumerals)

local MAXWIDTH = 1000

return {
	["Header"] = function(ToolTip, data, priority)
		--Return a text label
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Text = data.Text
		label.TextSize = 20
		label.LayoutOrder = priority
		label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)

		local params = Instance.new("GetTextBoundsParams")
		params.Text = label.Text
		params.Font = label.FontFace
		params.Size = 20
		params.Width = MAXWIDTH

		local size = TextService:GetTextBoundsAsync(params)
		--local size = TextService:GetTextSize(data.Text, 20, Enum.Font.SourceSans, Vector2.new(100, 1000))
		label.Size = UDim2.new(0, size.X + 10, 0, size.Y + 10)

		params:Destroy()
		return label
	end,

	["Rarity"] = function(ToolTip, data, priority)
		--Return a text label
		local label = Instance.new("TextLabel")
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Text = data.Data.DisplayName
		label.TextSize = 14
		label.LayoutOrder = priority
		label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
		label.TextColor3 = Color3.fromRGB(228, 228, 228)
		data.Data.Effect(data.Data, label)

		local UICorner = Instance.new("UICorner")
		UICorner.CornerRadius = UDim.new(1, 0)
		UICorner.Parent = label

		local params = Instance.new("GetTextBoundsParams")
		params.Text = label.Text
		params.Font = label.FontFace
		params.Size = 14
		params.Width = MAXWIDTH

		local size = TextService:GetTextBoundsAsync(params)
		--local size = TextService:GetTextSize(data.Text, 20, Enum.Font.SourceSans, Vector2.new(100, 1000))
		label.Size = UDim2.new(0, size.X + 10, 0, size.Y + 10)

		params:Destroy()
		return label
	end,

	["Copies"] = function(ToolTip, data, priority)
		--Return a text label
		local label = Instance.new("TextLabel")
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Text = `{formatter:Format(data.Copies or 0)} exists`
		label.TextSize = 14
		label.LayoutOrder = priority
		label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
		label.TextColor3 = Color3.fromRGB(39, 39, 39)
		label.BackgroundTransparency = 1

		local params = Instance.new("GetTextBoundsParams")
		params.Text = label.Text
		params.Font = label.FontFace
		params.Size = 14
		params.Width = MAXWIDTH

		local size = TextService:GetTextBoundsAsync(params)
		--local size = TextService:GetTextSize(data.Text, 20, Enum.Font.SourceSans, Vector2.new(100, 1000))
		label.Size = UDim2.new(0, size.X, 0, size.Y)

		params:Destroy()
		return label
	end,

	[MetadataTypes.Types.Untradeable] = function(ToolTip, data, priority)
		--Return a text label
		local label = Instance.new("TextLabel")
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Text = " UNTRADEABLE"
		label.BackgroundTransparency = 1
		label.TextSize = 10
		label.LayoutOrder = priority
		label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
		label.TextColor3 = Color3.fromRGB(128, 128, 128)

		local params = Instance.new("GetTextBoundsParams")
		params.Text = label.Text
		params.Font = label.FontFace
		params.Size = 10
		params.Width = MAXWIDTH

		local size = TextService:GetTextBoundsAsync(params)
		--local size = TextService:GetTextSize(data.Text, 20, Enum.Font.SourceSans, Vector2.new(100, 1000))
		label.Size = UDim2.new(0, size.X, 0, size.Y)

		params:Destroy()
		return label
	end,

	[MetadataTypes.Types.Enchant] = function(ToolTip, data, priority)
		--Return a text label
		if not data.Data then
			return
		end
		local enchant = EnchantsData[data.Data[1]]
		if not enchant then
			return
		end

		local label = Instance.new("TextLabel")
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.RichText = true
		label.Text =
			`{string.upper(enchant.DisplayName)} <i><font face="Antique">{IntToRomanNumerals(data.Data[2])}</font></i>`
		label.TextSize = 14
		label.LayoutOrder = priority
		label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
		label.TextColor3 = Color3.fromRGB(228, 228, 228)
		label.BackgroundColor3 = Color3.fromRGB(146, 12, 135)

		local UICorner = Instance.new("UICorner")
		UICorner.CornerRadius = UDim.new(1, 0)
		UICorner.Parent = label

		local params = Instance.new("GetTextBoundsParams")
		params.Text = label.ContentText
		params.Font = label.FontFace
		params.Size = label.TextSize
		params.Width = MAXWIDTH

		local size = TextService:GetTextBoundsAsync(params)
		--local size = TextService:GetTextSize(data.Text, 20, Enum.Font.SourceSans, Vector2.new(100, 1000))
		label.Size = UDim2.new(0, size.X + 10, 0, size.Y + 10)

		params:Destroy()
		return label
	end,

	["UnboxChances"] = function(ToolTip, data, priority)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 150, 0, 150)
		frame.BackgroundTransparency = 1

		local uigrid = Instance.new("UIGridLayout")
		uigrid.CellSize = UDim2.new(0, 40, 0, 40)
		uigrid.StartCorner = Enum.StartCorner.TopLeft
		uigrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uigrid.Parent = frame

		--Create chance uis
		for _, itemData in data.Data do
			local f
			if itemData.Image then
				f = Instance.new("ImageLabel")
				f.Image = itemData.Image
				local uicorner = Instance.new("UICorner")
				uicorner.CornerRadius = UDim.new(0, 5)
				uicorner.Parent = f
			elseif itemData.Model then
				f = Instance.new("ViewportFrame")
				f.Parent = frame

				local UICorner = Instance.new("UICorner")
				UICorner.Parent = f
				UICorner.CornerRadius = UDim.new(1, 0)

				local m = itemData.Model:Clone()
				m.Parent = f
				local c = Instance.new("Camera")
				c.Parent = f
				f.CurrentCamera = c

				m:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0))

				local VPF = ViewportFrameModel.new(f, c)
				VPF:SetModel(m)
				local cf = VPF:GetMinimumFitCFrame(CFrame.new(0, 0, 0))
				if itemData.Offset then
					cf = cf * itemData.Offset
				end
				c.CFrame = cf
			else
				f = Instance.new("Frame")
			end
			f.LayoutOrder = itemData.Chance

			local label = Instance.new("TextLabel")
			label.Text = math.floor(itemData.Chance) .. "%"
			label.Size = UDim2.new(1, 0, 0, 15)
			label.AnchorPoint = Vector2.new(0.5, 1)
			label.Position = UDim2.new(0.5, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.TextScaled = true
			label.Parent = f

			f.Parent = frame
		end

		local s = uigrid.AbsoluteContentSize
		frame.Size = UDim2.new(0, s.X, 0, s.Y)

		frame.LayoutOrder = priority

		return frame
	end,

	[MetadataTypes.Types.Strange] = function(ToolTip, data, priority)
		--Return a text label
		local StrangeItemData = require(ReplicatedStorage.Data.StrangeItemData)
		local StatData = require(ReplicatedStorage.Data.StatData)
		local ItemController = knit.GetController("ItemController")

		local itemData = ItemController:GetItemData(data.Item)
		local strangeData = StrangeItemData.ItemTypes[itemData.ItemType]
		local stat = StatData[strangeData.Stat]

		local label = Instance.new("TextLabel")
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Text = `{stat.Emoji} {formatter:Format(data.Data)}`
		label.TextSize = 14
		label.LayoutOrder = priority
		label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
		label.TextColor3 = Color3.fromRGB(255, 136, 39)
		label.BackgroundTransparency = 1

		local params = Instance.new("GetTextBoundsParams")
		params.Text = label.Text
		params.Font = label.FontFace
		params.Size = 14
		params.Width = MAXWIDTH

		local size = TextService:GetTextBoundsAsync(params)
		--local size = TextService:GetTextSize(data.Text, 20, Enum.Font.SourceSans, Vector2.new(100, 1000))
		label.Size = UDim2.new(0, size.X, 0, size.Y)

		params:Destroy()
		return label
	end,

	[MetadataTypes.Types.StrangeParts] = function(ToolTip, data, priority)
		--Return a text label
		local StrangeItemData = require(ReplicatedStorage.Data.StrangeItemData)
		local StatData = require(ReplicatedStorage.Data.StatData)

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 150, 0, 150)
		frame.BackgroundTransparency = 1

		local uigrid = Instance.new("UIListLayout")
		uigrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uigrid.VerticalAlignment = Enum.VerticalAlignment.Center
		uigrid.FillDirection = Enum.FillDirection.Vertical
		uigrid.Parent = frame

		--Create chance uis
		for part, value in data.Data do
			--Create strange stuff here
			local d = StrangeItemData.Parts[part]
			if not d then
				continue
			end
			local sd = StatData[d.Stat]

			local l = Instance.new("TextLabel")

			l.Text = `{sd.Emoji} {formatter:Format(value)}`
			l.TextSize = 14
			l.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
			l.TextColor3 = Color3.fromRGB(255, 136, 39)
			l.BackgroundTransparency = 1

			local params = Instance.new("GetTextBoundsParams")
			params.Text = l.Text
			params.Font = l.FontFace
			params.Size = 14
			params.Width = MAXWIDTH

			local size = TextService:GetTextBoundsAsync(params)
			--local size = TextService:GetTextSize(data.Text, 20, Enum.Font.SourceSans, Vector2.new(100, 1000))
			l.Size = UDim2.new(0, size.X, 0, size.Y)

			l.Parent = frame
		end

		local s = uigrid.AbsoluteContentSize
		frame.Size = UDim2.new(0, s.X, 0, s.Y)

		frame.LayoutOrder = priority

		return frame
	end,

	[MetadataTypes.Types.Autograph] = function(ToolTip, data, priority)
		--Return a text label
		local success, info = pcall(function()
			return UserService:GetUserInfosByUserIdsAsync({
				data.UserId,
			})
		end)
		if not success then
			return
		end
		if not info[1] then
			return
		end
		local playerInfo = info[1]

		local label = Instance.new("TextLabel")
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Text = `{playerInfo.Username}`
		label.TextSize = 14
		label.LayoutOrder = priority
		label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
		label.TextColor3 = Color3.fromRGB(255, 136, 39)
		label.BackgroundTransparency = 1

		local params = Instance.new("GetTextBoundsParams")
		params.Text = label.Text
		params.Font = label.FontFace
		params.Size = 14
		params.Width = MAXWIDTH

		local size = TextService:GetTextBoundsAsync(params)
		--local size = TextService:GetTextSize(data.Text, 20, Enum.Font.SourceSans, Vector2.new(100, 1000))
		label.Size = UDim2.new(0, size.X, 0, size.Y)

		params:Destroy()
		return label
	end,
}

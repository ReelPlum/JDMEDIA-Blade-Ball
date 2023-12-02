--[[
Types
2023, 11, 14
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local TextService = game:GetService("TextService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local FormatNumber = require(ReplicatedStorage.Packages.FormatNumber)

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
		label.Size = UDim2.new(0, size.X + 10, 0, size.Y + 10)

		params:Destroy()
		return label
	end,

	[MetadataTypes.Types.Untradeable] = function(ToolTip, data, priority)
		--Return a text label
		local label = Instance.new("TextLabel")
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Text = "UNTRADEABLE"
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
			local f = Instance.new("ImageLabel")
			f.Image = itemData.Image
			f.LayoutOrder = itemData.Chance
			local uicorner = Instance.new("UICorner")
			uicorner.CornerRadius = UDim.new(0, 5)
			uicorner.Parent = f
			local label = Instance.new("TextLabel")
			label.Text = itemData.Chance .. "%"
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
}

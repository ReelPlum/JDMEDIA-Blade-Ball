--[[
UnboxingFrame
2023, 11, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local itemFrame = require(script.Parent.Item)

local UnboxingFrame = {}
UnboxingFrame.ClassName = "UnboxingFrame"
UnboxingFrame.__index = UnboxingFrame

function UnboxingFrame.new(unboxing, frames)
	local self = setmetatable({}, UnboxingFrame)

	self.Janitor = janitor.new()
	self.UnboxingJanitor = self.Janitor:Add(janitor.new())

	self.UnboxFrame = unboxing
	self.Frames = frames

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		Finished = self.Janitor:Add(signal.new()),
		CrossedFrame = self.Janitor:Add(signal.new()),
	}

	return self
end

local function CalculateMovedDistance(t, maxTime, wantedDistance)
	--return startVelocity * t + 1 / 2 * acceleration * t ^ 2

	local x = t / maxTime
	-- local i = 1 - math.pow(1 - x, 4)
	-- if x == 1 then
	-- 	i = 1
	-- else
	-- 	i = 1 - math.pow(2, -10 * x)
	-- end

	local i = 1 - math.pow(1 - x, 4)

	return wantedDistance * i
end

local function CalculateFinish()
	--return -startVelocity / (2 * 1 / 2 * acceleration)
	return math.random(12 * 1000, 17 * 1000) / 1000
end

local function CreateItemFrame()
	--Clone item clone
	local UIFrame = ReplicatedStorage.Assets.UI.Item:Clone()
	UIFrame.AutoButtonColor = false
	UIFrame.Size = UDim2.new(1, 0, 1, 0)
	UIFrame.AnchorPoint = Vector2.new(0.5, 0.5)

	local aspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	aspectRatioConstraint.AspectRatio = 1
	aspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	aspectRatioConstraint.Parent = UIFrame

	return UIFrame
end

local function UpdateItemFrameWithItem(ui, case, itemIndex)
	--Sets itemframe to item

	--Check if item is currency or item
	--if item then set image to item. Remember to take account for metadata. Use itemcontroller here.
	--If currency then set image to currency image, and text to "amount" "currencyname"
end

local function RandomItemFromWeightedTable(t)
	return t[math.random(1, #t)]
end

local function GenerateWeightedTableFromCase(case)
	local ShopController = knit.GetController("ShopController")

	local unboxable = ShopController:GetUnboxable(case)

	local t = {}
	for index, data in unboxable.DropList do
		for _ = 1, data.Weight do
			table.insert(t, index)
		end
	end

	return t
end

function UnboxingFrame:AnimateUnboxing(case, winningItem)
	self.Finished = false
	self.UnboxingJanitor:Cleanup()

	--Animates unboxing for case with the winning item

	local finish = CalculateFinish()
	local totalDistance = math.random(80 * 1000, 150 * 1000) / 1000 --ItemFrames
	local finalItemNumber = math.floor(totalDistance + 0.5)

	print(finalItemNumber)
	print(totalDistance)

	local weightedTable = GenerateWeightedTableFromCase(case)

	--Setup items in frames. We know the total distance in item frames, which means we know how many itemframes we need to generate.
	local FrameWidths = {}
	local FrameAmounts = {}
	local Items = {}
	local LoadedItem = {}
	local ItemList = nil

	local MaxIndex = {}

	for _, frame in self.Frames do
		local frameWidth = frame.AbsoluteSize.Y / frame.AbsoluteSize.X
		local frameAmount = math.floor((1 / frameWidth) + 0.5)

		FrameWidths[frame] = frameWidth
		Items[frame] = {}
		FrameAmounts[frame] = frameAmount
		LoadedItem[frame] = {}

		if not ItemList then
			ItemList = {}
			for i = -frameAmount, finalItemNumber + frameAmount do
				if i == finalItemNumber then
					ItemList[finalItemNumber] = winningItem
					continue
				end
				ItemList[i] = RandomItemFromWeightedTable(weightedTable)
			end
			ItemList[finalItemNumber] = winningItem
		end

		MaxIndex[frame] = frameAmount

		for i = -frameAmount, frameAmount do
			--Create frame
			local ui = self.UnboxingJanitor:Add(CreateItemFrame())

			--Set item to corresponding item from itemlist
			UpdateItemFrameWithItem(ui, case, ItemList[i])
			LoadedItem[frame][i] = ItemList[i]
			ui.Parent = frame

			local itm = self.UnboxingJanitor:Add(itemFrame.new(self, ui, FrameWidths[frame], i))
			itm:Update(i, case, ItemList[i])
			if i == finalItemNumber then
				print(ItemList[i])
			end

			table.insert(Items[frame], itm)
		end
	end

	--Animate
	local t = 0
	self.UnboxingJanitor:Add(RunService.RenderStepped:Connect(function(dt)
		if self.Finished then
			return
		end

		t = t + dt

		local x = CalculateMovedDistance(t, finish, totalDistance)

		for frame, items in Items do
			for _, item in items do
				if not ItemList[item.Index] then
					continue
				end

				--Calculate where the items should be placed.
				item:SetPosition(x)
				if
					(item.Index - x) * FrameWidths[frame] > -FrameWidths[frame] / 2
					and (item.Index - x) * FrameWidths[frame] < FrameWidths[frame] / 2
				then
					--print((item.Index - x) * FrameWidths[frame])
					--print(item.Index)
				end

				--Check if items get out of range.
				if x - item.Index > FrameAmounts[frame] then
					--Out of range.
					--Spawn in new items if items got out of range and destroy the items that got out of range
					if MaxIndex[frame] + 1 == finalItemNumber then
						print(ItemList[MaxIndex[frame] + 1])
					end
					MaxIndex[frame] += 1
					item:Update(MaxIndex[frame], case, ItemList[MaxIndex[frame]])
				end
			end
		end

		if math.min(t, finish) == finish then
			self.Finished = true
			print(totalDistance)
			print(x)

			task.wait(2)
			self.Signals.Finished:Fire(case, winningItem)
			return
		end
	end))
end

function UnboxingFrame:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return UnboxingFrame

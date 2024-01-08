--[[
____________________________________________________________________________________________________________________________________________________________________________

 @ CloneTrooper1019, 2014 (with some edits by TheNexusAvenger in 2016)
	(Some code provided by Mark Langen, also known as stravant)


	This module comes with API for controlling 3D to 2D. 

____________________________________________________________________________________________________________________________________________________________________________

	(API DETAILS) Assuming that 'Module3d' is require(Module3D) this is how to use the library:
____________________________________________________________________________________________________________________________________________________________________________
		
		* Module3d:Attach3D(Instance guiObj, Instance model)
			Description:
				* Attaches a part/model to the center of the gui object specified.
				* Can have its offset changed as well as its active state. By default the model is hidden, and you need to call SetActive onto it manually
			Arguments:
				* Instance guiObj
					- guiObj must be any kind of Gui object that contains a "Position" property, such as a Frame, ImageLabel, etc.
				* Instance model
				 	- model can be either a Model, or a BasePart (Part, Wedge, Truss, etc).
			Returns:
				* 3dController
					- This is a library with a few functions and one property. It allows you to control your 3D Model's behavior.
						* 3dController:SetActive(boolean active)
							- Toggles whether or not the 3D Object should be shown or not
						* 3dController:SetCFrame(CoordinateFrame Offset)
							- Sets a CFrame rotation and offset from the location its trying to place the 3D Model.
							- Note that by default, it sets the CFrame a blank CFrame.new() ( or CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) )
						* 3dController:End()
							- Effectively Removes the model and disconnects its movement events.
						* 3dController.Object3D
							- The current model being used.
			Example Code:
			
				----------------------------------------------------------------------------------------------------------
				local handler = require(script.Parent.Module3D)
				local model = workspace.Guy
				local frame = script.Parent.Frame
				local activeModel = handler:Attach3D(frame,model)
				activeModel:SetActive(true)
				activeModel:SetCFrame(CFrame.fromEulerAnglesXYZ(0,math.pi,0))
				----------------------------------------------------------------------------------------------------------
____________________________________________________________________________________________________________________________________________________________________________

	Script Starts Below...
____________________________________________________________________________________________________________________________________________________________________________																																																																--]]

-- Double check that we are being called from the client...

local isClient = (game.Players.LocalPlayer ~= nil)

if not isClient then
	error("ERROR: '"..script:GetFullName().."' can only be used from a LocalScript.")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- API

local ModuleAPI = {}
local Camera = game.Workspace.Camera
local RenderStepped = game["Run Service"].RenderStepped
local Player = game.Players.LocalPlayer
local CFrameAngles = CFrame.Angles

local GetMouse = Player.GetMouse
local function GetScreenResolution()
	local Mouse = GetMouse(Player)
	if Mouse then
		local ViewSizeX,ViewSizeY = Mouse.ViewSizeX,Mouse.ViewSizeY
		if ViewSizeX > 0 and ViewSizeY > 0 then
			return ViewSizeX,ViewSizeY
		end
	end
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		local ScreenGui
		for _,C in pairs(PlayerGui:GetChildren()) do
			if C:IsA("ScreenGui") then
				ScreenGui = C
			end
		end
		if not ScreenGui then -- Not sure if this is possible assuming the scenario. But you never know.
			ScreenGui = Instance.new("ScreenGui",PlayerGui)
			wait(.1) -- Wait just a moment for the property to get set.
		end
		return ScreenGui.AbsoluteSize.X,ScreenGui.AbsoluteSize.Y
	end
	return error("ERROR: Can't get client resolution")
end


local rad,tan,max,huge,abs = math.rad,math.tan,math.max,math.huge,math.abs
local function GetDepthForWidth(PartWidth,VisibleSize,ResolutionX,ResolutionY,FieldOfView)
	local AspectRatio = ResolutionX/ResolutionY
	local HFactor = tan(rad(FieldOfView)/2)
	local WFactor = AspectRatio*HFactor
	
	return abs(-0.5*ResolutionX*PartWidth/(VisibleSize*WFactor))
end

local Instancenew = Instance.new
function ModuleAPI:Attach3D(GuiObj,Model,SizeOverride)
	local Index = {}
	local M = Instance.new("Model")
	M.Name = "Model"
	M.Parent = Camera
	local Objs = {}
	if Model:IsA("BasePart") then
		local This = Model:Clone()
		This.Parent = M
		table.insert(Objs,This)
	else
		local function Recurse(Obj)
			for _,V in pairs(Obj:GetChildren()) do
				local Part
				if V:IsA("BasePart") then
					Part = V:Clone()
				elseif V:IsA("Hat") and V:FindFirstChild("Handle") then
					Part = V.Handle:Clone()
				end
				if Part then
					Part.Anchored = true
					Part.Parent = M
					if Part:FindFirstChild("Decal") and Part.Transparency ~= 0 then
						Part:Destroy()
					elseif Part.Name == "Head" then
						Part.Name = "H"
					end
					if Part.Parent == M then
						table.insert(Objs,Part)
					end
				elseif not V:IsA("Model") and not V:IsA("Sound") and not V:IsA("Script") then
					V:Clone().Parent = M
				else
					Recurse(V)
				end
			end
		end
		Recurse(Model)
	end
	
	local CF = CFrame.new(0,0,0)
	
	local ModelSize = SizeOverride or M:GetExtentsSize()
	local Primary = Instancenew("UnionOperation")
	Primary.Anchored = true
	Primary.Transparency = 1
	Primary.CanCollide = false
	Primary.Name = "MODEL_CENTER"
	Primary.Size = ModelSize
	Primary.CFrame = CFrame.new(M:GetModelCFrame().p)
	Primary.Parent = M
	M.PrimaryPart = Primary
	for _,V in pairs(Objs) do
		V.Anchored = true
		V.CanCollide = false
		V.Archivable = true
		V.Parent = M
	end
	local Active = false
	function Index:SetActive(B)
		Active = B
	end
	function Index:SetCFrame(NewCF)
		CF = NewCF
	end
	
	local CFramenew,CFrameAngles = CFrame.new,CFrame.Angles
	local components = CFramenew().components
	local SetPrimaryPartCFrame = M.SetPrimaryPartCFrame
	local HighCF = CFramenew(0,100000,0)
	local ScreenPointToRay = Camera.ScreenPointToRay
	local Width = max(Primary.Size.X,Primary.Size.Y,Primary.Size.Z)
	
	local WasMoved = false
	local MaxFieldOfView = 120
	local function UpdateModel()
		if Active then
			local AbsoluteSize,AbsolutePosition = GuiObj.AbsoluteSize,GuiObj.AbsolutePosition
			local SizeX,SizeY = AbsoluteSize.X,AbsoluteSize.Y
			local PointX,PointY = AbsolutePosition.X + (SizeX/2),AbsolutePosition.Y + (SizeY/2)
			
			local Viewport = Camera.ViewportSize
			local ViewportX,ViewportY = Viewport.X,Viewport.Y
			local FieldOfView = Camera.FieldOfView
			local AngleX,AngleY = (ViewportX/ViewportY) * FieldOfView,FieldOfView
			
			local CenterX,CenterY  = ViewportX/2,ViewportY/2
			local CenterXMult,CenterYMult = (PointX - CenterX)/CenterX,(PointY - CenterY)/CenterY
			if AngleX > MaxFieldOfView then
				AngleY = FieldOfView * (MaxFieldOfView/AngleX)
				AngleX = MaxFieldOfView
			end
			
			-- local PositionRay = ScreenPointToRay(Camera,PointX,PointY,GetDepthForWidth(Width,(SizeX < SizeY and SizeX or SizeY),ViewportX,ViewportY,FieldOfView))
			local PositionRay = ScreenPointToRay(Camera,PointX,PointY,1)

			local scale = 1.5 / GetDepthForWidth(Width,(SizeX < SizeY and SizeX or SizeY),ViewportX,ViewportY,FieldOfView)

			local Position = PositionRay.Origin + PositionRay.Direction
			local PositionX,PositionY,PositionZ = Position.X,Position.Y,Position.Z
			local _,_,_,A,B,C,D,E,F,G,H,I = components(Camera.CFrame)
			if PositionX == huge or PositionX == -huge then PositionX = 0 end
			if PositionY == huge or PositionY == -huge then PositionY = 0 end
			if PositionZ == huge or PositionZ == -huge then PositionZ = 0 end
			
			local NewCF = CFramenew(PositionX,PositionY,PositionZ,A,B,C,D,E,F,G,H,I) * CFrameAngles(-rad(AngleY/2) * CenterYMult,-rad(AngleX/2) * CenterXMult,0)
			SetPrimaryPartCFrame(M,NewCF * CF)
			M:ScaleTo(scale)
			WasMoved = false
		elseif WasMoved == false then
			SetPrimaryPartCFrame(M,HighCF)
			WasMoved = true
		end
	end
	
	
	local Con = RenderStepped:connect(UpdateModel)	
	
	function Index:End()
		if Con then Con:disconnect() end
		pcall(function ()
			M:Destroy()
		end)
		return
	end
	Index.Object3D = M
	return Index
end

return ModuleAPI
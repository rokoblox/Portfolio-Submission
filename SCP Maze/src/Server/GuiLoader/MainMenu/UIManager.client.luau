local MainMenu = script.Parent:WaitForChild("MainMenu")
local OptionsMenu = script.Parent:WaitForChild("OptionsMenu")
local Title = MainMenu:WaitForChild("Title")
local PlayButton = MainMenu:WaitForChild("PlayButton")
local ShopButton = MainMenu:WaitForChild("ShopButton")
local OptionsButton = MainMenu:WaitForChild("OptionsButton")
local InfoButton = MainMenu:WaitForChild("InfoButton")
local HoverSound = script.Parent:WaitForChild("Hover")
local FadeFrame = script.Parent:WaitForChild("FadeFrame")
local MusicScript = script.Parent:WaitForChild("Music")
local Music = MusicScript:WaitForChild("Music")
local IntroInfo = script.Parent:WaitForChild("IntroInfo")
local PlayEvent = game.ReplicatedStorage:WaitForChild("RequestSpawn")
local MouseImage = script.Parent:WaitForChild("MouseImage")
local Lighting = game:GetService("Lighting")
local Blur = Lighting:WaitForChild("Blur")
local ButtonsClickable = false
local OnMainMenu = true

local BaseButtonOffset = 30
local HoverButtonOffset = 50
local CanFade = false

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TweenInformation = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
local FrameFade = TweenService:Create(FadeFrame, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true, 0), {BackgroundTransparency = 0})

local Buttons = {PlayButton, ShopButton, OptionsButton, InfoButton}

for i,v in ipairs(Buttons) do
	v.MouseEnter:Connect(function()
		TweenService:Create(v, TweenInformation, {Position = UDim2.fromOffset(HoverButtonOffset, v.Position.Y.Offset)}):Play()
		local c = HoverSound:Clone()
		c.Parent = script.Parent
		c:Play()
		Debris:AddItem(c, 1)
	end)
	v.MouseLeave:Connect(function()
		TweenService:Create(v, TweenInformation, {Position = UDim2.fromOffset(BaseButtonOffset, v.Position.Y.Offset)}):Play()
	end)
end






PlayButton.MouseButton1Click:Connect(function()
	if ButtonsClickable == true then
		CanFade = false
		ButtonsClickable = false
		for i,v in ipairs(Buttons) do
			TweenService:Create(v, TweenInfo.new(2, Enum.EasingStyle.Linear), {TextTransparency = 1}):Play()
		end
		TweenService:Create(Title, TweenInfo.new(2, Enum.EasingStyle.Linear), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
		wait(2.5)
		TweenService:Create(Music, TweenInfo.new(5, Enum.EasingStyle.Linear), {Volume = 0}):Play()
		FadeFrame.ZIndex = 10
		TweenService:Create(FadeFrame, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true, 0), {BackgroundTransparency = 0}):Play()
		wait(2)
		Blur.Size = 3
		Lighting.Brightness = 0.3
		Lighting.Ambient = Color3.fromRGB(50, 50, 50)
		for i,v in ipairs(Buttons) do
			v.Visible = false
		end
		MouseImage.Visible = false
		OnMainMenu = false
		PlayEvent:FireServer()
		wait(1)
		TweenService:Create(FadeFrame, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true, 0), {BackgroundTransparency = 1}):Play()
		wait(2)
		Music:Stop()
		TweenService:Create(FadeFrame, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true, 0), {BackgroundTransparency = 1}):Play()
	end
end)

OptionsButton.MouseButton1Click:Connect(function()
	if ButtonsClickable == true then
		ButtonsClickable = false
		TweenService:Create(MainMenu, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {AnchorPoint = Vector2.new(0,1)}):Play()
		TweenService:Create(OptionsMenu, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {AnchorPoint = Vector2.new(0,1)}):Play()
		wait(0.5)
		ButtonsClickable = true
	end
end)






local Camera = workspace.CurrentCamera
local CameraFolder = workspace:WaitForChild("CameraAligns")
local Cameras = {CameraFolder:WaitForChild("Part1"),CameraFolder:WaitForChild("Part2"),CameraFolder:WaitForChild("Part3"),CameraFolder:WaitForChild("Part4")}
local CurrentCamera = 1
local Rotation = 15
local Dir = 1

spawn(function()
	
end)
spawn(function()
	while true do
		Dir = -Dir
		for i = 1,60 do
			Rotation = Rotation + (0.5 * Dir)
			wait(0.03)
		end
		wait(1)
	end
end)

game:GetService("RunService").RenderStepped:Connect(function(dl)
	if OnMainMenu == true then
		Camera.CFrame = Cameras[CurrentCamera].CFrame * CFrame.Angles(0, math.rad(Rotation), 0)
	end
end)

spawn(function()
	while true do
		wait(10)
		if CanFade == true then
			FrameFade:Play()
			wait(0.5)
			CurrentCamera = CurrentCamera + 1
			if CurrentCamera > #Cameras then
				CurrentCamera = 1
			end
		end
	end
end)

wait(10)
TweenService:Create(IntroInfo, TweenInfo.new(5, Enum.EasingStyle.Linear), {TextTransparency = 0}):Play()
MusicScript.Disabled = false
wait(5)
TweenService:Create(IntroInfo, TweenInfo.new(5, Enum.EasingStyle.Linear), {TextTransparency = 1}):Play()
wait(3)
TweenService:Create(FadeFrame, TweenInfo.new(5, Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
wait(5)
ButtonsClickable = true
CanFade = true
FadeFrame.ZIndex = -5
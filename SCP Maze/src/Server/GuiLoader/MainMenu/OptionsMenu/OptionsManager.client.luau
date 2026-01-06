local MainMenu = script.Parent.Parent:WaitForChild("MainMenu")
local OptionsMenu = script.Parent
local BackButton = OptionsMenu:WaitForChild("BackButton")
local BlurToggle = OptionsMenu:WaitForChild("BlurToggle")
local DoFToggle = OptionsMenu:WaitForChild("DoFToggle")
local HoverSound = script.Parent.Parent:WaitForChild("Hover")
local Blur = game:GetService("Lighting"):WaitForChild("Blur")
local DoF = game:GetService("Lighting"):WaitForChild("DepthOfField")
Blur.Enabled = true DoF.Enabled = true
local ButtonsClickable = false

local HoverButtonOffset = 20
local CanFade = false

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TweenInformation = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)

local Buttons = {{BackButton, BackButton.Position.X.Offset}, {BlurToggle, BlurToggle.Position.X.Offset}, {DoFToggle, DoFToggle.Position.X.Offset}}

for i,v in ipairs(Buttons) do
	v[1].MouseLeave:Connect(function()
		TweenService:Create(v[1], TweenInformation, {Position = UDim2.fromOffset(v[2], v[1].Position.Y.Offset)}):Play()
	end)
	v[1].MouseEnter:Connect(function()
		TweenService:Create(v[1], TweenInformation, {Position = UDim2.fromOffset(v[2] + HoverButtonOffset, v[1].Position.Y.Offset)}):Play()
		local c = HoverSound:Clone()
		c.Parent = script.Parent
		c:Play()
		Debris:AddItem(c, 1)
	end)
end




local function OnOrOff(state)
	if state == true then
		return "On"
	end
	return "Off"
end



BackButton.MouseButton1Click:Connect(function()
	if ButtonsClickable == true then
		TweenService:Create(OptionsMenu, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {AnchorPoint = Vector2.new(0,0)}):Play()
		TweenService:Create(MainMenu, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {AnchorPoint = Vector2.new(0,0)}):Play()
	end
end)

BlurToggle.MouseButton1Click:Connect(function()
	if ButtonsClickable == true then
		Blur.Enabled = not Blur.Enabled
		BlurToggle.Text = "Blur: " .. OnOrOff(Blur.Enabled)
	end
end)

DoFToggle.MouseButton1Click:Connect(function()
	if ButtonsClickable == true then
		DoF.Enabled = not DoF.Enabled
		DoFToggle.Text = "Depth Of Field: " .. OnOrOff(DoF.Enabled)
	end
end)


while true do
	if OptionsMenu.AnchorPoint == Vector2.new(0,1) then
		ButtonsClickable = true
	else
		ButtonsClickable = false
	end
	wait()
end
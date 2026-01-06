game:GetService("UserInputService").MouseIconEnabled = false
local MouseImage = script.Parent:WaitForChild("MouseImage")
local Mouse = game.Players.LocalPlayer:GetMouse()

local c = game:GetService("RunService").RenderStepped:Connect(function()
	MouseImage.Position = UDim2.fromOffset(Mouse.X, Mouse.Y + 36)
end)

if game:GetService("UserInputService").TouchEnabled == true then
	c:Disconnect()
	MouseImage:Destroy()
end
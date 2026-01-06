return function()
	local Player = game.Players.LocalPlayer
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local Camera = workspace.CurrentCamera
	local Mouse = Player:GetMouse()
	Camera.CameraType = Enum.CameraType.Scriptable
	local CameraFocus = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, -1))
	local x, y = 0, 0
	local Zoom = 12

	Mouse.Button2Down:Connect(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end)
	Mouse.Button2Up:Connect(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end)

	local function updatecam()
		local delta = UserInputService:GetMouseDelta()
		local sensitivity = UserSettings().GameSettings.MouseSensitivity
		x += delta.X * sensitivity
		y -= delta.Y * sensitivity
		y = math.clamp(y, -60, 60)
		CameraFocus = CFrame.new(CameraFocus.Position) * CFrame.Angles(0,math.rad(-x),0)
		CameraFocus = CameraFocus * CFrame.Angles(math.rad(-y),0,0)
		Camera.CFrame = CameraFocus * CFrame.new(0, 0, -Zoom) * CFrame.Angles(0, math.rad(180), 0)
	end

	RunService:BindToRenderStep("MeasureMouseMovement",Enum.RenderPriority.Input.Value,updatecam)
end

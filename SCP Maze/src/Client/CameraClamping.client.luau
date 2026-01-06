local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
RunService:BindToRenderStep("CameraClamping", Enum.RenderPriority.Camera.Value + 1, function()
	local rX, rY, rZ = camera.CFrame:ToOrientation()
	local limX = math.clamp(math.deg(rX), -45, 45)
	camera.CFrame = CFrame.new(camera.CFrame.p) * CFrame.fromOrientation(math.rad(limX), rY, rZ)
end)

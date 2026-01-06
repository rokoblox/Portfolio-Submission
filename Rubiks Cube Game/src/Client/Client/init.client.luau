print("Version 0.1.0-dev.4")
require(script.camera)()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Roact)
local Cube = require(ReplicatedStorage.lib).cube
local Cube_Selector = require(script.cube_selector)

local Camera = workspace.CurrentCamera

local cube = Cube.new(3)
cube.model.Parent = workspace
local cube_selector = Cube_Selector.new(cube, {
	top = {{"Q", nil}, {nil, nil}, {"W", nil}},
	bottom = {{"Q", "LeftShift"}, {nil, nil}, {"W", "LeftShift"}},
	right = {{"S", nil}, {nil, nil}, {"X", nil}},
	left = {{"S", "LeftShift"}, {nil, nil}, {"X", "LeftShift"}},
})

local app = Roact.createElement("ScreenGui", {
	IgnoreGuiInset = true,
}, {
	RotateButton = Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 5, 0, 5),
		Rotation = 45,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	}),
})

task.wait(3)
cube:scramble()

local accepted_inputs = {
	Enum.KeyCode.Q,
	Enum.KeyCode.S,
	Enum.KeyCode.W,
	Enum.KeyCode.X,
	Enum.KeyCode.R,
}

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {cube.model}
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
local selected_face = "f"
RunService.RenderStepped:Connect(function()
	-- calculate which face the camera is looking at
	local ray = Ray.new(Camera.CFrame.Position, Camera.CFrame.LookVector * 16)
	local hit = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 16, raycastParams)
	if hit then
		local pos = hit.Position
		local highest = math.max(math.abs(pos.X), math.abs(pos.Y), math.abs(pos.Z))
		if highest == math.abs(pos.X) then
			if pos.X > 0 then
				selected_face = "l"
			else
				selected_face = "r"
			end
		elseif highest == math.abs(pos.Y) then
			if pos.Y > 0 then
				selected_face = "u"
			else
				selected_face = "d"
			end
		elseif highest == math.abs(pos.Z) then
			if pos.Z > 0 then
				selected_face = "b"
			else
				selected_face = "f"
			end
		end
	end

	cube_selector:set_face(selected_face)
end)

local face_inputs = {
	f = {
		{"x", 1, true},
		{"y", 1, false},
		{"x", 3, true},
		{"y", 3, false},
		{"z", 1, true},
	},
	b = {
		{"x", 3, false},
		{"y", 1, false},
		{"x", 1, false},
		{"y", 3, false},
		{"z", 3, false},
	},
	r = {
		{"z", 1, false},
		{"y", 1, false},
		{"z", 3, false},
		{"y", 3, false},
		{"x", 3, true},
	},
	l = {
		{"z", 3, true},
		{"y", 1, false},
		{"z", 1, true},
		{"y", 3, false},
		{"x", 1, false},
	},
}

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if table.find(accepted_inputs, input.KeyCode) then
		local axis = "z"
		local layer = 1
		local clockwise = true
		local input_index = table.find(accepted_inputs, input.KeyCode)

		if face_inputs[selected_face] then
			axis, layer, clockwise = table.unpack(face_inputs[selected_face][input_index])
		else
			return
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			clockwise = not clockwise
		end
		cube:rotate_layer(axis, layer, clockwise, "f")
		print(cube:verify())
	end
end)

local g = Roact.mount(app, Players.LocalPlayer:WaitForChild("PlayerGui"))
while true do
	Players.LocalPlayer.PlayerGui.RoactTree.Enabled = true
	task.wait()
end

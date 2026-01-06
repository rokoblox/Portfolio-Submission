local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local utils = require(script.Parent.utils)
local debug_utils = require(script.Parent.debug_utils)

local cube = {}
cube.__index = cube

-- order of face names in part names is u -> f -> r -> l -> b -> d
local face_letter_order = {u=1, f=2, r=3, l=4, b=5, d=6}
function cube:_generate_cube(side_length)
	self.model = Instance.new("Model")
	self.model.Name = "Cube"

	local PrimaryPart = Instance.new("Part")
	PrimaryPart.Name = "PrimaryPart"
	PrimaryPart.Size = Vector3.new(1, 1, 1)
	PrimaryPart.Anchored = true
	PrimaryPart.CanCollide = false
	PrimaryPart.CFrame = CFrame.new(0, 0, 0)
	PrimaryPart.Transparency = 1
	PrimaryPart.Parent = self.model
	self.model.PrimaryPart = PrimaryPart

	self._data = {}
	self._part_index = {}

	self.part_size = self.part_template.PrimaryPart.Size.X
	local half_side_length = (side_length * self.part_size) / 2 - self.part_size / 2
	for z = 1, side_length do
		self._data[z] = {}
		for y = 1, side_length do
			self._data[z][y] = {}
			for x = 1, side_length do
				local part = self.part_template:Clone();
				part.Name = string.format("%d_%d_%d", z, y, x)
				part:SetPrimaryPartCFrame(CFrame.new(
					(side_length - x) * self.part_size - half_side_length,
					(side_length - y) * self.part_size - half_side_length,
					(z - 1) * self.part_size - half_side_length
				))
				-- optimizing parts by deleting hidden faces of a part
				if x ~= 1 then part.l:Destroy() part.PrimaryPart.l:Destroy() end
				if x ~= side_length then part.r:Destroy() part.PrimaryPart.r:Destroy() end
				if y ~= 1 then part.u:Destroy() part.PrimaryPart.u:Destroy() end
				if y ~= side_length then part.d:Destroy() part.PrimaryPart.d:Destroy() end
				if z ~= 1 then part.f:Destroy() part.PrimaryPart.f:Destroy() end
				if z ~= side_length then part.b:Destroy() part.PrimaryPart.b:Destroy() end

				part.Parent = self.model
				self._data[z][y][x] = part.Name
				self._part_index[part.Name] = part
			end
		end
	end
end

-- This function is used internally by _update function to update part positions.
function cube:_update_model()
	local cframe = self._tween_data.origin_cframe:Lerp(self._tween_data.target_cframe, TweenService:GetValue(self._tween_data.theta, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut))
	for i, v in pairs(self._tween_data.rotating_parts) do
		v[1]:SetPrimaryPartCFrame(cframe * v[2])
	end
end

-- This function is called every frame to update the cube's parts during rotation since we aren't using TweenService to do the rotation.
-- Do not call this function manually, It is already connected to RenderStep.
function cube:_update(dt)
	if self._tween_data.rotating then
		self._tween_data.theta += dt / self._tween_data.rotating_speed
		self._tween_data.theta = math.clamp(self._tween_data.theta, 0, 1)
		self:_update_model()
		if self._tween_data.theta == 1 then
			self._tween_data.rotating = false
			self._tween_data.theta = 0
		end
	end
end

function cube.new(side_length, template)
	local self = setmetatable({}, cube)
	self.side_length = side_length
	self.part_template = template or ReplicatedStorage.Assets.PartTemplates.Default
	self:_generate_cube(side_length)
	self._correct_data = utils.deep_copy(self._data)

	self._tween_data = {
		rotating = false,
		rotating_speed = 0.3, -- time taken to do a full rotation
		origin_cframe = nil,
		target_cframe = nil,
		theta = 0,
		rotating_parts = {},
	}
	RunService.RenderStepped:Connect(function(dt)
		self:_update(dt)
	end)

	return self
end

function cube:verify()
	return utils.compare_tables(self._data, self._correct_data)
end

--[[
	x = -2, y = -1
	x = 1, y = -2
	x = 2, y = 1
	x = -1, y = 2
	clockwiseRotation =
	x = y, y = -x
	antiClockwiseRotation =
	x = -y, y = x

	always invert rotation when looking from right, back or down sides
	(since x, y plane is flipped)
]]
local function rotateIndex(x, y, clockwiseRotation, side_length)
	-- rotate x and y around the middle of the cube regardless of whether its even or odd and always
	-- get a positive, integer result to be used as an index

	local half_side_length = math.ceil(side_length/2)
	local x_offset = x - half_side_length
	local y_offset = y - half_side_length

	if half_side_length == side_length/2 then
		if x <= half_side_length then
			x_offset -= 1
		end
		if y <= half_side_length then
			y_offset -= 1
		end
	end

	if clockwiseRotation then
		x_offset, y_offset = y_offset, -x_offset
	else
		x_offset, y_offset = -y_offset, x_offset
	end

	x_offset += half_side_length
	y_offset += half_side_length

	if half_side_length == side_length/2 then
		if x_offset < half_side_length then
			x_offset += 1
		end
		if y_offset < half_side_length then
			y_offset += 1
		end
	end

	return x_offset, y_offset
end

function cube:_get_layer(axis, layer)
	local layer_data = {}
	local layer_data_index = {}
	for y = 1, self.side_length do
		layer_data[y] = {}
		layer_data_index[y] = {}
		for x = 1, self.side_length do
			layer_data[y][x] = ""
		end
	end

	-- rotate the 3D face
	if axis == "x" then
		for y = 1, self.side_length do
			for x = 1, self.side_length do
				layer_data[y][x] = self._data[x][y][layer]
				layer_data_index[y][x] = {x, y, layer}
			end
		end
	elseif axis == "y" then
		for y = 1, self.side_length do
			for x = 1, self.side_length do
				layer_data[y][x] = self._data[x][layer][y]
				layer_data_index[y][x] = {x, layer, y}
			end
		end
	elseif axis == "z" then
		for y = 1, self.side_length do
			for x = 1, self.side_length do
				layer_data[y][x] = self._data[layer][y][x]
				layer_data_index[y][x] = {layer, y, x}
			end
		end
	end

	return layer_data, layer_data_index
end

function cube:_rotate(axis, layer, is_clockwise)
	local layer_data, layer_data_index = self:_get_layer(axis, layer)

	-- Rotate the 3D part
	local new_layer_data = {}
	for y = 1, self.side_length do
		new_layer_data[y] = {}
		for x = 1, self.side_length do
			local new_x, new_y = rotateIndex(x, y, is_clockwise, self.side_length)
			new_layer_data[y][x] = layer_data[new_y][new_x]
		end
	end

	-- debug_utils.print_2d_table(layer_data)
	-- print("V")
	-- debug_utils.print_2d_table(new_layer_data)

	-- reapply new_layer_data to self._data using the indexes stored in layer_data_index
	for y = 1, self.side_length do
		for x = 1, self.side_length do
			local index = layer_data_index[y][x]
			self._data[index[1]][index[2]][index[3]] = new_layer_data[y][x]
		end
	end
	-- print(self._data)
end

local axis_to_look_vector = {
	x = Vector3.new(-1, 0, 0),
	y = Vector3.new(0, 1, 0),
	z = Vector3.new(0, 0, -1),
}
function cube:_rotate_model(axis, layer, is_clockwise)
	if self._tween_data.rotating then
		self._tween_data.theta = 1
		self:_update(0)
	end
	self._tween_data.rotating = true

	self._tween_data.origin_cframe = CFrame.new(self.model.PrimaryPart.Position, self.model.PrimaryPart.Position + axis_to_look_vector[axis])
	self._tween_data.target_cframe = self._tween_data.origin_cframe * CFrame.Angles(0, 0, is_clockwise and math.rad(90) or math.rad(-90))

	-- get the parts on the layer of the axis to rotate and place them in self._tween_data.rotating_parts
	local cframe_inverse = self._tween_data.origin_cframe:Inverse()
	local layer_data = self:_get_layer(axis, layer)
	local rotating_parts = {}
	for _, v in pairs(layer_data) do
		for _, v2 in pairs(v) do
			table.insert(rotating_parts, v2)
		end
	end
	for i, v in pairs(rotating_parts) do
		rotating_parts[i] = {self._part_index[v], cframe_inverse * self._part_index[v].PrimaryPart.CFrame}
	end

	self._tween_data.rotating_parts = rotating_parts
end

function cube:rotate_layer(axis, layer, is_clockwise, face)
	if face == "l" or face == "u" or face == "b" then
		self:_rotate(axis, layer, not is_clockwise)
		self:_rotate_model(axis, layer, not is_clockwise)
	else
		self:_rotate(axis, layer, is_clockwise)
		self:_rotate_model(axis, layer, is_clockwise)
	end
end

local function randomize_axis_layer_clockwise(side_length, lastAxis, lastLayer, lastClockwise)
	local axis = math.random(1, 3)
	local layer = math.random(1, side_length)
	local is_clockwise = math.random(1, 2) == 1
	if axis == lastAxis and layer == lastLayer and is_clockwise == not lastClockwise then
		return randomize_axis_layer_clockwise(side_length, lastAxis, lastLayer, lastClockwise)
	end
	return axis, layer, is_clockwise
end

local possible_axis = {"x", "y", "z"}
function cube:scramble()
	local original_rotation_speed = self._tween_data.rotating_speed
	self._tween_data.rotating_speed = 0.1
	local scramble_count = math.random(6 * self.side_length - 5, 6 * self.side_length)
	local lastAxis, lastLayer, lastIsClockwise = nil, nil, nil
	for i = 1, scramble_count do
		local axis, layer, is_clockwise = randomize_axis_layer_clockwise(self.side_length, lastAxis, lastLayer, lastIsClockwise)
		self:rotate_layer(possible_axis[axis], layer, is_clockwise, "f")
		while self._tween_data.rotating == true do RunService.RenderStepped:Wait() end
	end
	self._tween_data.rotating_speed = original_rotation_speed
end

return cube

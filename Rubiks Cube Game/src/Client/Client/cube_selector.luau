local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local key_hints = require(script.Parent.key_hints)

local cube_selector = {}
cube_selector.__index = cube_selector

function cube_selector:compute_template_data()
    local template_data = {}
    template_data.button_size = 100 * self.cube.part_size / 2
    template_data.initial_skip = template_data.button_size + 50 + template_data.button_size / 2

    template_data.size = self.cube.part_size * (self.cube.side_length + 1) + 1
    template_data.outline_position = UDim2.new(0, template_data.button_size, 0, template_data.button_size)
    template_data.outline_size = UDim2.new(1, -2 * template_data.button_size, 1, -2 * template_data.button_size)

    template_data.stud_offset = self.cube.side_length * self.cube.part_size / 2 + 0.1 -- 0.1 stud outside to prevent the cube from overlapping the UI
    template_data.fade = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

    self.template_data = template_data
end

local face_to_look_vector = {
    f = Vector3.new(0, 0, -1),
    b = Vector3.new(0, 0, 1),
    -- u = Vector3.new(0, 1, 0),
    -- d = Vector3.new(0, -1, 0),
    l = Vector3.new(1, 0, 0),
    r = Vector3.new(-1, 0, 0)
}
function cube_selector:set_face(face)
    if self.face == face then return end
    self.face = face
    if self.selection then
        Debris:AddItem(self.selection, 0.3)
        for _, item in pairs(self.selection:GetDescendants()) do
            if item:IsA("GuiObject") then
                TweenService:Create(item, self.template_data.fade, {ImageTransparency = 1}):Play()
            end
        end
        self.selection = nil
    end
    if not face_to_look_vector[face] then return end

    self.selection = ReplicatedStorage.Assets.SelectionTemplate:Clone()
    self.selection.Size = Vector3.new(self.template_data.size, self.template_data.size, 0.001)
    self.selection.CFrame = CFrame.new(face_to_look_vector[face] * self.template_data.stud_offset, face_to_look_vector[face] * 1000)

    -- create key hints from self.controls
    local key_hint_table = {}
    local key_hints_container = self.selection.FrontUI
    local key_hint_template = key_hints_container.Key_Template
    for setname, set in pairs(self.controls) do
        for i, binding in pairs(set) do
            if not binding[1] then continue end
            local key_hint = key_hint_template:Clone()
            local success, key_hint_image = pcall(key_hints.get_from_key, binding[1], true)
            if success then
                key_hint.Image = "rbxassetid://" .. key_hint_image
                key_hint.Name = binding[1] .. "_" .. (binding[2] or "nil")
            else
                key_hint.Image = "rbxassetid://" .. key_hints.get_from_name("Blank_Black_Normal")
            end

            -- set its position
            if setname == "top" then
                key_hint.Position = UDim2.new(0, self.template_data.initial_skip + (i-1) * self.template_data.button_size * 2, 0, 0)
            elseif setname == "bottom" then
                key_hint.Position = UDim2.new(0, self.template_data.initial_skip + (i-1) * self.template_data.button_size * 2, 1, -self.template_data.button_size)
            elseif setname == "left" then
                key_hint.Position = UDim2.new(0, 0, 0, self.template_data.initial_skip + (i-1) * self.template_data.button_size * 2)
            elseif setname == "right" then
                key_hint.Position = UDim2.new(1, -self.template_data.button_size, 0, self.template_data.initial_skip + (i-1) * self.template_data.button_size * 2)
            end
            key_hint.Size = UDim2.fromOffset(self.template_data.button_size, self.template_data.button_size)
            key_hint.Parent = key_hints_container
            table.insert(key_hint_table, key_hint)
        end
    end
    key_hint_template:Destroy()

    self.selection.FrontUI.Selection.Position = self.template_data.outline_position
    self.selection.FrontUI.Selection.Size = self.template_data.outline_size
    self.selection.BackUI.Selection.Position = self.template_data.outline_position
    self.selection.BackUI.Selection.Size = self.template_data.outline_size

    for _, item in pairs(key_hint_table) do
        TweenService:Create(item, self.template_data.fade, {ImageTransparency = 0}):Play()
    end
    TweenService:Create(self.selection.FrontUI.Selection, self.template_data.fade, {ImageTransparency = 0.3}):Play()
    TweenService:Create(self.selection.BackUI.Selection, self.template_data.fade, {ImageTransparency = 0.3}):Play()

    self.selection.Parent = workspace.CurrentCamera
end

function cube_selector.new(cube, controls)
    local self = setmetatable({}, cube_selector)
    self.cube = cube
    self.controls = controls or {
        top = {},
        bottom = {},
        left = {},
        right = {},
    }

    self:compute_template_data()
    return self
end

return cube_selector

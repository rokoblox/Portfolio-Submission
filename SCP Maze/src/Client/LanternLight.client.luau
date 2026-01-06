local Light = script:WaitForChild("PointLight")

while true do
	for i,v in pairs(workspace:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("Lantern") and v.Lantern:FindFirstChild("Light") and (v.Lantern.Light:FindFirstChild("PointLight") == nil) then
			local c = Light:Clone()
			c.Parent = v.Lantern.Light
			c.Enabled = true
			spawn(function()
				local l = v.Lantern.Light.PointLight
				while l and l.Parent ~= nil do
					for i = 1,15 do
						c.Brightness = c.Brightness - 0.02
						wait()
					end
					for i = 1,15 do
						c.Brightness = c.Brightness + 0.02
						wait()
					end
				end
			end)
		end
	end
	wait(.2)
end
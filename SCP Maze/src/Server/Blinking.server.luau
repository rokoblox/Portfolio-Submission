local BlinkTime = workspace:WaitForChild("BlinkTime")
local Blinking = workspace:WaitForChild("Blinking")
local TimeToBlink = 10
local RemainingTime = BlinkTime.Value

game:GetService("RunService").Heartbeat:Connect(function(dl)
	RemainingTime = RemainingTime - dl
	local NextNegative = 0
	if RemainingTime < 0 then
		NextNegative = RemainingTime
		spawn(function()
			wait(0.2)
			Blinking.Value = true
			wait(0.3)
			Blinking.Value = false
		end)
		RemainingTime = TimeToBlink + NextNegative
	end
	BlinkTime.Value = RemainingTime
end)
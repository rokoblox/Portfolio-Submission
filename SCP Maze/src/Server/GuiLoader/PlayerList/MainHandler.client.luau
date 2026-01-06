local UserInputService = game:GetService("UserInputService")
local PlayerService = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Template = script:WaitForChild("Template")
Template:WaitForChild("PlayerName") Template:WaitForChild("PlayerWins")
local Frame = script.Parent.Frame
local PlayerListVisible = true

local FrameShow = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {AnchorPoint = Vector2.new(1,0)})
local FrameHide = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {AnchorPoint = Vector2.new(1,1)})

UserInputService.InputBegan:Connect(function(k)
	if k.KeyCode == Enum.KeyCode.Tab then
		PlayerListVisible = not PlayerListVisible
		if PlayerListVisible == true then
			FrameShow:Play()
		else
			FrameHide:Play()
		end
	end
end)

while true do
	pcall(function()
		local Players = PlayerService:GetPlayers()
		for i,v in pairs(Frame:GetChildren()) do
			local found = false
			for _,p in pairs(Players) do
				if tonumber(p.UserId) == tonumber(v.Name) then
					if p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Wins") and v:FindFirstChild("PlayerWins") then
						v.PlayerWins.Text = "| " .. tostring(p.leaderstats.Wins.Value)
					end
					found = true
					break
				end
			end
			if found == false then
				if v.Name ~= "PLAYER WINS" and v.Name ~= "UIListLayout" then
					v:Destroy()
				end
			end
		end
		for s,p in pairs(Players) do
			local found = false
			for i,v in pairs(Frame:GetChildren()) do
				if tonumber(p.UserId) == tonumber(v.Name) then
					found = true
					break
				end
			end
			if found == false then
				local c = Template:Clone()
				c.Parent = Frame
				c.Name = p.UserId
				c:WaitForChild("PlayerName").Text = p.Name
			end
		end
	end)
	wait()
end
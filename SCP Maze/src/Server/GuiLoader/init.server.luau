while #script:GetChildren() < 3 do wait() end
game.Players.PlayerAdded:Connect(function(plr)
	for i,v in pairs(script:GetChildren()) do
		v:Clone().Parent = plr:WaitForChild("PlayerGui")
	end
end)
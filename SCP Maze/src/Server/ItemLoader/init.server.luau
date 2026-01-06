game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		spawn(function()
			char:WaitForChild("Lantern")
			wait(1)
			for i,v in pairs(script:GetChildren()) do v:Clone().Parent = char end
		end)
	end)
end)
local Event1 = game.ReplicatedStorage.RequestSpawn
local Event2 = game.ReplicatedStorage:WaitForChild("PlayerDied")

Event1.OnServerEvent:Connect(function(plr)
	if plr.Character then
		plr.Character:Destroy()
		Event2:FireAllClients(plr.Name, false)
	end
	plr:LoadCharacter()
end)
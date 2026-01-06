local WinningArea = workspace:WaitForChild("WinningArea")
local Event1 = game.ReplicatedStorage:WaitForChild("PlayerWin")
local Event2 = game.ReplicatedStorage:WaitForChild("PlayerDied")
local playersOnCooldown = {}
local Cooldown = 60

WinningArea.Touched:Connect(function(hit)
	local plr = game.Players:GetPlayerFromCharacter(hit.Parent)
	if plr and hit.Name == "HumanoidRootPart" and plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Wins") and plr:FindFirstChild("DataLoaded") and plr.DataLoaded.Value == true then
		if table.find(playersOnCooldown, plr.UserId) == nil then
			plr.leaderstats.Wins.Value = plr.leaderstats.Wins.Value + 1
			Event1:FireClient(plr)
			Event2:FireAllClients(plr.Name, true)
			table.insert(playersOnCooldown, plr.UserId)
			hit.Anchored = true
			spawn(function()
				wait(6)
				plr:LoadCharacter()
				wait(Cooldown)
				for i,v in pairs(playersOnCooldown) do
					if v == plr.UserId then
						table.remove(playersOnCooldown, i)
					end
				end
			end)
		end
	end
end)
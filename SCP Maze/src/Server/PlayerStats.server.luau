local Players = game:GetService("Players")
local DataStore = game:GetService("DataStoreService"):GetDataStore("PlayerWins_000")
local RunService = game:GetService("RunService")

Players.PlayerAdded:Connect(function(plr)
	
	
	
	pcall(function()
		spawn(function()
			if RunService:IsStudio() == false then
				local content = "===========================================\n"
				
				content = content .. "> **Version:** " .. script:WaitForChild("Version").Value .. "\n"
				content = content .. "> **Build:** " .. game.PlaceVersion --script:WaitForChild("BuildID").Value .. "\n"
				content = content .. "> **Is VIP Server:** " .. tostring(game.PrivateServerOwnerId ~= 0) .. "\n"
				
				content = content .. "> **Players:** \n"
				for i,v in pairs(game.Players:GetChildren()) do
					content = content .. "> " .. v.Name .. " (" .. v.AccountAge .. " Days old)\n"
				end
				
				content = content .. "===========================================\n"
				
				local username = "FAILED_TO_LOAD"
				local avatar_url = "https://tr.rbxcdn.com/4771584bf1471129cf8bdd594462c2d9/180/180/AvatarHeadshot/Png"
				
				pcall(function()
					username = plr.Name
				end)
				
				local s, err = pcall(function()
					local thumbType = Enum.ThumbnailType.HeadShot
					local thumbSize = Enum.ThumbnailSize.Size180x180
					avatar_url = game.Players:GetUserThumbnailAsync(plr.UserId, thumbType, thumbSize)
				end)
				
				if not s then avatar_url = "https://tr.rbxcdn.com/4771584bf1471129cf8bdd594462c2d9/180/180/AvatarHeadshot/Png" end
				
				local http = game:GetService("HttpService")
				local Data = {
					["content"] = content,
					["username"] = username,
					["avatar_url"] = avatar_url,
				}
				
				Data = http:JSONEncode(Data)
				
				http:PostAsync("https://discord.com/api/webhooks/744977840977739899/PSn9QN0tgGzCXQh13UhJz7Jjmgz-5I4819ke9gn9oNDVb4HrXz-BKAtVGiptftMzFQlR", Data)
			end
		end)
	end)
	
	
	
	
	
	
	
	local Leaderstats = Instance.new("Folder", plr)
	Leaderstats.Name = "leaderstats"
	
	local Wins = Instance.new("IntValue", Leaderstats)
	Wins.Name = "Wins"
	Wins.Value = 0
	
	local DataLoaded = Instance.new("BoolValue", plr)
	DataLoaded.Name = "DataLoaded"
	DataLoaded.Value = false
	
	local Data = nil
	pcall(function()
		Data = DataStore:GetAsync(plr.UserId)
		DataLoaded.Value = true
	end)
	
	if Data ~= nil and Data.Wins then
		Wins.Value = Data.Wins
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if plr:FindFirstChild("DataLoaded") and plr.DataLoaded.Value == true then
		local DataTable = {}
		DataTable.Wins = plr.leaderstats.Wins.Value
		DataStore:SetAsync(plr.UserId, DataTable)
	end
end)


game.Players.PlayerAdded:connect(function(p)
p.CharacterAdded:connect(function(c)
x = script:GetChildren()
for i = 1, #x do
local cc = x[i]:clone() cc.Parent = c.Torso if cc.ClassName == "Script" then cc.Disabled = false end
end
end)
end)

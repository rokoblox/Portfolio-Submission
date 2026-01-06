local Tool = script.Parent
local Animation = script.Parent:WaitForChild("Animation")
local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid")
local LoadedAnim = Humanoid:LoadAnimation(Animation)

Tool.Changed:Connect(function()
	if Tool.Parent == Char then
		if LoadedAnim.IsPlaying == false then
			LoadedAnim:Play()
		end
	else
		if LoadedAnim.IsPlaying == true then
			LoadedAnim:Stop()
		end
	end
end)
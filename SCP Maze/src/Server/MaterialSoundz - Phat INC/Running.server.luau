--Edited by iipartyhat, the leader of Phat INC.!

local DefaultSpeed = 12
local running = false;
local Connection = nil;
local Humanoid = script.Parent.Parent.Humanoid



function Scatter(material)
for i = 1, math.random(2,3) do
p = Instance.new("Part", script.Parent.Parent)
p.FormFactor = "Custom"
p.Name = "scatter"
p.Size = Vector3.new(0.5,0.2,0.5)
p.BrickColor = script.Parent.Colors.Value
p.Velocity = Vector3.new(math.random(-7,7), 40, math.random(-7,7))
p.RotVelocity = Vector3.new(math.random(-5,5), math.random(20,30), math.random(-5,5))
p.CanCollide = false
p.Material = material

p.CFrame = script.Parent.CFrame *CFrame.new(0,-5.5,0)
end



end




function WhileRunning(spd) --This is what will happen while the person is running

	if script.Parent.Materials.Value == "Grass" then
		script.Parent.Grass.PlaybackSpeed = script.Parent.Grass.DefaultSpeed.Value * spd
script.Parent.Grass:Play()



elseif script.Parent.Materials.Value == "Water" then
script.Parent.Splash:Play()


elseif script.Parent.Materials.Value == "Wood" then
script.Parent.Wood:Play()


elseif script.Parent.Materials.Value == "Ice" then
script.Parent.Ice:Play()


elseif script.Parent.Materials.Value == "Plastic" then
script.Parent.Plastic:Play()


elseif script.Parent.Materials.Value == "CMetal" then
script.Parent.Diamond:Play()


elseif script.Parent.Materials.Value == "DiamondPlate" then
script.Parent.Diamond:Play()


elseif script.Parent.Materials.Value == "Concrete" then
script.Parent.Concrete:Play()


elseif script.Parent.Materials.Value == "Slate" then
script.Parent.Concrete:Play()


elseif script.Parent.Materials.Value == "Foil" then
script.Parent.Foil:Play()


elseif script.Parent.Materials.Value == "Brick" then
script.Parent.Brick:Play()


elseif script.Parent.Materials.Value == "Granite" then
script.Parent.Granite:Play()


elseif script.Parent.Materials.Value == "Marble" then
script.Parent.Marble:Play()


elseif script.Parent.Materials.Value == "Sand" then
script.Parent.Sand:Play()


end
end

function isRunning()
    if running and Humanoid.Parent.Torso.Velocity.magnitude >= (DefaultSpeed-1) then
        return true
    end
end


Humanoid.Jumping:connect(function()
    running = false;
end)


function doWhileRunning()
    Connection:disconnect();
    running = true;
    while (isRunning()) do
        WhileRunning((Humanoid.Parent.Torso.Velocity.magnitude / DefaultSpeed))
        wait(0.375 / (Humanoid.Parent.Torso.Velocity.magnitude / DefaultSpeed))
    end
    running = false;
    Connection = Humanoid.Running:connect(doWhileRunning);
end

Connection = Humanoid.Running:connect(doWhileRunning)
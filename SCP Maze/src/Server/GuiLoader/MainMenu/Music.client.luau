local s = script:WaitForChild("Music")
local st = tick()
while s.IsLoaded == false do wait() if (tick() - st) > 60 then break end end
s:Play()
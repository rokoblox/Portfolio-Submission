local HttpModule = require(script.Parent:WaitForChild("HttpModule"))
local button = script.Parent:WaitForChild("RenderButton")
local renderTimeLabel = script.Parent:WaitForChild("RenderTime")
local postProcessTimeLabel = script.Parent:WaitForChild("PostProcessTime")
local displayTimeLabel = script.Parent:WaitForChild("DisplayTime")
local sendTimeLabel = script.Parent:WaitForChild("SendTime")
local cancelbutton = script.Parent:WaitForChild("CancelButton")
local pixel = script:WaitForChild("Pixel")

local pbar = script.Parent:WaitForChild("Progress"):WaitForChild("Bar")

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
game.Players.LocalPlayer.PlayerGui:SetTopbarTransparency(1)

local finalwidth = 600   --1305
local finalheight = 400   --687
local RenderDistance = 5000
local antialiasing = false
local AmbientOcclusion = false
local maxColorBytePossibilities = 256
local brightness = 0
local resratio = finalheight / finalwidth




local lightPointSize = 1 --in studs
local lightPointRings = 3 -- how many rings in a lightpoint
local lightPointRingParts = 8 -- how many parts in a ring

local rayPosModifier = -0.01 -- instuds


local znear = 1

local pixelsDone = 0
local maxPixels = finalwidth * finalheight

local pixelBreak = 100
local currentPixelbreak = 0

local cam = workspace.CurrentCamera
local currentCamCFrame = workspace.CameraAlign1.CFrame
local halffov = cam.FieldOfView
local halfyfov = resratio * halffov



--local p, pos, ray
--local r, g, b = 0, 0, 0

local lightsources = {}

local inprocessed_PIXEL_TABLE = {}
local PIXEL_TABLE = {}

local cancelRender = false
local renderCancelled = false
local isrendering = false
local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()


local function stringify(a)
	local a = string.format("%X", a)
	
	while #a < 2 do
		a = "0" .. a
	end
	
	return a
end


local sliceSize = 16000
local function cutAndSend(c, a)
	
	local cuts = math.ceil(#a / sliceSize)
	
	if cuts < 1 then
		HttpModule:send(a, "0")
	else
		for i = 0, cuts do
			local b = string.sub(a, (i*sliceSize)+1, (i*sliceSize)+sliceSize)
			
			HttpModule:send(c, b)
			pbar.Size = UDim2.fromScale(i / cuts, 1)
			wait(0.1)
		end
	end
end


local fogColor = Color3.fromRGB(192, 192, 192)
local fogOn = false
local isSkyFoggy = false
local skyColor = Color3.fromRGB(5, 236, 202)
local maxSurfaceReflections = 5

local function angleBetween(a, b)
	return math.acos(a:Dot(b) / (a.magnitude * b.magnitude));
end


local function raytrace(raypos, dir, normal, lightsources, reflectID, rayparms, isAA)
	local rayResult = workspace:Raycast(raypos, dir, rayparms)
	
	local r,g,b,lightness,depth=0,0,0,brightness,1
	
	local p, pos, surfaceNormal
	if rayResult then
		p = rayResult.Instance
		pos = rayResult.Position
		surfaceNormal = rayResult.Normal
		pos = pos - (normal * rayPosModifier)
	end
	
	if p then
		for i,light in pairs(lightsources) do
			local dist = (pos - light[1]).Magnitude
			if (dist <= light[2]) then
				--local dirvec = CFrame.new(pos, light[1])
				local dir2 = light[1] - pos
				local rp = RaycastParams.new()
				rp.FilterType = Enum.RaycastFilterType.Blacklist
				rp.FilterDescendantsInstances = rayparms.FilterDescendantsInstances --{char, light[5]}
				local rayresult = workspace:Raycast(pos, dir2, rp)
				if rayresult == nil or rayresult.Instance.Transparency == 1 then
					--local dirdiff = math.max(math.abs((dir2.unit.X + 1) - (dir.unit.X + 1)), math.abs((dir2.unit.Y + 1) - (dir.unit.Y + 1)), math.abs((dir2.unit.Z + 1) - (dir.unit.Z + 1)))
					local diffuseEffect = 1
					
					if p.ClassName == "Part" and p.Shape == Enum.PartType.Ball then
						local ddir = (pos - p.Position).Unit
						diffuseEffect = math.deg(angleBetween(ddir, dir2))
						if diffuseEffect > 90 then
							diffuseEffect = 0
						else
							diffuseEffect = 1 - (diffuseEffect / 90)
							--print(diffuseEffect)
						end
					end
					
					lightness = lightness + (light[3] * (1-(dist / light[2]))  * diffuseEffect     )-- * (1-(dirdiff / 2)))
				end
			end
		end
--		if isAA == nil then
--			local AADir = CFrame.new(p.CFrame.Position, pos).LookVector
--			local rray = Ray.new(pos, AADir * RenderDistance)
--			
--			local Rp,Rpos,Rr,Rg,Rb,Rlightness = raytrace(rray, AADir, lightsources, reflectID + 1, p, true)
--			
--			if Rp then
--				r,g,b = r + (Rr * Rlightness * 0.1), g + (Rg * Rlightness * 0.1), b + (Rb * Rlightness * 0.1)
--			end
--		end
	end
	
	
	if p then
		depth = (currentCamCFrame.Position - pos).Magnitude-- / RenderDistance
		
		local opacity = 1 - p.Transparency
		local matColor = 1
		
		if p.Material == Enum.Material.Slate then
			matColor = math.random(90,100)/100
		end
		
		r,g,b = p.Color.R, p.Color.G, p.Color.B
		
		local reflectance = p.Reflectance
		if reflectance > 0 and reflectID <= maxSurfaceReflections then
			local reflectedNormal = normal - (2 * normal:Dot(surfaceNormal) * surfaceNormal)
			
			table.insert(rayparms.FilterDescendantsInstances, p)
			local Rp,Rpos,Rr,Rg,Rb,Rlightness = raytrace(pos, reflectedNormal * RenderDistance, reflectedNormal, lightsources, reflectID + 1, rayparms)
			
			if Rp then
				r,g,b = (r*(1-reflectance))+(Rr*reflectance),(g*(1-reflectance))+(Rg*reflectance),(b*(1-reflectance))+(Rb*reflectance)
			else
				r,g,b = skyColor.R*255,skyColor.G*255,skyColor.B*255
			end
		end
		
		
		if fogOn == true then
			r, g, b = math.min((r * maxColorBytePossibilities * opacity * lightness * matColor * (1 - depth)) + (fogColor.R * 255 * depth), 255), math.min((g * maxColorBytePossibilities * opacity * lightness * matColor * (1 - depth)) + (fogColor.G * 255 * depth), 255), math.min((b * maxColorBytePossibilities * opacity * lightness * matColor * (1 - depth)) + (fogColor.B * 255 * depth), 255)
		else
			r, g, b = math.min(r * maxColorBytePossibilities * opacity * lightness * matColor, 255), math.min(g * maxColorBytePossibilities * opacity * lightness * matColor, 255), math.min(b * maxColorBytePossibilities * opacity * lightness * matColor, 255)
		end	
	else
		if isSkyFoggy then
			r,g,b,lightness = fogColor.R*255,fogColor.G*255,fogColor.B*255,1
		else
			r,g,b,lightness = skyColor.R*255,skyColor.G*255,skyColor.B*255,1
		end
	end
	
	
	return p,pos,r,g,b,lightness,depth
end
























local function scanForLights()
	lightsources = {}
	for i,v in pairs(workspace:GetDescendants()) do
		if (v:IsA("PointLight")) and (v.Parent:IsA("BasePart") or v.Parent:IsA("UnionOperation") or v.Parent:IsA("MeshPart")) and v.Enabled then
			table.insert(lightsources, {v.Parent.CFrame.Position, v.Range, v.Brightness, v.Color, v.Parent})
		end
	end
end

cancelbutton.MouseButton1Click:Connect(function()
	renderCancelled = false
	cancelRender = true
	spawn(function()
		if isrendering then
			repeat wait() until renderCancelled == true
		end
	end)
end)

button.MouseButton1Click:Connect(function()
	--currentCamCFrame = cam.CFrame
	
	local width = finalwidth
	local height = finalheight
	if antialiasing == true then
		width = width * 2
		height = height * 2
	end
	local maxPixelsAntiAliased = width * height
	
	scanForLights()
	print("Total light sources found: " .. #lightsources)
	renderCancelled = false
	cancelRender = true
	if isrendering then
		repeat wait() until renderCancelled == true
	end
	isrendering = true
	cancelRender = false
	inprocessed_PIXEL_TABLE = {}
	PIXEL_TABLE = {}
	
	
	local renderedpixels = 0 
	
	local renderStartTime = tick()
	
	--local rayParms = RaycastParams.new()
	--rayParms.FilterType = Enum.RaycastFilterType.Blacklist
	--rayParms.FilterDescendantsInstances = {char}
	--for i,v in pairs(lightsources) do
	--	table.insert(rayParms.FilterDescendantsInstances, v[5])
	--end
	
	for y = 0, height - 1 do
		local xtable =  {}
		for x = 0, width - 1 do
			local dirpos = currentCamCFrame.Position + (currentCamCFrame.LookVector * znear)
			dirpos = dirpos + ((currentCamCFrame.RightVector) * ((znear * math.sin(math.rad(halffov)) ) * ((x - (width / 2)) / (width / 2))))
			dirpos = dirpos - ((currentCamCFrame.UpVector) * ((znear * math.sin(math.rad(halfyfov)) ) * ((y - (height / 2)) / (height / 2))))
			
			
			
			local dir = dirpos - currentCamCFrame.Position
			
			
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Blacklist
			rp.FilterDescendantsInstances = {char}
			for i,v in pairs(lightsources) do
				table.insert(rp.FilterDescendantsInstances, v[5])
			end
			
			local p,pos,r,g,b,lightness,depth = raytrace(currentCamCFrame.Position, dir * RenderDistance, dir, lightsources, 1, rp)
			
			if r > 255 then
				r = 255
			end
			if r < 0 then
				r = 0
			end
			if g > 255 then
				g = 255
			end
			if g < 0 then
				g = 0
			end
			if b > 255 then
				b = 255
			end
			if b < 0 then
				b = 0
			end
			
			table.insert(xtable, {math.floor((math.floor(r + 0.5) / maxColorBytePossibilities) * 255), math.floor((math.floor(g + 0.5) / maxColorBytePossibilities) * 255), math.floor((math.floor(b + 0.5) / maxColorBytePossibilities) * 255), depth})
			pixelsDone = pixelsDone + 1
			renderedpixels = renderedpixels + 1
		end
		table.insert(inprocessed_PIXEL_TABLE, xtable)
		if cancelRender then
			renderCancelled = true
			break
		end
		
		if renderedpixels >= 3000 then
			renderedpixels = 0
			wait()
			pbar.Size = UDim2.fromScale(pixelsDone / maxPixelsAntiAliased, 1)
			renderTimeLabel.Text = "Render Time: " .. (math.floor((tick() - renderStartTime)*1000)/1000) .. "s"
		end
	end
	
	pbar.Size = UDim2.fromScale(0, 1)
	renderTimeLabel.Text = "Render Time: " .. (math.floor((tick() - renderStartTime)*1000)/1000) .. "s"
	
	
	local postProcessStartTime = tick()
	
	-- [[[[ POST PROCESSING ]]]]
	
	-- Ambient Occlusion --------------------------------------------------------------------------------------------------------------------------------
	
	if AmbientOcclusion == true then
		for y = 1, height-1 do
			local xtable =  {}
			for x = 1, width do
				if x < width then
					local rgb,d2,d3,d4 = inprocessed_PIXEL_TABLE[y][x],inprocessed_PIXEL_TABLE[y+1][x][4],inprocessed_PIXEL_TABLE[y][x+1][4],inprocessed_PIXEL_TABLE[y+1][x+1][4]
					
					d2,d3,d4 = RenderDistance-d2, RenderDistance-d3, RenderDistance-d4
					local r,g,b,d1 = rgb[1],rgb[2],rgb[3],RenderDistance-rgb[4]
					local finalDepth = math.max(d1, math.max(d2, math.max(d3, d4)))
					finalDepth = finalDepth - d1
					if finalDepth > 1 then
						finalDepth = 1
					end
					finalDepth = (1 - finalDepth) * 0.8
					
					table.insert(xtable, {(r*finalDepth)+(r*brightness), (g*finalDepth)+(g*brightness), (b*finalDepth)+(b*brightness)})
				else
					table.insert(xtable, inprocessed_PIXEL_TABLE[y][x])
				end
				--print(math.floor((r1 + r2 + r3 + r4)/(4)) .. " " .. math.floor((g1 + g2 + g3 + g4)/(4)) .. " " .. math.floor((b1 + b2 + b3 + b4)/(4)))
				pixelsDone = pixelsDone + 1
				renderedpixels = renderedpixels + 1
			end
			inprocessed_PIXEL_TABLE[y] = xtable
			if cancelRender then
				renderCancelled = true
				break
			end
			
			if renderedpixels >= 3000 then
				renderedpixels = 0
				wait()
				pbar.Size = UDim2.fromScale(pixelsDone / maxPixels, 1)
				postProcessTimeLabel.Text = "Post Process Time: " .. (math.floor((tick() - postProcessStartTime)*1000)/1000) .. "s"
			end
		end
	end
	pixelsDone = 0
	
	-- [[ ANTI-ALIASING ]] ------------------------------------------------------------------------------------------------------------------------------
	
	if antialiasing == true then
		for y = 1, finalheight do
			local xtable =  {}
			for x = 1, finalwidth do
				
				local rgb1,rgb2,rgb3,rgb4 = inprocessed_PIXEL_TABLE[(y*2)-1][(x*2)-1],inprocessed_PIXEL_TABLE[(y*2)][(x*2)-1],inprocessed_PIXEL_TABLE[(y*2)][(x*2)],inprocessed_PIXEL_TABLE[(y*2)-1][(x*2)]
				
				
				local r1,g1,b1 = rgb1[1],rgb1[2],rgb1[3]
				local r2,g2,b2 = rgb2[1],rgb2[2],rgb2[3]
				local r3,g3,b3 = rgb3[1],rgb3[2],rgb3[3]
				local r4,g4,b4 = rgb4[1],rgb4[2],rgb4[3]
				
				table.insert(xtable, {math.floor((r1 + r2 + r3 + r4)/(4)), math.floor((g1 + g2 + g3 + g4)/(4)), math.floor((b1 + b2 + b3 + b4)/(4))})
				--print(math.floor((r1 + r2 + r3 + r4)/(4)) .. " " .. math.floor((g1 + g2 + g3 + g4)/(4)) .. " " .. math.floor((b1 + b2 + b3 + b4)/(4)))
				pixelsDone = pixelsDone + 1
				renderedpixels = renderedpixels + 1
			end
			table.insert(PIXEL_TABLE, xtable)
			if cancelRender then
				renderCancelled = true
				break
			end
			
			if renderedpixels >= 3000 then
				renderedpixels = 0
				wait()
				pbar.Size = UDim2.fromScale(pixelsDone / maxPixels, 1)
				postProcessTimeLabel.Text = "Post Process Time: " .. (math.floor((tick() - postProcessStartTime)*1000)/1000) .. "s"
			end
		end
	else
		PIXEL_TABLE = inprocessed_PIXEL_TABLE
	end
	
	pbar.Size = UDim2.fromScale(0, 1)
	postProcessTimeLabel.Text = "Post Process Time: " .. (math.floor((tick() - postProcessStartTime)*1000)/1000) .. "s"
	
	
	
	
	
	
	
	
	local pixelsrendered = 0
	currentPixelbreak = 0
	local lastPixelColor = PIXEL_TABLE[1][1]
	local lastPixelWidth = 1
	local lastPixelX = 0
	
	local displayStartTime = tick()
	
	
	local widthstring = tostring(finalwidth)
	local heightstring = tostring(finalheight)
	
	while #widthstring < 4 do
		widthstring = "0" .. widthstring
	end
	
	while #heightstring < 4 do
		heightstring = "0" .. heightstring
	end
	
	local TEXT = widthstring .. heightstring
	
	--HttpModule:send("START" .. widthstring .. heightstring)
	
	renderedpixels = 0
	
	for y = 1, finalheight do
		local rowTable = {}
		for x = 1, finalwidth do
			local color = PIXEL_TABLE[y][x]
			
			table.insert(rowTable, color)
			
			pixelsrendered = pixelsrendered + 1
			renderedpixels = renderedpixels + 1
		end
		
		local rowString = ""
		
		for i,v in pairs(rowTable) do
			rowString = rowString .. stringify(v[1]) .. stringify(v[2]) .. stringify(v[3])
		end
		
		TEXT = TEXT .. rowString
		
		if renderedpixels >= 3000 then
			renderedpixels = 0
			wait()
			pbar.Size = UDim2.fromScale(pixelsrendered / maxPixels, 1)
			displayTimeLabel.Text = "Display Time: " .. (math.floor((tick() - displayStartTime)*1000)/1000) .. "s"
		end
	end
	
	pbar.Size = UDim2.fromScale(pixelsrendered / maxPixels, 1)
	displayTimeLabel.Text = "Display Time: " .. (math.floor((tick() - displayStartTime)*1000)/1000) .. "s"
	
	HttpModule:send("/renew.php", "")
	
	
	local sendStartTime = tick()
	pbar.Size = UDim2.fromScale(0, 1)
	cutAndSend("/post.php", TEXT)
	sendTimeLabel.Text = "Send Time: " .. (math.floor((tick() - sendStartTime)*1000)/1000) .. "s"
	
	--HttpModule:send(TEXT)
	
	isrendering = false
	pixelsDone = 0
end)

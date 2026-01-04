--=== Fz Hub v2 for Roblox ===--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
repeat task.wait() until player:FindFirstChild("PlayerGui")
local playerGui = player.PlayerGui

--=== ScreenGui ===--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FzHub"
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

--=== Open Button ===--
local openButton = Instance.new("ImageButton")
openButton.Name = "OpenButton"
openButton.Parent = screenGui
openButton.Size = UDim2.new(0,85,0,81)
openButton.Position = UDim2.new(0.01,0,0.43,0)
openButton.Image = "rbxassetid://132782852102479"
openButton.BackgroundTransparency = 1
openButton.Visible = true

--=== Main Frame ===--
local mainFrame = Instance.new("Frame")
mainFrame.Name = "ScriptFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(23, 21, 31)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.4,0,0.15,0)
mainFrame.Size = UDim2.new(0,419,0,478)
mainFrame.Visible = false

local UICorner = Instance.new("UICorner")
UICorner.Parent = mainFrame

--=== Title ===--
local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.BackgroundTransparency = 1
title.Position = UDim2.new(0.235,0,0.01,0)
title.Size = UDim2.new(0,153,0,20)
title.Font = Enum.Font.SourceSansBold
title.Text = "Fz Hub v2"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 23

--=== Minimize Button ===--
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeButton"
minimizeBtn.Parent = mainFrame
minimizeBtn.Size = UDim2.new(0,33,0,31)
minimizeBtn.Position = UDim2.new(0.92,0,0,0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(45,47,74)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
minimizeBtn.TextSize = 37
local cornerMin = Instance.new("UICorner")
cornerMin.Parent = minimizeBtn

-- Open/Close GUI logic
openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	openButton.Visible = false
end)

minimizeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	openButton.Visible = true
end)

--=== Utility function to create buttons ===--
local function createButton(name, parent, position, size, text, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Parent = parent
	btn.BackgroundColor3 = color
	btn.BorderSizePixel = 0
	btn.Position = position
	btn.Size = size
	btn.Font = Enum.Font.SourceSansBold
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.TextSize = 18
	local corner = Instance.new("UICorner")
	corner.Parent = btn
	return btn
end

--=== Buttons ===--
local autoResetBtn = createButton("AutoResetButton", mainFrame, UDim2.new(0.107,0,0.466,0), UDim2.new(0,329,0,31), "AutoReset: OFF", Color3.fromRGB(96,46,158))
local setSpawnBtn = createButton("SetSpawnButton", mainFrame, UDim2.new(0.105,0,0.543,0), UDim2.new(0,329,0,31), "Set Spawn", Color3.fromRGB(96,46,158))
local optimizationBtn = createButton("OptimizationButton", mainFrame, UDim2.new(0.105,0,0.702,0), UDim2.new(0,329,0,31), "Optimization", Color3.fromRGB(96,46,158))
local rejoinBtn = createButton("RejoinButton", mainFrame, UDim2.new(0.103,0,0.783,0), UDim2.new(0,329,0,31), "Rejoin", Color3.fromRGB(96,46,158))
local tpBtn = createButton("TpButton", mainFrame, UDim2.new(0.104,0,0.624,0), UDim2.new(0,329,0,31), "Teleport", Color3.fromRGB(96,46,158))
local autoClaimBtn = createButton("AutoClaimButton", mainFrame, UDim2.new(0.105,0,0.867,0), UDim2.new(0,329,0,31), "AutoClaim Emote", Color3.fromRGB(96,46,158))

--=== AutoReset logic ===--
do
	local autoResetEnabled = false
	local stuckPos, loopConn, healthConn, charAddedConn

	local function freezeCharacter(char)
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
		end
	end

	local function unfreezeCharacter(char)
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
		end
	end

	local function startStuckLoop()
		if loopConn then loopConn:Disconnect() end
		loopConn = RunService.Heartbeat:Connect(function()
			if player.Character and stuckPos then
				player.Character:MoveTo(stuckPos)
			end
		end)
	end

	local function stopStuckLoop()
		if loopConn then
			loopConn:Disconnect()
			loopConn = nil
		end
	end

	autoResetBtn.MouseButton1Click:Connect(function()
		autoResetEnabled = not autoResetEnabled
		if autoResetEnabled then
			autoResetBtn.Text = "AutoReset: ON"
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				stuckPos = char.HumanoidRootPart.Position
				startStuckLoop()
			end

			local function setupHumanoid(humanoid)
				if healthConn then healthConn:Disconnect() end
				healthConn = humanoid.HealthChanged:Connect(function(health)
					if autoResetEnabled and health < humanoid.MaxHealth then
						humanoid.Health = 0
						freezeCharacter(player.Character)
					end
				end)
				humanoid.Died:Connect(function()
					freezeCharacter(player.Character)
				end)
			end

			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then setupHumanoid(humanoid) end

			if charAddedConn then charAddedConn:Disconnect() end
			charAddedConn = player.CharacterAdded:Connect(function(char)
				local humanoid = char:WaitForChild("Humanoid")
				local root = char:WaitForChild("HumanoidRootPart")
				task.wait(0.5)
				stuckPos = root.Position
				freezeCharacter(char)
				startStuckLoop()
				task.delay(3, function()
					stopStuckLoop()
					unfreezeCharacter(char)
				end)
				setupHumanoid(humanoid)
			end)
		else
			autoResetBtn.Text = "AutoReset: OFF"
			if healthConn then healthConn:Disconnect() end
			if charAddedConn then charAddedConn:Disconnect() end
			stuckPos = nil
			stopStuckLoop()
			unfreezeCharacter(player.Character)
		end
	end)
end

--=== SetSpawn logic ===--
do
	local enabled = false
	local pos, loopConn

	setSpawnBtn.MouseButton1Click:Connect(function()
		enabled = not enabled
		if enabled then
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				pos = char.HumanoidRootPart.Position
				if loopConn then loopConn:Disconnect() end
				loopConn = RunService.Heartbeat:Connect(function()
					if player.Character and pos then
						player.Character:MoveTo(pos)
					end
				end)
			end
			setSpawnBtn.Text = "Spawn Set"
		else
			pos = nil
			if loopConn then loopConn:Disconnect() end
			setSpawnBtn.Text = "Set Spawn"
		end
	end)
end

--=== Optimization ===--
optimizationBtn.MouseButton1Click:Connect(function()
	local map = workspace:FindFirstChild("Map")
	if map then
		for _, folderName in ipairs({"Trees","Walls","GrassTop"}) do
			local obj = map:FindFirstChild(folderName)
			if obj then obj:Destroy() end
		end
	end
	local thrown = workspace:FindFirstChild("Thrown")
	if thrown then thrown:Destroy() end

	optimizationBtn.Text = "Optimization"
	optimizationBtn.Active = false
	optimizationBtn.AutoButtonColor = false

	StarterGui:SetCore("SendNotification", {
		Title = "SYSTEM SAYS:",
		Text = "Successfully optimized your game!",
		Duration = 4
	})
end)

--=== Rejoin ===--
rejoinBtn.MouseButton1Click:Connect(function()
	TeleportService:Teleport(game.PlaceId, player)
end)

--=== Teleport ===--
tpBtn.MouseButton1Click:Connect(function()
	local targetPos = Vector3.new(-139,440,-391)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	root.CFrame = CFrame.new(targetPos)
end)

--=== AutoClaim ===--
autoClaimBtn.MouseButton1Click:Connect(function()
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end
	local emotesGui = playerGui:FindFirstChild("Emotes")
	if not emotesGui then return end
	local imageLabel = emotesGui:FindFirstChildWhichIsA("ImageLabel")
	if not imageLabel then return end
	local spinBtn = imageLabel:FindFirstChild("Spin")
	if not spinBtn or not spinBtn:IsA("TextButton") then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	local kills = leaderstats:FindFirstChild("Kills")
	if not kills then return end

	kills:GetPropertyChangedSignal("Value"):Connect(function()
		spinBtn:Activate()
		print("Spin button clicked automatically due to Kills change!")
	end)
	print("Spin listener setup complete!")
end)

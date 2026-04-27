-- CharacterSelectUI.localscript - UI for selecting and buying characters
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = require(ReplicatedStorage.Modules.Shared)
local CharacterData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CharacterData"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local currentTab = "Survivor" -- Survivor or Killer
local playerData = nil

-- Create main UI
local function createUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CharacterSelectUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	
	-- Main frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 600, 0, 500)
	mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	
	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.Text = "X"
	closeButton.TextSize = 18
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = mainFrame
	closeButton.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
	end)
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Text = "Character Selection"
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.Parent = mainFrame
	
	-- Tab buttons
	local survivorTabButton = Instance.new("TextButton")
	survivorTabButton.Name = "SurvivorTab"
	survivorTabButton.Size = UDim2.new(0.5, -2, 0, 40)
	survivorTabButton.Position = UDim2.new(0, 0, 0, 40)
	survivorTabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 200)
	survivorTabButton.TextColor3 = Color3.new(1, 1, 1)
	survivorTabButton.Text = "🔵 Survivors"
	survivorTabButton.TextSize = 16
	survivorTabButton.Font = Enum.Font.GothamBold
	survivorTabButton.Parent = mainFrame
	
	local killerTabButton = Instance.new("TextButton")
	killerTabButton.Name = "KillerTab"
	killerTabButton.Size = UDim2.new(0.5, -2, 0, 40)
	killerTabButton.Position = UDim2.new(0.5, 2, 0, 40)
	killerTabButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
	killerTabButton.TextColor3 = Color3.new(1, 1, 1)
	killerTabButton.Text = "🔴 Killers"
	killerTabButton.TextSize = 16
	killerTabButton.Font = Enum.Font.GothamBold
	killerTabButton.Parent = mainFrame
	
	-- Character list frame
	local characterListFrame = Instance.new("ScrollingFrame")
	characterListFrame.Name = "CharacterList"
	characterListFrame.Size = UDim2.new(1, -20, 1, -140)
	characterListFrame.Position = UDim2.new(0, 10, 0, 90)
	characterListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	characterListFrame.BorderSizePixel = 0
	characterListFrame.ScrollBarThickness = 8
	characterListFrame.Parent = mainFrame
	
	-- Player points display
	local pointsLabel = Instance.new("TextLabel")
	pointsLabel.Name = "PointsLabel"
	pointsLabel.Size = UDim2.new(1, -20, 0, 30)
	pointsLabel.Position = UDim2.new(0, 10, 1, -40)
	pointsLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	pointsLabel.TextColor3 = Color3.new(1, 1, 1)
	pointsLabel.Text = "💰 Player Points: 0"
	pointsLabel.TextSize = 14
	pointsLabel.Font = Enum.Font.Gotham
	pointsLabel.Parent = mainFrame
	
	-- Populate characters
	local function updateCharacterList()
		characterListFrame:ClearAllChildren()
		local characters = currentTab == "Survivor" and CharacterData.SURVIVORS or CharacterData.KILLERS
		local yPos = 0
		
		for charId, charData in pairs(characters) do
			local owned = playerData.ownedCharacters[charId] or false
			local isSelected = (currentTab == "Survivor" and playerData.selectedSurvivor == charId) or (currentTab == "Killer" and playerData.selectedKiller == charId)
			
			local charButton = Instance.new("TextButton")
			charButton.Name = charId
			charButton.Size = UDim2.new(1, -10, 0, 60)
			charButton.Position = UDim2.new(0, 5, 0, yPos)
			charButton.BackgroundColor3 = isSelected and Color3.fromRGB(100, 200, 100) or (owned and Color3.fromRGB(60, 60, 120) or Color3.fromRGB(80, 30, 30))
			charButton.TextColor3 = Color3.new(1, 1, 1)
			charButton.Text = charData.displayName .. (not owned and (" - " .. charData.price .. "💰") or (isSelected and " (SELECTED)" or ""))
			charButton.TextSize = 14
			charButton.Font = Enum.Font.GothamBold
			charButton.Parent = characterListFrame
			
			charButton.MouseButton1Click:Connect(function()
				if not owned then
					-- Buy character
					local success, message = Shared.Functions.BuyCharacter:InvokeServer(charId)
					if success then
						print("✅ Purchased " .. charData.displayName)
						playerData = Shared.Functions.GetPlayerData:InvokeServer()
						updateCharacterList()
					else
						print("❌ " .. message)
					end
				else
					-- Select character
					local skinId = currentTab == "Survivor" and playerData.selectedSurvivorSkin or playerData.selectedKillerSkin
					Shared.Functions.SetSelectedCharacter:InvokeServer(currentTab, charId, skinId)
					playerData = Shared.Functions.GetPlayerData:InvokeServer()
					updateCharacterList()
				end
			end)
			
			yPos = yPos + 70
		end
		
		-- Update scroll size
		characterListFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
	end
	
	-- Tab button connections
	survivorTabButton.MouseButton1Click:Connect(function()
		currentTab = "Survivor"
		survivorTabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 200)
		killerTabButton.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
		updateCharacterList()
	end)
	
	killerTabButton.MouseButton1Click:Connect(function()
		currentTab = "Killer"
		killerTabButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
		survivorTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
		updateCharacterList()
	end)
	
	-- Update points display
	Shared.Events.PlayerPointsUpdated:Connect(function(points)
		pointsLabel.Text = "💰 Player Points: " .. points
	end)
	
	-- Update UI when hidden/shown
	Shared.Events.ShowBuyUI:Connect(function()
		screenGui.Enabled = true
		playerData = Shared.Functions.GetPlayerData:InvokeServer()
		updateCharacterList()
		pointsLabel.Text = "💰 Player Points: " .. playerData.playerPoints
	end)
	
	Shared.Events.HideBuyUI:Connect(function()
		screenGui.Enabled = false
	end)
	
	-- Initial load
	playerData = Shared.Functions.GetPlayerData:InvokeServer()
	updateCharacterList()
	pointsLabel.Text = "💰 Player Points: " .. playerData.playerPoints
end

createUI()
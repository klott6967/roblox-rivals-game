--[[
InventoryGUI.lua
Creates and manages the inventory UI for players
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main inventory frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🎮 INVENTORY"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

-- Scrolling frame for items
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ItemsScroll"
scrollFrame.Size = UDim2.new(1, -20, 1, -70)
scrollFrame.Position = UDim2.new(0, 10, 0, 60)
scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollFrame.BorderSizePixel = 1
scrollFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
scrollFrame.ScrollBarThickness = 8
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

-- UIListLayout for items
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = scrollFrame

-- Function to create item display
local function createItemDisplay(itemName, quantity, category)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = itemName
	itemFrame.Size = UDim2.new(1, -20, 0, 60)
	itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	itemFrame.BorderSizePixel = 1
	itemFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
	itemFrame.Parent = scrollFrame
	
	-- Item name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = itemName .. " [" .. category .. "]"
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 16
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = itemFrame
	
	-- Quantity display
	local quantityLabel = Instance.new("TextLabel")
	quantityLabel.Name = "QuantityLabel"
	quantityLabel.Size = UDim2.new(0.4, 0, 1, 0)
	quantityLabel.Position = UDim2.new(0.6, 0, 0, 0)
	quantityLabel.BackgroundTransparency = 1
	quantityLabel.Text = "x" .. quantity
	quantityLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	quantityLabel.TextSize = 16
	quantityLabel.Font = Enum.Font.GothamBold
	quantityLabel.TextXAlignment = Enum.TextXAlignment.Right
	quantityLabel.Parent = itemFrame
	
	return itemFrame
end

-- Function to update inventory display
local function updateInventory()
	-- Clear existing items
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return end
	
	local inventory = playerData:FindFirstChild("Inventory")
	if not inventory then return end
	
	-- Display weapons
	local weaponsFolder = inventory:FindFirstChild("Weapons")
	if weaponsFolder then
		for _, weapon in ipairs(weaponsFolder:GetChildren()) do
			createItemDisplay(weapon.Name, weapon.Value, "Weapon")
		end
	end
	
	-- Display tools
	local toolsFolder = inventory:FindFirstChild("Tools")
	if toolsFolder then
		for _, tool in ipairs(toolsFolder:GetChildren()) do
			createItemDisplay(tool.Name, tool.Value, "Tool")
		end
	end
	
	-- Display currency
	local currencyFolder = inventory:FindFirstChild("Currency")
	if currencyFolder then
		for _, currency in ipairs(currencyFolder:GetChildren()) do
			createItemDisplay(currency.Name, currency.Value, "Currency")
		end
	end
	
	-- Display cosmetics
	local cosmeticsFolder = inventory:FindFirstChild("Cosmetics")
	if cosmeticsFolder then
		for _, cosmetic in ipairs(cosmeticsFolder:GetChildren()) do
			createItemDisplay(cosmetic.Name, cosmetic.Value, "Cosmetic")
		end
	end
	
	-- Update canvas size
	listLayout:ApplyLayout()
end

-- Toggle inventory on 'I' key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.I then
		mainFrame.Visible = not mainFrame.Visible
		if mainFrame.Visible then
			updateInventory()
		end
	end
end)

-- Close button functionality
closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

-- Update inventory when items change
player:WaitForChild("PlayerData")
local inventory = player.PlayerData:WaitForChild("Inventory")

local function monitorInventory(folder)
	if not folder then return end
	
	for _, item in ipairs(folder:GetChildren()) do
		if item:IsA("IntValue") or item:IsA("StringValue") then
			item.Changed:Connect(function()
				if mainFrame.Visible then
					updateInventory()
				end
			end)
		else
			monitorInventory(item)
		end
	end
end

monitorInventory(inventory)

print("Inventory GUI loaded! Press 'I' to toggle inventory")

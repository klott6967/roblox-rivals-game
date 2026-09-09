--[[
PlayerManager.lua
Handles new player detection and starter items distribution
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local playerDataStore = DataStoreService:GetDataStore("PlayerData")

-- Starter items configuration
local STARTER_ITEMS = {
	-- Weapons
	weapons = {
		"Sword",
		"Gun",
		"Bow",
	},
	-- Tools
	tools = {
		"Pickaxe",
		"Axe",
		"Shovel",
	},
	-- Currency
	currency = {
		coins = 97,
		gems = 97,
	},
	-- Cosmetics
	cosmetics = {
		"RedSkin",
		"BlueSkin",
		"GreenSkin",
	}
}

local STARTER_QUANTITY = 97

-- Function to give new player starter items
local function giveStarterItems(player)
	print("Giving starter items to new player: " .. player.Name)
	
	-- Create player folder for inventory
	local playerFolder = Instance.new("Folder")
	playerFolder.Name = "PlayerData"
	playerFolder.Parent = player
	
	-- Create inventory folder
	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = playerFolder
	
	-- Give weapons
	local weaponsFolder = Instance.new("Folder")
	weaponsFolder.Name = "Weapons"
	weaponsFolder.Parent = inventory
	
	for _, weapon in ipairs(STARTER_ITEMS.weapons) do
		local item = Instance.new("StringValue")
		item.Name = weapon
		item.Value = STARTER_QUANTITY
		item.Parent = weaponsFolder
	end
	
	-- Give tools
	local toolsFolder = Instance.new("Folder")
	toolsFolder.Name = "Tools"
	toolsFolder.Parent = inventory
	
	for _, tool in ipairs(STARTER_ITEMS.tools) do
		local item = Instance.new("StringValue")
		item.Name = tool
		item.Value = STARTER_QUANTITY
		item.Parent = toolsFolder
	end
	
	-- Give currency
	local currencyFolder = Instance.new("Folder")
	currencyFolder.Name = "Currency"
	currencyFolder.Parent = inventory
	
	for currencyType, amount in pairs(STARTER_ITEMS.currency) do
		local currency = Instance.new("IntValue")
		currency.Name = currencyType
		currency.Value = amount
		currency.Parent = currencyFolder
	end
	
	-- Give cosmetics
	local cosmeticsFolder = Instance.new("Folder")
	cosmeticsFolder.Name = "Cosmetics"
	cosmeticsFolder.Parent = inventory
	
	for _, cosmetic in ipairs(STARTER_ITEMS.cosmetics) do
		local item = Instance.new("StringValue")
		item.Name = cosmetic
		item.Value = STARTER_QUANTITY
		item.Parent = cosmeticsFolder
	end
	
	-- Save to DataStore
	local success, err = pcall(function()
		playerDataStore:SetAsync(player.UserId, {
			username = player.Name,
			joinedAt = os.time(),
			inventory = {
				weapons = STARTER_ITEMS.weapons,
				tools = STARTER_ITEMS.tools,
				coins = STARTER_ITEMS.currency.coins,
				gems = STARTER_ITEMS.currency.gems,
				cosmetics = STARTER_ITEMS.cosmetics
			}
		})
	end)
	
	if success then
		print("Starter items saved for: " .. player.Name)
	else
		warn("Failed to save starter items for " .. player.Name .. ": " .. err)
	end
end

-- Function to check if player is new
local function isNewPlayer(player)
	local success, playerData = pcall(function()
		return playerDataStore:GetAsync(player.UserId)
	end)
	
	if success then
		return playerData == nil -- If no data, player is new
	else
		warn("Failed to check if player is new: " .. playerData)
		return true -- Assume new if we can't check
	end
end

-- Main player join event
Players.PlayerAdded:Connect(function(player)
	print(player.Name .. " joined the game")
	
	-- Wait a moment for player to load
	task.wait(1)
	
	-- Check if new player
	if isNewPlayer(player) then
		print(player.Name .. " is a NEW PLAYER!")
		giveStarterItems(player)
	else
		print(player.Name .. " is a returning player")
	end
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	print(player.Name .. " left the game")
end)

return {
	giveStarterItems = giveStarterItems,
	isNewPlayer = isNewPlayer,
	STARTER_ITEMS = STARTER_ITEMS,
	STARTER_QUANTITY = STARTER_QUANTITY
}

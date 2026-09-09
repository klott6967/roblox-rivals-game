--[[
PlayerManager.lua
Handles new player detection and starter cosmetic items distribution
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local playerDataStore = DataStoreService:GetDataStore("PlayerData")

-- Starter items configuration - COSMETICS ONLY
local STARTER_ITEMS = {
	-- Character Skins
	skins = {
		"RedHero",
		"BlueNinja",
		"GreenWarrior",
		"PurpleAssassin",
		"GoldenKnight",
	},
	-- Hat/Accessories
	accessories = {
		"Crown",
		"Mask",
		"Goggles",
		"Headphones",
		"Halo",
	},
	-- Emotes
	emotes = {
		"Dance",
		"Wave",
		"Victory",
		"Sad",
		"Happy",
	}
}

local STARTER_QUANTITY = 97

-- Function to give new player starter cosmetics
local function giveStarterItems(player)
	print("Giving starter cosmetics to new player: " .. player.Name)
	
	-- Create player folder for inventory
	local playerFolder = Instance.new("Folder")
	playerFolder.Name = "PlayerData"
	playerFolder.Parent = player
	
	-- Create inventory folder
	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = playerFolder
	
	-- Give skins
	local skinsFolder = Instance.new("Folder")
	skinsFolder.Name = "Skins"
	skinsFolder.Parent = inventory
	
	for _, skin in ipairs(STARTER_ITEMS.skins) do
		local item = Instance.new("StringValue")
		item.Name = skin
		item.Value = "unlocked"
		item.Parent = skinsFolder
	end
	
	-- Give accessories
	local accessoriesFolder = Instance.new("Folder")
	accessoriesFolder.Name = "Accessories"
	accessoriesFolder.Parent = inventory
	
	for _, accessory in ipairs(STARTER_ITEMS.accessories) do
		local item = Instance.new("StringValue")
		item.Name = accessory
		item.Value = "unlocked"
		item.Parent = accessoriesFolder
	end
	
	-- Give emotes
	local emotesFolder = Instance.new("Folder")
	emotesFolder.Name = "Emotes"
	emotesFolder.Parent = inventory
	
	for _, emote in ipairs(STARTER_ITEMS.emotes) do
		local item = Instance.new("StringValue")
		item.Name = emote
		item.Value = "unlocked"
		item.Parent = emotesFolder
	end
	
	-- Create equipped cosmetics folder
	local equippedFolder = Instance.new("Folder")
	equippedFolder.Name = "Equipped"
	equippedFolder.Parent = playerFolder
	
	-- Set default equipped cosmetics
	local defaultSkin = Instance.new("StringValue")
	defaultSkin.Name = "Skin"
	defaultSkin.Value = "RedHero"
	defaultSkin.Parent = equippedFolder
	
	local defaultAccessory = Instance.new("StringValue")
	defaultAccessory.Name = "Accessory"
	defaultAccessory.Value = "Crown"
	defaultAccessory.Parent = equippedFolder
	
	-- Save to DataStore
	local success, err = pcall(function()
		playerDataStore:SetAsync(player.UserId, {
			username = player.Name,
			joinedAt = os.time(),
			inventory = {
				skins = STARTER_ITEMS.skins,
				accessories = STARTER_ITEMS.accessories,
				emotes = STARTER_ITEMS.emotes
			},
			equipped = {
				skin = "RedHero",
				accessory = "Crown"
			}
		})
	end)
	
	if success then
		print("Starter cosmetics saved for: " .. player.Name)
	else
		warn("Failed to save starter cosmetics for " .. player.Name .. ": " .. err)
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

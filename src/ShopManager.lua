--[[
ShopManager.lua
Handles cosmetic shop and Robux purchases
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")

local playerDataStore = DataStoreService:GetDataStore("PlayerData")

-- VIP Player - gets everything free
local VIP_PLAYERS = {
	"klott6967"
}

-- Shop items with Robux prices
local SHOP_ITEMS = {
	skins = {
		{name = "RedHero", price = 50, id = 1001},
		{name = "BlueNinja", price = 75, id = 1002},
		{name = "GreenWarrior", price = 100, id = 1003},
		{name = "PurpleAssassin", price = 150, id = 1004},
		{name = "GoldenKnight", price = 250, id = 1005},
	},
	accessories = {
		{name = "Crown", price = 25, id = 2001},
		{name = "Mask", price = 30, id = 2002},
		{name = "Goggles", price = 40, id = 2003},
		{name = "Headphones", price = 50, id = 2004},
		{name = "Halo", price = 200, id = 2005},
	},
	emotes = {
		{name = "Dance", price = 20, id = 3001},
		{name = "Wave", price = 15, id = 3002},
		{name = "Victory", price = 25, id = 3003},
		{name = "Sad", price = 20, id = 3004},
		{name = "Happy", price = 20, id = 3005},
	}
}

-- Track product IDs to item mapping
local productIdMap = {}

-- Build the product ID map
for category, items in pairs(SHOP_ITEMS) do
	for _, item in ipairs(items) do
		productIdMap[item.id] = {
			name = item.name,
			category = category,
			price = item.price
		}
	end
end

-- Function to check if player is VIP
local function isVIPPlayer(playerName)
	for _, vipName in ipairs(VIP_PLAYERS) do
		if vipName == playerName then
			return true
		end
	end
	return false
end

-- Function to give player a cosmetic item
local function giveCosmetic(player, category, itemName)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then
		playerData = Instance.new("Folder")
		playerData.Name = "PlayerData"
		playerData.Parent = player
	end
	
	local inventory = playerData:FindFirstChild("Inventory")
	if not inventory then
		inventory = Instance.new("Folder")
		inventory.Name = "Inventory"
		inventory.Parent = playerData
	end
	
	local categoryFolder = inventory:FindFirstChild(category)
	if not categoryFolder then
		categoryFolder = Instance.new("Folder")
		categoryFolder.Name = category
		categoryFolder.Parent = inventory
	end
	
	-- Check if already owned
	local existingItem = categoryFolder:FindFirstChild(itemName)
	if existingItem then
		print(player.Name .. " already owns " .. itemName)
		return false
	end
	
	-- Add the item
	local newItem = Instance.new("StringValue")
	newItem.Name = itemName
	newItem.Value = "unlocked"
	newItem.Parent = categoryFolder
	
	print(player.Name .. " received " .. itemName)
	return true
end

-- Function to give VIP player all items for free
local function giveVIPAllItems(player)
	print(player.Name .. " is VIP! Giving all items for FREE!")
	
	-- Give all skins
	for _, skin in ipairs(SHOP_ITEMS.skins) do
		giveCosmetic(player, "Skins", skin.name)
	end
	
	-- Give all accessories
	for _, accessory in ipairs(SHOP_ITEMS.accessories) do
		giveCosmetic(player, "Accessories", accessory.name)
	end
	
	-- Give all emotes
	for _, emote in ipairs(SHOP_ITEMS.emotes) do
		giveCosmetic(player, "Emotes", emote.name)
	end
	
	-- Save to DataStore
	local success, err = pcall(function()
		local data = playerDataStore:GetAsync(player.UserId) or {
			username = player.Name,
			joinedAt = os.time(),
			inventory = {skins = {}, accessories = {}, emotes = {}},
			purchases = {}
		}
		
		data.isVIP = true
		data.vipUnlockedAt = os.time()
		
		playerDataStore:SetAsync(player.UserId, data)
	end)
	
	if not success then
		warn("Failed to save VIP status for " .. player.Name .. ": " .. err)
	end
	
	-- Send notification
	if player:FindFirstChild("PlayerGui") then
		local notification = Instance.new("TextLabel")
		notification.Text = "⭐ VIP ACCESS! All cosmetics unlocked for FREE! ⭐"
		notification.TextSize = 20
		notification.TextColor3 = Color3.fromRGB(255, 215, 0)
		notification.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		notification.BackgroundTransparency = 0.3
		notification.Size = UDim2.new(0, 500, 0, 60)
		notification.Position = UDim2.new(0.5, -250, 0, 20)
		notification.Font = Enum.Font.GothamBold
		notification.Parent = player.PlayerGui
		
		game:GetService("Debris"):AddItem(notification, 5)
	end
end

-- Listen for VIP players joining
Players.PlayerAdded:Connect(function(player)
	task.wait(1)
	
	if isVIPPlayer(player.Name) then
		giveVIPAllItems(player)
	end
end)

-- Function to save purchase to DataStore
local function savePurchase(player, category, itemName)
	local success, err = pcall(function()
		local data = playerDataStore:GetAsync(player.UserId) or {
			username = player.Name,
			joinedAt = os.time(),
			inventory = {skins = {}, accessories = {}, emotes = {}},
			purchases = {}
		}
		
		if not data.purchases then
			data.purchases = {}
		end
		
		table.insert(data.purchases, {
			category = category,
			item = itemName,
			timestamp = os.time()
		})
		
		playerDataStore:SetAsync(player.UserId, data)
	end)
	
	if not success then
		warn("Failed to save purchase for " .. player.Name .. ": " .. err)
	end
end

-- Handle product purchase
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:FindFirstChild(tostring(receiptInfo.PlayerId))
	
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local itemInfo = productIdMap[receiptInfo.ProductId]
	
	if itemInfo then
		local success = giveCosmetic(player, itemInfo.category, itemInfo.name)
		
		if success then
			savePurchase(player, itemInfo.category, itemInfo.name)
			
			-- Notify player
			if player:FindFirstChild("PlayerGui") then
				local notification = Instance.new("TextLabel")
				notification.Text = "✅ Purchase successful! You got " .. itemInfo.name .. "!"
				notification.TextSize = 20
				notification.TextColor3 = Color3.fromRGB(0, 255, 0)
				notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				notification.BackgroundTransparency = 0.5
				notification.Size = UDim2.new(0, 400, 0, 50)
				notification.Position = UDim2.new(0.5, -200, 0, 20)
				notification.Parent = player.PlayerGui
				
				game:GetService("Debris"):AddItem(notification, 3)
			end
			
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end
	
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- Function to prompt purchase for a player
local function promptPurchase(player, productId)
	if not productIdMap[productId] then
		warn("Invalid product ID: " .. productId)
		return
	end
	
	local success, err = pcall(function()
		MarketplaceService:PromptProductPurchase(player, productId)
	end)
	
	if not success then
		warn("Failed to prompt purchase: " .. err)
	end
end

print("Shop Manager loaded!")

return {
	SHOP_ITEMS = SHOP_ITEMS,
	promptPurchase = promptPurchase,
	giveCosmetic = giveCosmetic,
	productIdMap = productIdMap,
	isVIPPlayer = isVIPPlayer,
	giveVIPAllItems = giveVIPAllItems
}

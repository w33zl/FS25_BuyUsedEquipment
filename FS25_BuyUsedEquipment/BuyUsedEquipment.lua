--[[
SHORT DESCRIPTION OF WHAT YOUR MOD DOES GOES HERE

Author:     YOUR NAME/NICKNAME
Version:    1.0.0
Modified:   YYYY-MM-DD

Changelog:

]]

BuyUsedEquipment = Mod:init()

BuyUsedEquipment:source("ShopConfigScreenExtension.lua")
BuyUsedEquipment:source("FarmExtension.lua")
BuyUsedEquipment:source("RequestItemEvent.lua")

BuyUsedEquipment.MIN_SALE_DURATION = 24
BuyUsedEquipment.MAX_SALE_DURATION = BuyUsedEquipment.MIN_SALE_DURATION * 3

BuyUsedEquipment.MIN_GENERATION = 2
BuyUsedEquipment.MAX_GENERATION = 4

local GENERATIONS = {0, 5, 15, 50}
-- local GENERATIONS = {
--     {
--         maxYear = 0,
--         age = { 5, 25 },
--         discount = { 0.12, 0.1875 },
--         hours = { 2.5, 12.5 },
--         damage = { 0.05, 0.25 },
--         wear = { 0.045, 0.2375 },
--     },
--     {
--         maxYear = 3,
--         age = { 15, 35 },
--         discount = { 0.2, 0.3125 },
--         hours = { 7.5, 17.5 },
--         damage = { 0.15, 0.35 },
--         wear = { 0.135, 0.3325 },
--     },
--     {
--         maxYear = 8,
--         age = { 25, 45 },
--         discount = { 0.28, 0.4375 },
--         hours = { 12.5, 22.5 },
--         damage = { 0.25, 0.45 },
--         wear = { 0.225, 0.4275 },
--     },
--     {
--         maxYear = 15,
--         age = { 35, 55 },
--         discount = { 0.36, 0.5625 },
--         hours = { 17.5, 27.5 },
--         damage = { 0.35, 0.55 },
--         wear = { 0.315, 0.5225 },
--     },
--     {
--         maxYear = 25,
--         age = { 45, 65 },
--         discount = { 0.44, 0.6875 },
--         hours = { 22.5, 32.5 },
--         damage = { 0.45, 0.65 },
--         wear = { 0.405, 0.6175 },
--     },
--     {
--         maxYear = 50,
--         age = { 55, 75 },
--         discount = { 0.52, 0.8125 },
--         hours = { 27.5, 37.5 },
--         damage = { 0.55, 0.75 },
--         wear = { 0.495, 0.7125 },
--     },
--     {
--         maxYear = 100,
--         age = { 65, 85 },
--         discount = { 0.6, 0.9375 },
--         hours = { 32.5, 42.5 },
--         damage = { 0.65, 0.85 },
--         wear = { 0.585, 0.8075 },
--     },
-- }

BuyUsedEquipment.MAX_GENERATION = math.min(BuyUsedEquipment.MAX_GENERATION, #GENERATIONS)



-- Event that is executed when your mod is loading (after the map has been loaded and before the game starts)
function BuyUsedEquipment:loadMap(filename)
end

-- Event that is continuously, USE WITH CAUTION! Any demanding code here (even just a simple "print()" command) will cause poor performance, stuttering and FPS drops
function BuyUsedEquipment:update(dt)
end

-- Event that is executed when the player chooses to start the mission (after the map has been loaded and before the game starts)
function BuyUsedEquipment:startMission()
end

function BuyUsedEquipment:requestUsedItem(storeItem)
    local xmlFilename = storeItem.xmlFilename
    Log:debug("requestUsedItem: '%s' '%s'", storeItem.name, xmlFilename)
    RequestItemEvent.requestUsedItem(g_localPlayer.farmId, xmlFilename)
end

function BuyUsedEquipment:storeRequestedItem(farmId, xmlFilename)
    Log:debug("storeRequestedItem")
    Log:var("farmId", farmId)
    Log:var("xmlFilename", xmlFilename)
    local storeItem = g_storeManager:getItemByXMLFilename(xmlFilename)
    local farm = g_farmManager:getFarmById(farmId)

    if farm == nil then
        Log:error("Could not find farm with #%d", farmId)
        return
    -- elseif type(farm.addUsedVehicleSearch) ~= "function" then
    --     Log:error("Farm does not have addUsedVehicleSearch function")
    --     return
    end

    FarmExtension.addUsedVehicleSearch(farm, xmlFilename) --farm:addUsedVehicleSearch(xmlFilename)
end

function BuyUsedEquipment:finalizeSearch(farmId, xmlFilename)
    Log:debug("finalizeSearch")
    Log:var("farmId", farmId)
    Log:var("xmlFilename", xmlFilename)
    local storeItem = g_storeManager:getItemByXMLFilename(xmlFilename)
    local farm = g_farmManager:getFarmById(farmId)

    --TODO: add sale item
    --TODO: send notification to client
end



function BuyUsedEquipment:generateSaleItem(storeItem)
    local preferredGeneration = 4
    local generation = preferredGeneration or math.random(1, #GENERATIONS)
    local minAge = GENERATIONS[generation]
    local maxAge = GENERATIONS[generation + 1] or 100
    local age = math.random(minAge, maxAge) * 0.5 --HACK: factor to go from years to "reasonable" months

    local discountDelta = 5
    local discountBase = 10
    local discountPerGeneration = 15
    local discountMedian = discountBase + ((generation - 1) * discountPerGeneration)
    local minDiscount = discountMedian - discountDelta
    local maxDiscount = discountMedian + discountDelta
    local discount = math.random(minDiscount, maxDiscount)
    local priceFactor = (100 - discount) / 100
    -- local price = storeItem.price * 0.5
    local price = storeItem.price * priceFactor --BUG: fix
    Log:var("generation", generation)
    Log:var("discountMedian", discountMedian)
    Log:var("minDiscount", minDiscount)
    Log:var("maxDiscount", maxDiscount)
    Log:var("discount", discount)
    Log:var("discountFactor", priceFactor)
    Log:var("original price", storeItem.price)
    Log:var("discounted price", price)
    Log:var("age", age)
    
    g_currentMission.vehicleSaleSystem:addSale({
		["timeLeft"] = math.random(VehicleSaleSystem.MIN_GENERATED_ITEM_DURATION, VehicleSaleSystem.MAX_GENERATED_ITEM_DURATION),
		["isGenerated"] = false,
		["xmlFilename"] = storeItem.xmlFilename,
		["boughtConfigurations"] = {},
		["age"] = age,
		["price"] = price,
		["damage"] = 0.5, --TODO: fix
		["wear"] = 0.5, --TODO: fix
		["operatingTime"] = 10, -- TODO: FIX
	})
   
    Log:debug("Item added")
end




--[[

ShopConfigScreen.updateButtons
ShopConfigScreen.loadCurrentConfiguration
ShopConfigScreen.onFinishedLoading
ShopConfigScreen.updateDisplay
ShopConfigScreen.setStoreItem
ShopConfigScreen.setConfigPrice
ShopConfigScreen.processStoreItemConfigurationSet
ShopConfigScreen.updateConfigOptionsDisplay
ShopConfigScreen.onOpen

:getDescendantByName("button")
:getDescendantByName("yesNoOption"):setVisible(false)

]]

Log:debug("BuyUsedEquipment loaded")

-- function ShopConfigScreen.onQuoteBuyUsed(self)
-- 	local _, _, hasChanges = self:getConfigurationCostsAndChanges(self.storeItem, self.vehicle, self.saleItem)
-- 	if hasChanges then
-- 		local enoughMoney = self.totalPrice <= 0 and true or g_currentMission:getMoney() >= self.totalPrice
-- 		local enoughSlots = g_currentMission.slotSystem:hasEnoughSlots(self.storeItem)
-- 		g_inputBinding:setShowMouseCursor(true)
-- 		if enoughMoney then
-- 			if enoughSlots then
-- 				self:playSample(GuiSoundPlayer.SOUND_SAMPLES.CLICK)
-- 				local text = string.format(g_i18n:getText(ShopConfigScreen.L10N_SYMBOL.CONFIRM_BUY), g_i18n:formatMoney(self.totalPrice, 0, true, true))
-- 				local callback = self.onYesNoBuy
-- 				YesNoDialog.show(callback, self, text, nil, nil, nil, nil, nil, nil, nil, true)
-- 			else
-- 				self:playSample(GuiSoundPlayer.SOUND_SAMPLES.ERROR)
-- 				InfoDialog.show(g_i18n:getText(ShopConfigScreen.L10N_SYMBOL.TOO_FEW_SLOTS), nil, nil, DialogElement.TYPE_WARNING, nil, nil, nil, true)
-- 			end
-- 		else
-- 			self:playSample(GuiSoundPlayer.SOUND_SAMPLES.ERROR)
-- 			InfoDialog.show(g_i18n:getText(ShopConfigScreen.L10N_SYMBOL.NOT_ENOUGH_MONEY_BUY), nil, nil, DialogElement.TYPE_WARNING, nil, nil, nil, true)
-- 			return
-- 		end
-- 	else
-- 		return
-- 	end
-- end
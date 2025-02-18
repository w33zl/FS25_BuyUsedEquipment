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

BuyUsedEquipment.MIN_GENERATION = 1
BuyUsedEquipment.MAX_GENERATION = 6

BuyUsedEquipment.USE_ALT_PRICE_STRATEGY = true
BuyUsedEquipment.ALT_PRICE_DELTA = 5

local GENERATIONS = {
    {
        maxYear = 0,
        age = { 5, 25 },
        discount = { 0.12, 0.1875 },
        hours = { 2.5, 12.5 },
        damage = { 0.05, 0.25 },
        wear = { 0.045, 0.2375 },
    },
    {
        maxYear = 3,
        age = { 15, 35 },
        discount = { 0.2, 0.3125 },
        hours = { 7.5, 17.5 },
        damage = { 0.15, 0.35 },
        wear = { 0.135, 0.3325 },
    },
    {
        maxYear = 8,
        age = { 25, 45 },
        discount = { 0.28, 0.4375 },
        hours = { 12.5, 22.5 },
        damage = { 0.25, 0.45 },
        wear = { 0.225, 0.4275 },
    },
    {
        maxYear = 15,
        age = { 35, 55 },
        discount = { 0.36, 0.5625 },
        hours = { 17.5, 27.5 },
        damage = { 0.35, 0.55 },
        wear = { 0.315, 0.5225 },
    },
    {
        maxYear = 25,
        age = { 45, 65 },
        discount = { 0.44, 0.6875 },
        hours = { 22.5, 32.5 },
        damage = { 0.45, 0.65 },
        wear = { 0.405, 0.6175 },
    },
    {
        maxYear = 50,
        age = { 55, 75 },
        discount = { 0.52, 0.8125 },
        hours = { 27.5, 37.5 },
        damage = { 0.55, 0.75 },
        wear = { 0.495, 0.7125 },
    },
    {
        maxYear = 100,
        age = { 65, 85 },
        discount = { 0.6, 0.9375 },
        hours = { 32.5, 42.5 },
        damage = { 0.65, 0.85 },
        wear = { 0.585, 0.8075 },
    },
}

BuyUsedEquipment.SEARCH_LEVELS = {
    {
        name = g_i18n:getText("searchLevel_normal"),
        duration = 1,
        chance = 0.65,
        baseFee = 1000,
    },
    {
        name = g_i18n:getText("searchLevel_extended"),
        duration = 3,
        chance = 0.80,
        baseFee = 3000,
    },
    {
        name = g_i18n:getText("searchLevel_continuous"),
        duration = 12,
        chance = 0.95,
        baseFee = 15000,
    },
}

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

function BuyUsedEquipment:requestUsedItem(storeItem, searchLevel)
    local xmlFilename = storeItem.xmlFilename
    Log:debug("requestUsedItem: '%s' '%s'", storeItem.name, xmlFilename)
    RequestItemEvent.requestUsedItem(g_localPlayer.farmId, xmlFilename,searchLevel)
end

function BuyUsedEquipment:calculateFee(price, searchLevel)
    local searchType = self.SEARCH_LEVELS[searchLevel or 1]
    local threshold = 2500 -- Low price threshold
    local dynamicFee = 800
    local factor = math.log10(price/threshold)
    local baseFee = searchType.baseFee
    local fee = baseFee + (math.max(factor, 0) * dynamicFee)
    
    return fee
end


function BuyUsedEquipment:createSearchAssignment(xmlFilename, searchLevel)
    local searchType = self.SEARCH_LEVELS[searchLevel or 1]
    local fee = self:calculateFee(g_storeManager:getItemByXMLFilename(xmlFilename).price, searchLevel)
    local isSuccess = math.random() < searchType.chance
    local maxSearchTime = g_currentMission.environment.daysPerPeriod * searchType.duration * 24
    local searchDuration = math.random(1, maxSearchTime)
    local successTime = isSuccess and math.random(1, searchDuration) or searchDuration + 1
    Log:var("maxSearchTime", maxSearchTime)
    Log:var("searchDuration", searchDuration)
    Log:var("successTime", successTime)
    Log:var("isSuccess", isSuccess)
    Log:var("searchLevel", searchType)
    Log:var("fee", fee)
    return {
        ttl = searchDuration,
        tts = successTime,
        filename = xmlFilename,
        level = searchType,
    }
end

function BuyUsedEquipment:storeRequestedItem(farmId, xmlFilename, searchLevel)
    Log:debug("storeRequestedItem")
    Log:var("farmId", farmId)
    Log:var("xmlFilename", xmlFilename)
    Log:var("searchLevel", searchLevel)
    local storeItem = g_storeManager:getItemByXMLFilename(xmlFilename)
    local farm = g_farmManager:getFarmById(farmId)

    if farm == nil then
        Log:error("Could not find farm with #%d", farmId)
        return
    -- elseif type(farm.addUsedVehicleSearch) ~= "function" then
    --     Log:error("Farm does not have addUsedVehicleSearch function")
    --     return
    end

    FarmExtension.addUsedVehicleSearch(farm, xmlFilename, searchLevel) --farm:addUsedVehicleSearch(xmlFilename)
end

function BuyUsedEquipment:finalizeSearch(farmId, xmlFilename)
    Log:debug("finalizeSearch")

    if g_server == nil then
        Log:warning("finalizeSearch command is only allowed on the server")
        return
    end

    Log:var("farmId", farmId)
    Log:var("xmlFilename", xmlFilename)
    local storeItem = g_storeManager:getItemByXMLFilename(xmlFilename)
    local farm = g_farmManager:getFarmById(farmId)

    self:generateSaleItem(storeItem)

    --TODO: send notification to client
end



function BuyUsedEquipment:generateSaleItem(storeItem, preferredGeneration)

    local function getRandomValue(pair)
        local minValue, maxValue = unpack(pair)
        return math.random() * (maxValue - minValue) + minValue
    end

    -- local preferredGeneration = 4 --TODO: remove
    local generationIndex = preferredGeneration or math.random(self.MIN_GENERATION, self.MAX_GENERATION)
    local generation = GENERATIONS[generationIndex]
    -- local minAge, maxAge = unpack(generation.age)
    -- local minWear, maxWear = unpack(generation.wear)
    -- local minDamage, maxDamage = unpack(generation.damage)
    -- local minHours, maxHours = unpack(generation.hours)

    -- local age = math.random((minAge + 0), maxAge or 100)


    local wear = getRandomValue(generation.wear)
    local damage = getRandomValue(generation.damage)
    local hours = getRandomValue(generation.hours)
    local operatingTime = hours * (60 * 60 * 1000)
    local age = getRandomValue(generation.age)
    local discount = getRandomValue(generation.discount)
    local priceFactor = (1 - discount)
    local boughtConfigurations = {}



    -- local discountDelta = 5
    -- local discountBase = 10
    -- local discountPerGeneration = 15
    -- local discountMedian = discountBase + ((generationIndex - 1) * discountPerGeneration)
    -- local minDiscount = discountMedian - discountDelta
    -- local maxDiscount = discountMedian + discountDelta
    -- local minDiscount, maxDiscount = unpack(generation.discount)
    -- local discount = math.random(minDiscount * 100, maxDiscount * 100)
    -- local priceFactor = (100 - discount) / 100
    -- local price = storeItem.price * 0.5

    local price = storeItem.price * priceFactor --BUG: fix

    if self.USE_ALT_PRICE_STRATEGY then
        local defaultPrice = StoreItemUtil.getDefaultPrice(storeItem, boughtConfigurations)
        local repairPrice = Wearable.calculateRepairPrice(defaultPrice, damage)
        local repaintPrice = Wearable.calculateRepaintPrice(defaultPrice, wear)
        local altPrice = Vehicle.calculateSellPrice(storeItem, age, operatingTime, defaultPrice, repairPrice, repaintPrice)
        local deltaFactor = 1 + (math.random(-self.ALT_PRICE_DELTA, self.ALT_PRICE_DELTA) / 100)
        Log:var("alt price", altPrice)

        price = altPrice * deltaFactor
    end


    Log:var("generation", generationIndex)
    -- Log:var("discountMedian", discountMedian)
    -- Log:var("minDiscount", minDiscount)
    -- Log:var("maxDiscount", maxDiscount)
    Log:var("discount", discount)
    Log:var("priceFactor", priceFactor)
    Log:var("original price", storeItem.price)
    Log:var("discounted price", price)
    
    -- Log:var("minAge", minAge)
    -- Log:var("maxAge", maxAge)
    Log:var("age", age)
    Log:var("wear", wear)
    Log:var("damage", damage)
    Log:var("hours", hours)
    
    g_currentMission.vehicleSaleSystem:addSale({
		["timeLeft"] = math.random(self.MIN_SALE_DURATION, self.MAX_SALE_DURATION),
		["isGenerated"] = false,
		["xmlFilename"] = storeItem.xmlFilename,
		["boughtConfigurations"] = boughtConfigurations,
		["age"] = age,
		["price"] = price,
		["damage"] = damage,
		["wear"] = wear,
		["operatingTime"] = operatingTime,
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
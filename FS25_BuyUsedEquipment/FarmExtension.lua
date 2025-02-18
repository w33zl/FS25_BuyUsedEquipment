FarmExtension = {}

function FarmExtension.new(isServer, superFunc, isClient, spectator, customMt, ...)
    Log:debug("FarmExtension.new")
    local farm = superFunc(isServer, isClient, spectator, customMt, ...)
    
    Log:var("superFunc", superFunc)
    Log:var("isServer", isServer)
    Log:var("isClient", isClient)
    Log:var("spectator", spectator)
    Log:var("customMt", customMt)

    farm.buyUsedVehicles = {}
	if g_server ~= nil then
		g_messageCenter:subscribe(MessageType.HOUR_CHANGED, FarmExtension.onHourChanged, farm)
	end



    return farm
end
Farm.new = Utils.overwrittenFunction(Farm.new, FarmExtension.new)

function FarmExtension:onHourChanged()
    -- Log:debug("FarmExtension:onHourChanged")

    if not self.isServer then
        Log:debug("not server")
        return
    end

    -- Log:var("farmId", self.farmId)
    -- Log:var("name", self.name)
    -- Log:var("color", self.color)
    -- Log:var("showInFarmScreen", self.showInFarmScreen)
    -- Log:var("isSpectator", self.isSpectator)

    local buyUsedVehicles = self.buyUsedVehicles

    if buyUsedVehicles == nil or #buyUsedVehicles == 0 then
        -- Log:debug("no items to check for farm #%d", self.farmId)
        return
    end

    local itemsFlushed = 0
    local totalItems = #buyUsedVehicles

    for i = totalItems, 1, -1 do
        -- print("checking #" .. i)
        local queueItem = buyUsedVehicles[i]
        queueItem.ttl = queueItem.ttl - 1
        queueItem.tts = queueItem.tts - 1
        local ttl = queueItem.ttl
        local tts = queueItem.tts

        -- Log:debug("ttl: %d, tts: %d", ttl, tts)
        if g_currentMission:getAllowsGuiDisplay() then
            if tts < 1 then
                BuyUsedEquipment:finalizeSearch(self.farmId, queueItem.filename, true)
                buyUsedVehicles[i] = nil
                itemsFlushed = itemsFlushed + 1
            elseif ttl < 1 then
                BuyUsedEquipment:finalizeSearch(self.farmId, queueItem.filename, false)
                buyUsedVehicles[i] = nil
                itemsFlushed = itemsFlushed + 1
            else
                -- items[i] = value
            end
        end
        
    end

    Log:debug("Flushed %d items out of %d for farm #%d", itemsFlushed, totalItems, self.farmId)
end

function FarmExtension:saveToXMLFile(xmlFile, key)
    Log:debug("FarmExtension:saveToXMLFile")

    -- if self.financing == nil then self.financing = {} end

    -- xmlFile:setSortedTable(key .. ".financing.finance", self.financing, function (index, financing)
    --     xmlFile:setString(index .. "#date", financing.date)
    --     xmlFile:setFloat(index .. "#amount", financing.amount)
    --     xmlFile:setFloat(index .. "#amountPaid", financing.amountPaid)
    --     xmlFile:setInt(index .. "#length", financing.length)
    --     xmlFile:setString(index .. "#vehicle", financing.vehicle)
    --     xmlFile:setBool(index .. "#paid", financing.paid)
    -- end)

end

Farm.saveToXMLFile = Utils.appendedFunction(Farm.saveToXMLFile, FarmExtension.saveToXMLFile)

function FarmExtension:loadFromXMLFile(superFunc, xmlFile, key)
    Log:debug("FarmExtension:loadFromXMLFile")

    local returnValue = superFunc(self, xmlFile, key)

    -- self.financing = {}

    -- xmlFile:iterate(key .. ".financing.finance", function (_, financingKey)
    --     local financingTable = {
    --         date = xmlFile:getString(financingKey .. "#date", "1-1"),
    --         amount = xmlFile:getFloat(financingKey .. "#amount", 0),
    --         amountPaid = xmlFile:getFloat(financingKey .. "#amountPaid", 0),
    --         length = xmlFile:getInt(financingKey .. "#length", 6),
    --         vehicle = xmlFile:getString(financingKey .. "#vehicle", "0"),
    --         paid = xmlFile:getBool(financingKey .. "#paid", true)
    --     }

    --     table.insert(self.financing, financingTable)
    -- end)

    return returnValue

end

Farm.loadFromXMLFile = Utils.overwrittenFunction(Farm.loadFromXMLFile, FarmExtension.loadFromXMLFile)

function FarmExtension.addUsedVehicleSearch(farm, xmlFilename, searchLevel)
    Log:debug("FarmExtension:addUsedVehicleSearch")



    farm.buyUsedVehicles = farm.buyUsedVehicles or {}
    local searchAssignment = BuyUsedEquipment:createSearchAssignment(xmlFilename, searchLevel)

    table.insert(farm.buyUsedVehicles, searchAssignment)
    --TODO: fix

    -- table.insert(farm.buyUsedVehicles, {
    --     ttl = 4,
    --     tts = 3,
    --     filename = xmlFilename,
    -- })

    Log:table("self.buyUsedVehicles", farm.buyUsedVehicles, 2)

    -- local storeItem = g_storeManager:getItemByXMLFilename(xmlFilename)
    -- local farm = g_farmManager:getFarm(farmId)

    -- if storeItem ~= nil and farm ~= nil then
    --     local financing = farm.financing
    --     local newEntry = {
    --         date = string.format("%d-%d", g_currentMission.environment.currentPeriod, g_currentMission.environment.currentYear),
    --         amount = storeItem.price,
    --         amountPaid = 0,
    --         length = 6,
    --         vehicle = storeItem.xmlFilename,
    --         paid = false
    --     }
    --     table.insert(financing, newEntry)
    -- end
end



-- function FarmExtension:writeStream(streamId, connection)

--     if self.financing == nil then
--         streamWriteUInt16(streamId, 0)
--     else
--         streamWriteUInt16(streamId, #self.financing or 0)
--         for _, entry in pairs(self.financing) do
--             streamWriteString(streamId, entry.date)
--             streamWriteFloat32(streamId, entry.amount)
--             streamWriteFloat32(streamId, entry.amountPaid)
--             streamWriteInt8(streamId, entry.length)
--             streamWriteString(streamId, entry.vehicle)
--             streamWriteBool(streamId, entry.paid)
--         end
--     end

-- end
-- Farm.writeStream = Utils.appendedFunction(Farm.writeStream, FarmExtension.writeStream)

-- function FarmExtension:readStream(streamId, connection)

--     local tableLength = streamReadUInt16(streamId)
--     self.financing = {}

--     if tableLength > 0 then

--         for i=1, tableLength do

--             local entryDate = streamReadString(streamId)
--             local entryAmount = streamReadFloat32(streamId)
--             local entryAmountPaid = streamReadFloat32(streamId)
--             local entryLength = streamReadInt8(streamId)
--             local entryVehicle = streamReadString(streamId)
--             local entryPaid = streamReadBool(streamId)

--             local newEntry = {
--                 date = entryDate,
--                 amount = entryAmount,
--                 amountPaid = entryAmountPaid,
--                 length = entryLength,
--                 vehicle = entryVehicle,
--                 paid = entryPaid
--             }

--             table.insert(self.financing, newEntry)

--         end
--     end

-- end

-- Farm.readStream = Utils.appendedFunction(Farm.readStream, FarmExtension.readStream)

-- function FarmExtension:periodChanged()

--     local financing = self.financing
--     local env = g_currentMission.environment
--     local period = env.currentPeriod
--     local year = env.currentYear

--     if financing ~= nil then

--         for _, entry in ipairs(financing) do

--             if entry.paid then return end

--             local entryPeriod = 1
--             local entryYear = 1
--             local amountPaid = entry.amountPaid
--             local amount = entry.amount
--             local interest = 1.05

--             for a, b in string.gmatch(entry.date, "(%w+)-(%w+)") do
--                 entryPeriod = tonumber(a)
--                 entryYear = tonumber(b)
--             end

--             local totalPeriods = (12 * year) + period -- 18
--             local finishedPeriods = (12 * entryYear) + entryPeriod -- 14 15 16 17 18 .. 19

--             if totalPeriods >= finishedPeriods + entry.length and amountPaid >= amount * 0.99 then
--                 entry.paid = true
--                 return
--             end

--             local monthlyCost = (amount - amountPaid) / math.max((finishedPeriods + entry.length) - totalPeriods, 1)

--             if self:getBalance() < monthlyCost then
--                 local vId = entry.vehicle
--                 local vSystem = g_currentMission.vehicleSystem
--                 if vId ~= nil and totalPeriods >= finishedPeriods + entry.length - 1 and vSystem.vehicleByUniqueId[vId] ~= nil then
--                     local v = vSystem.vehicleByUniqueId[vId]
--                     if v ~= nil then
--                         local storeItem = g_storeManager:getItemByXMLFilename(v.configFileName)
--                         g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_CRITICAL, string.format(g_i18n:getText("financing_vehicleRepossessed"), tostring(storeItem.name)))
--                         v:delete(false)
--                         entry.paid = true
--                     end
--                 else
--                     entry.amount = entry.amount + (((amount - amountPaid) * interest) - (amount - amountPaid))
--                     g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_CRITICAL, g_i18n:getText("financing_monthlyPaymentMissed"))
--                     g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_CRITICAL, string.format(g_i18n:getText("financing_monthlyPaymentMissed_newRemaining"), g_i18n:formatMoney(entry.amount - amountPaid, 2, true, true)))
--                 end
--             else

--                 if self.isServer then
--                     g_currentMission:addMoneyChange(0 - monthlyCost, self.farmId, MoneyType.SHOP_VEHICLE_BUY, true)
--                     self:changeBalance(0 - monthlyCost, MoneyType.SHOP_VEHICLE_BUY)
--                     entry.amountPaid = entry.amountPaid + monthlyCost
--                 else
--                     g_client:getServerConnection():sendEvent(MoneyChangeEvent.new(0 - monthlyCost, MoneyType.SHOP_VEHICLE_BUY, farmIndex))
--                 end
--                 if entry.amountPaid >= entry.amount * 0.99 then entry.paid = true end

--             end

--         end

--         for a, b in ipairs(financing) do
--             if b.paid == true then
--                 table.remove(financing, a)
--                 break
--             end
--         end

--     end

-- end

-- Farm.periodChanged = Utils.appendedFunction(Farm.periodChanged, FarmExtension.periodChanged)
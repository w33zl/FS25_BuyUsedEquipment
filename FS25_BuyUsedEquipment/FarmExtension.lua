FarmExtension = {}

function FarmExtension.new(isServer, superFunc, isClient, spectator, customMt, ...)
    local farm = superFunc(isServer, isClient, spectator, customMt, ...)
    
    -- Log:var("superFunc", superFunc)
    -- Log:var("isServer", isServer)
    -- Log:var("isClient", isClient)
    -- Log:var("spectator", spectator)
    -- Log:var("customMt", customMt)

    farm.buyUsedVehicles = {}
	if g_server ~= nil then
		g_messageCenter:subscribe(MessageType.HOUR_CHANGED, FarmExtension.onHourChanged, farm)
	end

    return farm
end
Farm.new = Utils.overwrittenFunction(Farm.new, FarmExtension.new)

function FarmExtension:onHourChanged()

    if not self.isServer then
        Log:debug("not server")
        return
    end

    local buyUsedVehicles = self.buyUsedVehicles

    if buyUsedVehicles == nil or #buyUsedVehicles == 0 then
        return
    end

    local itemsFlushed = 0
    local totalItems = #buyUsedVehicles

    for i = totalItems, 1, -1 do
        local queueItem = buyUsedVehicles[i]
        queueItem.ttl = queueItem.ttl - 1
        queueItem.tts = queueItem.tts - 1
        local ttl = queueItem.ttl
        local tts = queueItem.tts

        --TODO: maybe add successful/failed to a log?
        if g_currentMission:getAllowsGuiDisplay() then
            if tts < 1 then
                BuyUsedEquipment:finalizeSearch(self.farmId, queueItem.filename, true)
                table.remove(buyUsedVehicles, i)
                itemsFlushed = itemsFlushed + 1
            elseif ttl < 1 then
                BuyUsedEquipment:finalizeSearch(self.farmId, queueItem.filename, false)
                table.remove(buyUsedVehicles, i)
                itemsFlushed = itemsFlushed + 1
            end
        end
        
    end

    Log:debug("Flushed %d items out of %d for farm #%d", itemsFlushed, totalItems, self.farmId)
end

function FarmExtension:saveToXMLFile(xmlFile, key)
    -- Log:debug("FarmExtension:saveToXMLFile")

    if self.buyUsedVehicles == nil then self.buyUsedVehicles = {} end

    xmlFile:setSortedTable(key .. ".buyUsedEquipment.assignment", self.buyUsedVehicles, function (index, assignment)
        xmlFile:setInt(index .. "#ttl", assignment.ttl)
        xmlFile:setInt(index .. "#tts", assignment.tts)
        xmlFile:setString(index .. "#filename", assignment.filename)
        xmlFile:setInt(index .. "#level", assignment.level)
    end)

end

Farm.saveToXMLFile = Utils.appendedFunction(Farm.saveToXMLFile, FarmExtension.saveToXMLFile)

function FarmExtension:loadFromXMLFile(superFunc, xmlFile, key)
    Log:debug("FarmExtension:loadFromXMLFile")

    local returnValue = superFunc(self, xmlFile, key)

    self.buyUsedVehicles = {}

    xmlFile:iterate(key .. ".buyUsedEquipment.assignment", function (_, assignmentKey)
        local assignment = {
            ttl = xmlFile:getInt(assignmentKey .. "#ttl", 1),
            tts = xmlFile:getInt(assignmentKey .. "#tts", 2),
            filename = xmlFile:getString(assignmentKey .. "#filename", ""),
            level = xmlFile:getInt(assignmentKey .. "#level", 1),
        }

        if assignment.filename ~= "" then
            table.insert(self.buyUsedVehicles, assignment)
        end
        
    end)

    return returnValue

end

Farm.loadFromXMLFile = Utils.overwrittenFunction(Farm.loadFromXMLFile, FarmExtension.loadFromXMLFile)

function FarmExtension.addUsedVehicleSearch(farm, xmlFilename, searchLevel)
    -- Log:debug("FarmExtension:addUsedVehicleSearch")

    farm.buyUsedVehicles = farm.buyUsedVehicles or {}
    local searchAssignment = BuyUsedEquipment:createSearchAssignment(xmlFilename, searchLevel)

    table.insert(farm.buyUsedVehicles, searchAssignment)

    -- Log:table("self.buyUsedVehicles", farm.buyUsedVehicles, 2)

end

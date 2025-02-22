RequestItemEvent = {}
local RequestItemEvent_mt = Class(RequestItemEvent, Event)

InitEventClass(RequestItemEvent, "RequestItemEvent")

function RequestItemEvent.emptyNew()
	return Event.new(RequestItemEvent_mt)
end

function RequestItemEvent.new(farmId, xmlFilename, searchLevel)
	local newEvent = RequestItemEvent.emptyNew()

	newEvent.farmId = farmId
	newEvent.xmlFilename = xmlFilename
    newEvent.searchLevel = searchLevel or 1
	
	return newEvent
end

function RequestItemEvent.readStream(self, streamId, connection)
	if connection:getIsServer() then
		-- Log:debug("Response from server")
	else
		-- Log:debug("Response from client")
		local farmId = streamReadInt32(streamId)
		local xmlFilename = streamReadString(streamId)
        local searchLevel = streamReadInt32(streamId)

		-- local player = connection and g_currentMission:getPlayerByConnection(connection)
        
        RequestItemEvent.execute(farmId, xmlFilename, searchLevel)
	end
end

function RequestItemEvent.writeStream(self, streamId, connection)
	if connection:getIsServer() then
		streamWriteInt32(streamId, self.farmId)
		streamWriteString(streamId, self.xmlFilename)
        streamWriteInt32(streamId, self.searchLevel)
	else
        --TODO: should we do anything here?
	end
end

function RequestItemEvent.execute(farmId, xmlFilename, searchLevel)
    BuyUsedEquipment:storeRequestedItem(farmId, xmlFilename, searchLevel)
end

function RequestItemEvent.requestUsedItem(farmId, xmlFilename, searchLevel)
	if g_server == nil then
		-- Send event
		g_client:getServerConnection():sendEvent(RequestItemEvent.new(farmId, xmlFilename, searchLevel))
	else
		-- Fire directly
		RequestItemEvent.execute(farmId, xmlFilename, searchLevel)
	end
end


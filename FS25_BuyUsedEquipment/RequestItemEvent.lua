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
	-- Log:debug("readStream")
	if connection:getIsServer() then
		-- Log:debug("Response from server")
	else
		-- Log:debug("Response from client")
		local farmId = streamReadInt32(streamId)
		local xmlFilename = streamReadString(streamId)
        local searchLevel = streamReadInt32(streamId)

		local player = connection and g_currentMission:getPlayerByConnection(connection)
        
        RequestItemEvent.execute(farmId, xmlFilename, searchLevel)
	end
end

function RequestItemEvent.writeStream(self, streamId, connection)
	-- Log:debug("writeStream")
	if connection:getIsServer() then
		-- Log:debug("Sending from client")
		streamWriteInt32(streamId, self.farmId)
		streamWriteString(streamId, self.xmlFilename)
        streamWriteInt32(streamId, self.searchLevel)
	else
		-- Log:debug("Sending from server")
        --TODO: should we do anything here?
	end
end

function RequestItemEvent.execute(farmId, xmlFilename, searchLevel)
    -- Log:debug("RequestItemEvent.execute")
    -- Log:var("farmId", farmId)
    -- Log:var("xmlFilename", xmlFilename)
    -- Log:var("searchLevel", searchLevel)
    BuyUsedEquipment:storeRequestedItem(farmId, xmlFilename, searchLevel)
end

function RequestItemEvent.requestUsedItem(farmId, xmlFilename, searchLevel)
    -- Log:debug("RequestItemEvent.requestUsedItem")
    -- Log:var("farmId", farmId)
    -- Log:var("xmlFilename", xmlFilename)
    -- Log:var("searchLevel", searchLevel)
	if g_server == nil then
        -- Log:debug("Trigger client event")
		
		-- Send event
		g_client:getServerConnection():sendEvent(RequestItemEvent.new(farmId, xmlFilename, searchLevel))
	else
        -- Log:debug("Direct execute on server")

		-- Fire directly
		RequestItemEvent.execute(farmId, xmlFilename, searchLevel)
	end
end


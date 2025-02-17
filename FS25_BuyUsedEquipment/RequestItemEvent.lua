RequestItemEvent = {}
local RequestItemEvent_mt = Class(RequestItemEvent, Event)

InitEventClass(RequestItemEvent, "SpawnObjectEvent")

function RequestItemEvent.emptyNew()
	return Event.new(RequestItemEvent_mt)
end

function RequestItemEvent.new(farmId, xmlFilename)
	local newEvent = RequestItemEvent.emptyNew()

	newEvent.farmId = farmId
	newEvent.xmlFilename = xmlFilename
	
	return newEvent
end

function RequestItemEvent.readStream(self, streamId, connection)
	Log:debug("readStream")
	if connection:getIsServer() then
		Log:debug("Response from server")
	else
		Log:debug("Response from client")
		local farmId = streamReadInt32(streamId)
		local xmlFilename = streamReadString(streamId)

		local player = connection and g_currentMission:getPlayerByConnection(connection)
        
        RequestItemEvent.execute(farmId, xmlFilename)
	end
end

function RequestItemEvent.writeStream(self, streamId, connection)
	Log:debug("writeStream")
	if connection:getIsServer() then
		Log:debug("Sending from client")
		streamWriteInt32(streamId, self.farmId)
		streamWriteString(streamId, self.xmlFilename)
	else
		Log:debug("Sending from server")
        --TODO: should we do anything here?
	end
end

function RequestItemEvent.execute(farmId, xmlFilename)
    --TODO: fire the actual code
    Log:debug("RequestItemEvent.execute")
    Log:var("farmId", farmId)
    Log:var("xmlFilename", xmlFilename)
    BuyUsedEquipment:storeRequestedItem(farmId, xmlFilename)
end

function RequestItemEvent.requestUsedItem(farmId, xmlFilename)
    Log:debug("RequestItemEvent.requestUsedItem")
    Log:var("farmId", farmId)
    Log:var("xmlFilename", xmlFilename)
	if g_server == nil then
		-- Send event
        Log:debug("Trigger client event")
		g_client:getServerConnection():sendEvent(RequestItemEvent.new(farmId, xmlFilename))
	else
        Log:debug("Direct execute on server")
		-- Fire directly
		RequestItemEvent.execute(farmId, xmlFilename)
	end
end


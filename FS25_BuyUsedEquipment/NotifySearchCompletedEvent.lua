NotifySearchCompletedEvent = {}
local NotifySearchCompletedEvent_mt = Class(NotifySearchCompletedEvent, Event)
InitEventClass(NotifySearchCompletedEvent, "NotifySearchCompletedEvent")

local NOTIFICATION_DURATION = 10000

function NotifySearchCompletedEvent.emptyNew()
	return Event.new(NotifySearchCompletedEvent_mt)
end
function NotifySearchCompletedEvent.new(farmId, xmlFilename, success)
	-- Log:debug("NotifySearchCompletedEvent.new")
	local newEvent = NotifySearchCompletedEvent.emptyNew()
	newEvent.farmId = farmId
	newEvent.xmlFilename = xmlFilename
	newEvent.success = success
	
	return newEvent
end
function NotifySearchCompletedEvent.readStream(self, streamId, connection)
	Log:debug("NotifySearchCompletedEvent.readStream")
	self.farmId = streamReadInt32(streamId)
	self.xmlFilename = streamReadString(streamId)
	self.success = streamReadBool(streamId)

	self:run(connection)
end
function NotifySearchCompletedEvent.writeStream(self, streamId, connection)
	Log:debug("NotifySearchCompletedEvent.writeStream")
	streamWriteInt32(streamId, self.farmId)
	streamWriteString(streamId, self.xmlFilename)
	streamWriteBool(streamId, self.success)
end
function NotifySearchCompletedEvent.run(self, connection)
	-- Log:debug("NotifySearchCompletedEvent.run")
	if connection:getIsServer()  then
		Log:debug("Response from server")
		-- Log:var("self.farmId", self.farmId)
		-- Log:var("self.xmlFilename", self.xmlFilename)
		-- Log:var("self.success", self.success)

		local player = g_localPlayer

		if player.farmId ~= self.farmId then
			Log:debug("Player '%s' (farm #%d) does not match farmId '%d'", player.userId, player.farmId, self.farmId)
			return
		end

		if self.success then
			g_gui.guiSoundPlayer:playSample(GuiSoundPlayer.SOUND_SAMPLES.SUCCESS)
			g_currentMission:addGameNotification(g_i18n:getText("search_completed_success_title"), "", g_i18n:getText("search_completed_success_info"), nil, NOTIFICATION_DURATION)
			
		else
			g_gui.guiSoundPlayer:playSample(GuiSoundPlayer.SOUND_SAMPLES.ERROR)
			g_currentMission:addGameNotification(g_i18n:getText("search_completed_failed_title"), "", g_i18n:getText("search_completed_failed_info"), nil, NOTIFICATION_DURATION)
			
		end
	end
end










-- NotifySearchCompletedEvent = {}
-- local NotifySearchCompletedEvent_mt = Class(NotifySearchCompletedEvent, Event)

-- InitStaticEventClass(NotifySearchCompletedEvent, "NotifySearchCompletedEvent")

-- function NotifySearchCompletedEvent.emptyNew()
-- 	return Event.new(NotifySearchCompletedEvent_mt)
-- end

-- function NotifySearchCompletedEvent.new(farmId, xmlFilename, success)
-- 	local newEvent = NotifySearchCompletedEvent.emptyNew()

-- 	newEvent.farmId = farmId
-- 	newEvent.xmlFilename = xmlFilename
-- 	newEvent.success = success or false
	
-- 	return newEvent
-- end

-- function NotifySearchCompletedEvent.readStream(self, streamId, connection)
-- 	Log:debug("readStream")
-- 	if connection:getIsServer() then
-- 		Log:debug("Response from server")
-- 	else
-- 		Log:debug("Response from client")
-- 		local farmId = streamReadInt32(streamId)
-- 		local xmlFilename = streamReadString(streamId)
-- 		local success = streamReadBool(streamId)

-- 		-- local player = connection and g_currentMission:getPlayerByConnection(connection)
        
--         NotifySearchCompletedEvent.execute(farmId, xmlFilename, success)
-- 	end
-- end

-- function NotifySearchCompletedEvent.writeStream(self, streamId, connection)
-- 	Log:debug("writeStream")
-- 	if connection:getIsServer() then
-- 		Log:debug("Sending from client")
-- 		streamWriteInt32(streamId, self.farmId)
-- 		streamWriteString(streamId, self.xmlFilename)
-- 		streamWriteBool(streamId, self.success)
-- 	else
-- 		Log:debug("Sending from server")
--         --TODO: should we do anything here?
-- 	end
-- end



-- local NOTIFICATION_DURATION = 8000
-- function NotifySearchCompletedEvent.execute(farmId, xmlFilename, success)
--     Log:debug("NotifySearchCompletedEvent.execute")
--     Log:var("farmId", farmId)
--     Log:var("xmlFilename", xmlFilename)
-- 	Log:var("success", success)
	
-- 	--TODO: only show for the actual farm

	
-- 	if success then
-- 		g_gui.guiSoundPlayer:playSample(GuiSoundPlayer.SOUND_SAMPLES.SUCCESS)
--     	g_currentMission:addGameNotification(g_i18n:getText("search_completed_success_title"), "", g_i18n:getText("search_completed_success_info"), nil, NOTIFICATION_DURATION)
		
-- 	else
-- 		g_gui.guiSoundPlayer:playSample(GuiSoundPlayer.SOUND_SAMPLES.ERROR)
-- 		g_currentMission:addGameNotification(g_i18n:getText("search_completed_failed_title"), "", g_i18n:getText("search_completed_failed_info"), nil, NOTIFICATION_DURATION)
		
-- 	end
-- 	-- BuyUsedEquipment:storeRequestedItem(farmId, xmlFilename, searchLevel)
-- end

-- function NotifySearchCompletedEvent.broadcast(farmId, xmlFilename, success)
--     Log:debug("NotifySearchCompletedEvent.broadcast")
--     Log:var("farmId", farmId)
--     Log:var("xmlFilename", xmlFilename)
-- 	Log:var("success", success)
-- 	--self, event, sendLocal, ignoreConnection, ghostObject, force, connectionList, allowQueuing
-- 	-- g_server:broadcastEvent(NotifySuccessEvent.new(farmId, xmlFilename), true, false, {}, false, nil, true)
-- 	Server.broadcastEvent(g_server, NotifySearchCompletedEvent.new(farmId, xmlFilename, success), true, false, {}, true, nil, true)

-- 	g_currentMission:broadcastEventToFarm(NotifySearchCompletedEvent.new(farmId, xmlFilename, success), farmId, true, false, {}, true)

-- 	if g_server ~= nil then
--         Log:debug("Direct execute on server")
-- 		-- Fire directly
-- 		NotifySearchCompletedEvent.execute(farmId, xmlFilename, success)
-- 	end
-- end


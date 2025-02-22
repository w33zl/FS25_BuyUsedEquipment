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
	self.farmId = streamReadInt32(streamId)
	self.xmlFilename = streamReadString(streamId)
	self.success = streamReadBool(streamId)

	self:run(connection)
end
function NotifySearchCompletedEvent.writeStream(self, streamId, connection)
	streamWriteInt32(streamId, self.farmId)
	streamWriteString(streamId, self.xmlFilename)
	streamWriteBool(streamId, self.success)
end
function NotifySearchCompletedEvent.run(self, connection)
	if connection:getIsServer()  then
		-- Log:debug("Response from server")

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


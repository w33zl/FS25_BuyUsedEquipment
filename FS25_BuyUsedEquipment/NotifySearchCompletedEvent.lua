NotifySearchCompletedEvent = {}
local NotifySearchCompletedEvent_mt = Class(NotifySearchCompletedEvent, Event)
InitEventClass(NotifySearchCompletedEvent, "NotifySearchCompletedEvent")

function NotifySearchCompletedEvent.emptyNew()
	return Event.new(NotifySearchCompletedEvent_mt)
end

function NotifySearchCompletedEvent.new(farmId, xmlFilename, success)
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
	if connection:getIsServer() then
		local player = g_localPlayer

		if player.farmId ~= self.farmId then
			Log:debug("Player '%s' (farm #%d) does not match farmId '%d'", player.userId, player.farmId, self.farmId)
			return
		end

		local equipmentName = "Unknown Equipment"
		if g_storeManager and self.xmlFilename then
			local storeItem = g_storeManager:getItemByXMLFilename(self.xmlFilename)
			if storeItem and storeItem.name then
				equipmentName = storeItem.name
			end
		end

		local fullNotificationText = ""
		local soundToPlay = nil

		if self.success then
			soundToPlay = GuiSoundPlayer.SOUND_SAMPLES.SUCCESS
			local baseText = g_i18n:getText("search_completed_success_info")
			fullNotificationText = string.format("%s\n\nItem: %s", baseText, equipmentName)
		else
			soundToPlay = GuiSoundPlayer.SOUND_SAMPLES.ERROR
			local baseText = g_i18n:getText("search_completed_failed_info")
			fullNotificationText = string.format("%s\n\nItem: %s", baseText, equipmentName)
		end

		-- Route background results cleanly into the centralized queue layout
		if BuyUsedEquipment and BuyUsedEquipment.enqueueNotification then
			BuyUsedEquipment:enqueueNotification(fullNotificationText, soundToPlay)
		else
			-- Fallback execution wrapper matching the master time-scale logic overrides
			if g_currentMission then
				if BuyUsedEquipment.savedTimeScale == nil then
					BuyUsedEquipment.savedTimeScale = g_currentMission.missionInfo.timeScale
				end
				g_currentMission:setTimeScale(0)
			end
			
			local dialog = g_gui:showDialog("InfoDialog")
			if dialog ~= nil and dialog.target ~= nil then
				dialog.target:setDialogType(DialogElement.TYPE_INFO)
				
				local timeString = "00:00"
				if g_currentMission and g_currentMission.environment then
					local dayTime = g_currentMission.environment.dayTime
					local totalMinutes = math.floor(dayTime / 1000 / 60)
					local hours = math.floor(totalMinutes / 60)
					local minutes = totalMinutes % 60
					timeString = string.format("%02d:%02d", hours, minutes)
				end
				
				dialog.target:setText(string.format("%s\n\n[Triggered at Game Time: %s]", fullNotificationText, timeString))
				if soundToPlay and g_gui.guiSoundPlayer then
					g_gui.guiSoundPlayer:playSample(soundToPlay)
				end
				dialog.target:setCallback(function()
					if g_currentMission and BuyUsedEquipment.savedTimeScale ~= nil then
						g_currentMission:setTimeScale(BuyUsedEquipment.savedTimeScale)
						BuyUsedEquipment.savedTimeScale = nil
					end
				end)
			end
		end
	end
end
function ShopConfigScreen:onClickBuyUsed()
end

-- Global queue manager function to handle consecutive popups cleanly with master time scaling
function BuyUsedEquipment:enqueueNotification(text, soundSample)
    self.notificationQueue = self.notificationQueue or {}
    
    -- Capture the current in-game clock time
    local timeString = "00:00"
    if g_currentMission and g_currentMission.environment then
        local dayTime = g_currentMission.environment.dayTime
        local totalMinutes = math.floor(dayTime / 1000 / 60)
        local hours = math.floor(totalMinutes / 60)
        local minutes = totalMinutes % 60
        timeString = string.format("%02d:%02d", hours, minutes)
    end

    table.insert(self.notificationQueue, { text = text, sound = soundSample, timeStamp = timeString })

    -- If no dialog is currently showing, kickstart the display loop
    if not self.isDisplayingNotification then
        BuyUsedEquipment:processNextNotification()
    end
end

function BuyUsedEquipment:processNextNotification()
    if self.notificationQueue == nil or #self.notificationQueue == 0 then
        self.isDisplayingNotification = false
        
        -- Restore original speed once the entire queue is completely empty
        if g_currentMission and self.savedTimeScale ~= nil then
            g_currentMission:setTimeScale(self.savedTimeScale)
            Log:debug(string.format("Notification queue empty. Restoring original time scale to: %dx", self.savedTimeScale))
            self.savedTimeScale = nil
        end
        return
    end

    self.isDisplayingNotification = true
    local nextNotification = table.remove(self.notificationQueue, 1)

    -- Force Master Time Scale to 0 to lock time tightly across menus and fields
    if g_currentMission then
        if self.savedTimeScale == nil then
            self.savedTimeScale = g_currentMission.missionInfo.timeScale
            Log:debug(string.format("Notification opened. Saved current time scale: %dx", self.savedTimeScale))
        end
        g_currentMission:setTimeScale(0)
    end

    local dialog = g_gui:showDialog("InfoDialog")
    if dialog ~= nil and dialog.target ~= nil then
        dialog.target:setDialogType(DialogElement.TYPE_INFO)
        
        -- Append the captured start time timestamp to the bottom of the dialog text
        local finalizedText = string.format("%s\n\n[Triggered at Game Time: %s]", nextNotification.text, nextNotification.timeStamp)
        dialog.target:setText(finalizedText)
        
        if nextNotification.sound and g_gui.guiSoundPlayer then
            g_gui.guiSoundPlayer:playSample(nextNotification.sound)
        end
        
        -- Callback handles processing the subsequent item in line
        dialog.target:setCallback(function()
            BuyUsedEquipment:processNextNotification()
        end)
    else
        -- Fallback safety check if the dialog asset fails to load
        BuyUsedEquipment:processNextNotification()
    end
end

ShopConfigScreen.setStoreItem = Utils.overwrittenFunction(ShopConfigScreen.setStoreItem, function(self, superFunc, storeItem, ...)
    superFunc(self, storeItem, ...)

    local buyButton = self.buyButton
    local buyUsedButton = self.buyUsedButton

    if not buyUsedButton and buyButton then
        local parent = buyButton.parent
        buyUsedButton = buyButton:clone(parent)
        buyUsedButton.name = "buyUsedButton"
        buyUsedButton.text = "Find Used"
        buyUsedButton.inputActionName = "MENU_EXTRA_2"
        self.buyUsedButton = buyUsedButton
    end

    if buyUsedButton ~= nil then
        buyUsedButton:setDisabled(false)

        buyUsedButton.onClick = "onClickBuyUsed"
        buyUsedButton.text = g_i18n:getText("button_buyUsed")

        local function getFormattedOption(index)
            local name = BuyUsedEquipment.SEARCH_LEVELS[index].name
            local fee = g_i18n:getCurrency(BuyUsedEquipment:calculateFee(storeItem.price, index))
            local feeString = g_i18n:formatMoney(fee)
            return string.format(name, feeString)
        end

        local options = {}
        for i, _ in ipairs(BuyUsedEquipment.SEARCH_LEVELS) do
            table.insert(options, getFormattedOption(i))
        end

        self.onClickBuyUsed = function()
            g_shopConfigScreen:playSample(GuiSoundPlayer.SOUND_SAMPLES.CLICK)

            OptionDialog.show(function(results) 
                if results > 0 then
                    BuyUsedEquipment:requestUsedItem(storeItem, results)

                    local fee = BuyUsedEquipment:calculateFee(storeItem.price, results)
                    local feeString = g_i18n:formatMoney(g_i18n:getCurrency(fee))
                    local equipmentName = storeItem.name or "Equipment"

                    local baseText = g_i18n:getText("search_started_confirmation"):format(feeString)
                    local fullNotificationText = string.format("%s\n\nTarget: %s", baseText, equipmentName)

                    -- Route confirmation window safely into the persistent queue
                    BuyUsedEquipment:enqueueNotification(fullNotificationText, GuiSoundPlayer.SOUND_SAMPLES.YES)
                end
            end, g_i18n:getText("store_searchDialog_info"):gsub("\\n", "\n"), g_i18n:getText("store_searchDialog_title"), options)
        end

        buyUsedButton.onClickCallback = self.onClickBuyUsed
    end

    if buyUsedButton ~= nil then
        local function qualifyForUsed()
            local isQualified = storeItem.species == StoreSpecies.VEHICLE
            isQualified = isQualified and storeItem.saleItem == nil
            return isQualified
        end
        buyUsedButton:setDisabled(not qualifyForUsed())
    end
end)
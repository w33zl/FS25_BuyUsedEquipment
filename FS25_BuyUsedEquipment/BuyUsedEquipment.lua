--[[
SHORT DESCRIPTION OF WHAT YOUR MOD DOES GOES HERE

Author:     YOUR NAME/NICKNAME
Version:    1.0.0
Modified:   YYYY-MM-DD

Changelog:

]]

BuyUsedEquipment = Mod:init()

-- Event that is executed when your mod is loading (after the map has been loaded and before the game starts)
function BuyUsedEquipment:loadMap(filename)
end

-- Event that is continuously, USE WITH CAUTION! Any demanding code here (even just a simple "print()" command) will cause poor performance, stuttering and FPS drops
function BuyUsedEquipment:update(dt)
end

-- Event that is executed when the player chooses to start the mission (after the map has been loaded and before the game starts)
function BuyUsedEquipment:startMission()
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
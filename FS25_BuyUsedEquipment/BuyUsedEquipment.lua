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

ShopConfigScreen.onOpen = Utils.overwrittenFunction(ShopConfigScreen.onOpen, function(self, superFunc, ...)
    Log:debug("ShopConfigScreen.onOpen")
    superFunc(self, ...)
    self:getDescendantByName("button"):setVisible(false)
    -- self:getDescendantByName("yesNoOption"):setVisible(false)
end)

ShopConfigScreen.updateButtons = Utils.overwrittenFunction(ShopConfigScreen.updateButtons, function(self, superFunc, ...)
    Log:debug("ShopConfigScreen.updateButtons")
    superFunc(self, ...)

    local buyButton = self.buyButton

    Log:var("buyButton", buyButton)

    -- if buyButton ~= nil then
    --     Log:table("buyButton", buyButton, 2)

    --     local parent = buyButton.parent

    --     local buddy = buyButton:clone()
    --     buddy.text = "Buddy"

    --     Log:table("parent.elements", parent.elements, 1)
    --     -- buyButton:setEnabled(false)

    -- end

    
end)

ShopConfigScreen.setStoreItem = Utils.overwrittenFunction(ShopConfigScreen.setStoreItem, function(self, superFunc, ...)
    Log:debug("ShopConfigScreen.setStoreItem NEW")
    superFunc(self, ...)

    local buyButton = self.buyButton
    local buddyButton = self.buddyButton

    if not buddyButton and buyButton then
        local parent = buyButton.parent
        buddyButton = buyButton:clone(parent)
        buddyButton.name = "buddyButton"
        buddyButton.text = "Buddy"
        buddyButton.inputActionName = "MENU_EXTRA_2" -- TODO: custom U action?
        self.buddyButton = buddyButton
    end

    if buddyButton ~= nil then
        buddyButton:setDisabled(false)

        buddyButton.onClick = "onClickBuddy"
        buddyButton.text = "Buddy3"

        self.onClickBuddy = self.onClickBuddy or function()
            Log:info("Go!!")
        end

        buddyButton.onClickCallback = self.onClickBuddy
    end

    if buyButton ~= nil then
        buyButton:setDisabled(true)
    end
    -- :clone()
    -- visualizeTable("ShopConfigScreen", self, 1)
end)


ShopConfigScreen.updateData = Utils.overwrittenFunction(ShopConfigScreen.updateData, function(self, superFunc, storeItem, vehicle, saleItem)
    Log:debug("ShopConfigScreen.updateData")
    superFunc(self, storeItem, vehicle, saleItem)

    -- if self.isBuyingUsed then
    --     self.buyButton:setVisible(false)
    --     self.buyUsedButton:setVisible(true)
    -- else
    --     self.buyButton:setVisible(true)
    --     self.buyUsedButton:setVisible(false)
    -- end
end)


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
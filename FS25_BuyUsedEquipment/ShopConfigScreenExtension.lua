
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

ShopConfigScreen.setStoreItem = Utils.overwrittenFunction(ShopConfigScreen.setStoreItem, function(self, superFunc, storeItem, ...)
    Log:debug("ShopConfigScreen.setStoreItem NEW")
    superFunc(self, storeItem, ...)

    -- local args = {...}

    -- visualizeTable("args", args, 2)

    local buyButton = self.buyButton
    local buddyButton = self.buddyButton

    if not buddyButton and buyButton then
        local parent = buyButton.parent
        buddyButton = buyButton:clone(parent)
        buddyButton.name = "buddyButton"
        buddyButton.text = "Buddy"
        buddyButton.inputActionName = "MENU_EXTRA_2"
        self.buddyButton = buddyButton
    end

    if buddyButton ~= nil then
        buddyButton:setDisabled(false)

        buddyButton.onClick = "onClickBuddy"
        buddyButton.text = "Buddy4"

        self.onClickBuddy = function()
            --TODO: add sale item
            BuyUsedEquipment:requestUsedItem(storeItem)
            Log:info("Store item queued for search")
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


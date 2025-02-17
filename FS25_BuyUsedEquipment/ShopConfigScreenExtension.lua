
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
    local buyUsedButton = self.buyUsedButton

    if not buyUsedButton and buyButton then
        local parent = buyButton.parent
        buyUsedButton = buyButton:clone(parent)
        buyUsedButton.name = "buyUsedButton"
        buyUsedButton.text = "Buddy"
        buyUsedButton.inputActionName = "MENU_EXTRA_2"
        self.buyUsedButton = buyUsedButton
    end

    if buyUsedButton ~= nil then
        buyUsedButton:setDisabled(false)

        buyUsedButton.onClick = "onClickBuyUsed"
        buyUsedButton.text = g_i18n:getText("button_buyUsed")

        self.onClickBuyUsed = function()
            --TODO: add sale item
            BuyUsedEquipment:requestUsedItem(storeItem)
            Log:info("Store item queued for search")
        end

        buyUsedButton.onClickCallback = self.onClickBuyUsed
    end



    if buyUsedButton ~= nil then
        local function qualifyForUsed()
            local isQualified = storeItem.species == StoreSpecies.VEHICLE
            isQualified = isQualified and storeItem.saleItem == nil
            --isBundleItem
            --storeItem.price < 1000
            return isQualified
        end
        buyUsedButton:setDisabled(not qualifyForUsed())
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



-- ShopConfigScreen.onOpen = Utils.overwrittenFunction(ShopConfigScreen.onOpen, function(self, superFunc, ...)
--     Log:debug("ShopConfigScreen.onOpen")
--     superFunc(self, ...)
--     self:getDescendantByName("button"):setVisible(false)
--     -- self:getDescendantByName("yesNoOption"):setVisible(false)
-- end)

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


-- Local values: _, _, , enoughMoney, enoughSlots, text, callback, target
function ShopConfigScreen:onClickBuyUsed()
    -- OptionDialog.show(function(results) 
    --     Log:debug("OptionDialog.show")
    --     Log:var("results", results)

    --     if true then
    --         BuyUsedEquipment:requestUsedItem(storeItem)
    --     end
    -- end, "Texten", "En title", { "Nej", "Ja", "Kanske"})
	-- local _, _, hasChanges = self:getConfigurationCostsAndChanges(self.storeItem, self.vehicle, self.saleItem)
	-- if hasChanges then
	-- 	local v619_ = self.totalPrice <= 0 and true or g_currentMission:getMoney() >= self.totalPrice
	-- 	local v620_ = g_currentMission.slotSystem:hasEnoughSlots(self.storeItem)
	-- 	g_inputBinding:setShowMouseCursor(true)
	-- 	if v619_ then
	-- 		if v620_ then
	-- 			self:playSample(GuiSoundPlayer.SOUND_SAMPLES.CLICK)
	-- 			local v621_ = string.format(g_i18n:getText(ShopConfigScreen.L10N_SYMBOL.CONFIRM_BUY), g_i18n:formatMoney(self.totalPrice, 0, true, true))
	-- 			local v622_ = self.onYesNoBuy
	-- 			YesNoDialog.show(v622_, self, v621_, nil, nil, nil, nil, nil, nil, nil, true)
	-- 		else
	-- 			self:playSample(GuiSoundPlayer.SOUND_SAMPLES.ERROR)
	-- 			InfoDialog.show(g_i18n:getText(ShopConfigScreen.L10N_SYMBOL.TOO_FEW_SLOTS), nil, nil, DialogElement.TYPE_WARNING, nil, nil, nil, true)
	-- 		end
	-- 	else
	-- 		self:playSample(GuiSoundPlayer.SOUND_SAMPLES.ERROR)
	-- 		InfoDialog.show(g_i18n:getText(ShopConfigScreen.L10N_SYMBOL.NOT_ENOUGH_MONEY_BUY), nil, nil, DialogElement.TYPE_WARNING, nil, nil, nil, true)
	-- 		return
	-- 	end
	-- else
	-- 	return
	-- end
end



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
                Log:debug("OptionDialog.show")
                Log:var("results", results)
        
                if results > 0 then
                    --HACK: this is wrong! fix!
                    -- BuyUsedEquipment:createSearchAssignment(storeItem, results)
                    BuyUsedEquipment:requestUsedItem(storeItem, results)

                    local fee = BuyUsedEquipment:calculateFee(storeItem.price, results)
                    local feeString = g_i18n:formatMoney(g_i18n:getCurrency(fee))

                    -- g_currentMission:addGameNotification("", g_i18n:getText("search_started_title"), g_i18n:getText("search_started_success_info"), nil, 5000)
                    InfoDialog.show(g_i18n:getText("search_started_confirmation"):format(feeString), nil, nil, DialogElement.TYPE_INFO, nil, nil, nil, true)

                    g_shopConfigScreen:playSample(GuiSoundPlayer.SOUND_SAMPLES.YES)
                else
                    -- g_shopConfigScreen:playSample(GuiSoundPlayer.SOUND_SAMPLES.ERROR)
                end
            end, g_i18n:getText("store_searchDialog_info"):gsub("\\n", "\n"), g_i18n:getText("store_searchDialog_title"), options)
            -- --TODO: add sale item
            -- BuyUsedEquipment:requestUsedItem(storeItem)
            -- Log:info("Store item queued for search")
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



function ShopConfigScreen:onClickBuyUsed()
end

ShopConfigScreen.setStoreItem = Utils.overwrittenFunction(ShopConfigScreen.setStoreItem, function(self, superFunc, storeItem, ...)
    -- Log:debug("ShopConfigScreen.setStoreItem NEW")
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
                -- Log:debug("OptionDialog.show")
                -- Log:var("results", results)
        
                if results > 0 then
                    BuyUsedEquipment:requestUsedItem(storeItem, results)

                    local fee = BuyUsedEquipment:calculateFee(storeItem.price, results)
                    local feeString = g_i18n:formatMoney(g_i18n:getCurrency(fee))

                    InfoDialog.show(g_i18n:getText("search_started_confirmation"):format(feeString), nil, nil, DialogElement.TYPE_INFO, nil, nil, nil, true)

                    g_shopConfigScreen:playSample(GuiSoundPlayer.SOUND_SAMPLES.YES)
                else
                    -- g_shopConfigScreen:playSample(GuiSoundPlayer.SOUND_SAMPLES.ERROR)
                end
            end, g_i18n:getText("store_searchDialog_info"):gsub("\\n", "\n"), g_i18n:getText("store_searchDialog_title"), options)
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
end)




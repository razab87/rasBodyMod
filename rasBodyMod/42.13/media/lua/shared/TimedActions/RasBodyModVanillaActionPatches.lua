-- here we patch two vanilla actions:
-- 
-- 1. the UnequipAction so that the glitch-fix-vests are exchanged by the vanilla vests when unequipping them; also need to trigger a clothing update on client after unequipping
-- 2. for the wear/unequip clothing actions, we trigger the OnClothingUpdated event in the complete function (vanilla does it sometimes only in perform() which is not sufficient for the mod the work properly)
--
--
-- by razab


local rasSharedData = require("RasBodyModSharedData")
local manageUtils = require("ManageBodyShared/RasBodyModManageUtils")
local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG") 



local function adjustBody(player)

    if isServer() then
        manageUtils.TransferDirtToSkin(player, {}) 
        sendServerCommand(player, "rasBodyMod", "customClothingUpdate", {}) -- send command to client: trigger customClothingUpdated event on client
    else
        manageBody.CustomClothingUpdate(player)
    end
end



local vanilla_UnequipComplete = ISUnequipAction.complete
function ISUnequipAction:complete(...)

    if self.item then                  
        local visual = self.item:getVisual()
        if visual then
            local visualType = visual:getItemType()
            if rasSharedData.GlitchedItemsReverse[visualType] then
                manageUtils.ExchangeVestVisuals(self.character, {bodyLocation = self.item:getBodyLocation():toString(), revert = true}) 
            end
        end
    end

    local returnValue = vanilla_UnequipComplete(self, ...) -- execute vanilla code

    adjustBody(self.character)

    return returnValue
end



local vanilla_WearClothingComplete = ISWearClothing.complete
function ISWearClothing:complete(...)

    local returnValue = vanilla_WearClothingComplete(self, ...)   -- execute vanilla code
  
    adjustBody(self.character)

    return returnValue
end



local vanilla_ExtraActionComplete = ISClothingExtraAction.complete
function ISClothingExtraAction:complete(...)

    local returnValue = vanilla_ExtraActionComplete(self, ...) -- execute vanilla code

    adjustBody(self.character)

	return returnValue
end





-- here we patch two vanilla actions:
-- 
-- 1. the UnequipAction so that the glitch fix vests get their usual vanilla visuals back
-- 2. the WearClothingAction where we trigger the OnClothingUpdated event in the complete() function (vanilla does it only in perform() which is
--    not sufficient for the mod the work properly)
--
-- by razab


local rasSharedData = require("RasBodyModSharedData")


local vanilla_UnequipComplete = ISUnequipAction.complete
function ISUnequipAction:complete(...)

       if self.item and rasSharedData.GlitchedItems[self.item:getFullType()] then -- revert the vest to its vanilla visual
            local visual = self.item:getVisual()
            if visual then                  
                  local newItem = rasSharedData.GlitchedItemsReverse[visual:getItemType()]
                  if newItem then
                         local inv = self.character:getInventory()
                         local texture = visual:getTextureChoice()
                         visual:setItemType(newItem) 
                         visual:setClothingItemName(newItem)
                         if texture then
                             visual:setTextureChoice(texture)
                         end
                  end
            end
       end

       return vanilla_UnequipComplete(self, ...) 
end



local vanilla_WearClothingComplete = ISWearClothing.complete
function ISWearClothing:complete(...)

    local value = vanilla_WearClothingComplete(self, ...)   -- execute vanilla code
  
    triggerEvent("OnClothingUpdated", self.character) -- trigger the event
    return value
end



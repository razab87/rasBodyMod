-- patch vanilla UnequipAction so that the glitch fix vests get their usual vanilla visuals back when unequiped
--
--
-- by razab


local rasSharedData = require("RasBodyModSharedData")


local vanilla_perform = ISUnequipAction.perform
function ISUnequipAction:perform(...)

       if self.item and rasSharedData.GlitchedItems[self.item:getFullType()] then
            local visual = self.item:getVisual()
            if visual then                  
                  local newItem = rasSharedData.GlitchedItemsReverse[visual:getItemType()]
                  if newItem then
                         local texture = visual:getTextureChoice()

                         visual:setItemType(newItem) 
                         visual:setClothingItemName(newItem)
                         if texture then
                             visual:setTextureChoice(texture)
                         end
                  end
            end
       end

       vanilla_perform(self, ...) -- execute vanilla
end

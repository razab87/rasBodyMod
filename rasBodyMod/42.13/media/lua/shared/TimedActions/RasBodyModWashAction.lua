-- arragne things so that the vanilla wash-yourself-option also applies to the modded textures
--
--
-- by razab



local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG")


local Regs = RasBodyModRegistries


-- this modifies a function in the timed action ISWashYourself so that blood and dirt is also removed from the skin when you wash
local vanilla_washPart = ISWashYourself.washPart
function ISWashYourself.washPart(self, visual, part, ...)
        
    local returnValue = vanilla_washPart(self, visual, part, ...) -- execute vanilla code

    local skin = self.character:getWornItem(Regs.Skin)
    if skin then
	    if skin:getBlood(part) + skin:getDirt(part) <= 0 then
	       return false
	    end
    
        skin:setBlood(part, 0)
        skin:setDirt(part, 0)
	
        if isServer() then -- test 
            syncItemFields(self.character, skin)
            syncVisuals(self.character) -- test (seems to  sync the visuals of player clothing)
            sendServerCommand(self.character, "rasBodyMod", "customClothingUpdate", {}) -- send command to client: trigger customClothingUpdate event on client
        else
            manageBody.CustomClothingUpdate(self.character)
        end   
    end

    return returnValue
end





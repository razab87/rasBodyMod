-- arragne things so that the vanilla wash-yourself-option also applies to the modded textures
--
--
-- by razab



Regs = RasBodyModRegistries


-- this modifies a function in the timed action ISWashYourself so that blood and dirt is also removed from the skin when you wash
local vanilla_washPart = ISWashYourself.washPart
function ISWashYourself.washPart(self,visual, part, ...)
        
    vanilla_washPart(self, visual, part, ...) -- execute vanilla code

    local player = self.character
    local skin = player:getWornItem(Regs.Skin)
    if skin then
	   if skin:getBlood(part) + skin:getDirt(part) <= 0 then
	       return false
	   end
    end
    
    skin:setBlood(part, 0)
    skin:setDirt(part, 0)
	
    return true	
end





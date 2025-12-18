-- here we make sure that the player wears correct skin and penis model when in the CDDA challenge (vanilla game removes it)
--
--
-- by razab



local manageBody = require("ManageBodyShare/RasBodyModManageBodyIG")

local Regs = RasBodyModRegistries


local vanilla_AddPlayer = CDDA.AddPlayer
function CDDA.AddPlayer(playerNum, playerObj, ...)

        vanilla_AddPlayer(playerNum, playerObj, ...) -- execute vanilla code
              
        manageBody.EquipSkin(playerObj) -- re-equip body items
        manageBody.EquipBodyHair(playerObj, Regs.PubicHair) -- equip body hair items
        manageBody.EquipBodyHair(playerObj, Regs.LegHair)
        manageBody.EquipBodyHair(playerObj, Regs.ArmpitHair)
        manageBody.EquipHeadStubble(playerObj) -- equip head stubble  
        if not playerObj:isFemale() then
             manageBody.ManageMalePrivatePart(playerObj, true)
             manageBody.EquipBodyHair(playerObj, Regs.ChestHair)
             manageBody.EquipBeardStubble(playerObj)
        end
        
       -- add blood and dirt to skin 
       local visual = playerObj:getHumanVisual()
       local skin = playerObj:getWornItem(Regs.Skin)
       local coveredParts = BloodClothingType.getCoveredParts(skin:getBloodClothingType())
       for i=1,coveredParts:size() do
	      local part = coveredParts:get(i-1)
	      skin:setBlood(part, visual:getBlood(part))
	      skin:setDirt(part, visual:getDirt(part))
       end        
end
        










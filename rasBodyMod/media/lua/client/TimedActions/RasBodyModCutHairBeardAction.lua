-- we decrease the remaining uses of the razor if character shaves hair or beard; modifies vanilla client TimedAction ISCutHair and ISTrimBeard
--
--
-- by razab



local rasSharedData = require("RasBodyModSharedData")
local manageBody = require("ManageBody/RasBodyModManageBodyIG")


local vanilla_cutHairPerform = ISCutHair.perform
function ISCutHair:perform(...)
    local newHairStyle
	if self.character:isFemale() then
		newHairStyle = getHairStylesInstance():FindFemaleStyle(self.hairStyle):getName()
	else
	    newHairStyle = getHairStylesInstance():FindMaleStyle(self.hairStyle):getName()
	end
        
	if newHairStyle == "Bald" and self.item then -- in vanilla, razor is only used when cutting hair to bald
		if self.item:getFullType() == "Base.Razor" then -- in case razor is used, decrease its remaining uses
		       if self.item:getRemainingUses() > 0 then
                    self.item:Use()                    
	           else
                   return
	           end
		end
	end
	
	vanilla_cutHairPerform(self, ...) -- execute vanilla code
end





local vanilla_trimBeardPerform = ISTrimBeard.perform
function ISTrimBeard:perform(...)

     if self.item then 
		if self.item:getFullType() == "Base.Razor" then -- in case razor is used, decrease its remaining uses and remove stubble
		    if self.item:getRemainingUses() > 0 then
                     self.item:Use()
                     local data = self.character:getModData().RasBodyMod 
                     local newBeardStyle = getBeardStylesInstance():FindStyle(self.beardStyle)
                     local newBeardID = nil
                     if newBeardStyle then
                         newBeardID = newBeardStyle:getName()
                     end
                     if not rasSharedData.FullBeards[newBeardID] then -- do not remove stubble if result is a full beard
                          data.BeardStubble = 0
                          data.DaysTilGrow.BeardStubble = 3 + ZombRand(2) -- reset counter for beard growth
                     end
            end
		end
     end

     vanilla_trimBeardPerform(self, ...) -- execute vanilla code; will trigger ClothingUpdate and thus execute manageBody.BeardStubble for adjusting beard stubble
end








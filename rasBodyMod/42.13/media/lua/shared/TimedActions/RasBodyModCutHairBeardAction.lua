-- adjust trimBeard and cutHair so that they reduce available uses of razors; in case beard is shaved with a razor, we also may have to remove beard stubble; 
-- modifies vanilla TimedAction ISCutHair and ISTrimBeard
--
--
-- by razab



local rasSharedData = require("RasBodyModSharedData")
local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG")


local isRazor= {}
isRazor["Base.Razor"] = true
isRazor["Base.StraightRazor"] = true


-- PART I: modify TimedAction for cutting hair

local vanilla_cutHairIsValid = ISCutHair.isValid
function ISCutHair:isValid(...)

     if self.item and isRazor[self.item:getFullType()] then
           if self.item:isBroken() or self.item:getCurrentUses() < 1 then
                 return false
           end
     end   

     return vanilla_cutHairIsValid(self, ...) -- execute vanilla code
end



local vanilla_cutHairComplete = ISCutHair.complete
function ISCutHair:complete(...)
        
	if self.item and isRazor[self.item:getFullType()] then -- in case razor is used, decrease its remaining uses
        self.item:UseAndSync()                    
	end

    return vanilla_cutHairComplete(self, ...) -- execute vanilla code
end




-- PART II: modify TimedAction for trim beard

local vanilla_trimBeardIsValid = ISTrimBeard.isValid
function ISTrimBeard:isValid(...)

     if self.item and isRazor[self.item:getFullType()] then
           if self.item:isBroken() or self.item:getCurrentUses() < 1 then
                 return false
           end
     end   

     return vanilla_trimBeardIsValid(self, ...) -- execute vanilla code
end



local vanilla_trimBeardUpdate = ISTrimBeard.update
function ISTrimBeard:update(...)
   
       vanilla_trimBeardUpdate(self, ...) -- execute vanilla code

       if self.item and isRazor[self.item:getFullType()] then
		  self.item:setJobDelta(self:getJobDelta());
	   end
end



local vanilla_trimBeardStart = ISTrimBeard.start
function ISTrimBeard:start(...)	

    vanilla_trimBeardStart(self, ...) -- execute vanilla code

    if self.item and isRazor[self.item:getFullType()] then
		self.item:setJobDelta(0.0);
	end
end



local vanilla_trimBeardStop = ISTrimBeard.stop
function ISTrimBeard:stop(...)

   vanilla_trimBeardStop(self, ...) -- execute vanilla

   if self.item and isRazor[self.item:getFullType()] then 
         self.item:setJobDelta(0.0)
   end
end



local vanilla_trimBeardPerform = ISTrimBeard.perform
function ISTrimBeard:perform(...)

    vanilla_trimBeardPerform(self, ...) -- execute vanilla function

    if self.item and isRazor[self.item:getFullType()] then            
         self.item:setJobDelta(0.0)
    end

    if self.item and isRazor[self.item:getFullType()] then -- in case razor is used, remove stubble
        local data = self.character:getModData().RasBodyMod 
        local newBeardStyle = getBeardStylesInstance():FindStyle(self.beardStyle)
        local newBeardID = nil
        if newBeardStyle then
            newBeardID = newBeardStyle:getName()
        end
        if not rasSharedData.FullBeards[newBeardID] then -- do not remove stubble if result is a full beard
            data.BeardStubble = 0
            data.DaysTilGrow.BeardStubble = 4 + ZombRand(2) -- reset counter for beard growth
        end

        local queue = {
            {functionName = "EquipBeardStubble", args = {}},
            {functionName = "TransferDirtToSkin", args = {}} -- vanilla game sometimes removes dirt visuals from body when clothing items are (un-)equipped; we fix by manually re-setting dirt
        }
        manageBody.executeQueue(self.character, queue, true) -- parameter true means we update the in-game avatar after equipping the items
    end
end


local vanilla_trimBeardComplete = ISTrimBeard.complete
function ISTrimBeard:complete(...)

    if self.item and isRazor[self.item:getFullType()] then -- in case razor is used, decrease its remaining uses
        self.item:UseAndSync()
    end

    return vanilla_trimBeardComplete(self, ...) -- execute vanilla
end





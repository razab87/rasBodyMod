-- implements the timed action for shaving beard stubble
--
--
-- by razab


local rasSharedData = require("RasBodyModSharedData")
local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG")

local isRazor = {}
isRazor["Base.Razor"] = true
isRazor["Base.StraightRazor"] = true

local shaveStubbleAction = ISBaseTimedAction:derive("shaveStubbleAction") -- can be accessed via "require(TimedActions/RasBodyModshaveStubbleAction)" in other client files



function shaveStubbleAction:isValid()

    local currentBeard = getBeardStylesInstance():FindStyle(self.character:getHumanVisual():getBeardModel())
    local beardID = nil
    if currentBeard then
       beardID = currentBeard:getName()
    end
    local data = self.character:getModData().RasBodyMod
    if self.item and self.character:getInventory():contains(self.item) and isRazor[self.item:getFullType()] and (not self.item:isBroken()) and data.BeardStubble == 1 
       and self.item:getCurrentUses() >=1 and (not rasSharedData.FullBeards[beardID]) then
          return true    	
    end

    return false
end


function shaveStubbleAction:update()
	if self.item then
		self.item:setJobDelta(self:getJobDelta());
	end
end


function shaveStubbleAction:start()
	if isClient() and self.item then		
		self.item = self.character:getInventory():getItemById(self.item:getID())		
	end
           
    self.item:setJobType(getText("Shave Stubble"))
    self.item:setJobDelta(0.0)
    self:setActionAnim(CharacterActionAnims.Shave)
	self:setOverrideHandModels(self.item:getStaticModel() or "DisposableRazor", nil)
end


function shaveStubbleAction:stop()
    ISBaseTimedAction.stop(self)
    self.item:setJobDelta(0.0)
end


function shaveStubbleAction:perform()
	
    if self.item then
	   self.item:setJobDelta(0.0)
    end
	
    local data = self.character:getModData().RasBodyMod
	data.BeardStubble = 0	 	
    data.DaysTilGrow.BeardStubble = 4 + ZombRand(2) -- reset counter for stubble growth        
    self.character:resetBeardGrowingTime() -- reset beard growing time

    triggerEvent("OnClothingUpdated", self.character) -- calls manageBody.EquipBeardStubble which removes the stubble

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end


function shaveStubbleAction:complete()

    if self.item then
         self.item:UseAndSync() 
	end
	
	--local data = self.character:getModData().RasBodyMod
	--data.BeardStubble = 0	 	
    --data.DaysTilGrow.BeardStubble = 3 + ZombRand(2) -- reset counter for stubble growth        
    --self.character:resetBeardGrowingTime() -- reset beard growing time

    --triggerEvent("OnClothingUpdated", self.character) -- calls manageBody.EquipBeardStubble which removes the stubble

	return true
end


function shaveStubbleAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
    return 300
end


function shaveStubbleAction:new(character, item)
	local o = ISBaseTimedAction.new(self, character)
	o.character = character
	o.stopOnWalk = true
	o.stopOnRun = true
	o.item = item
	o.maxTime = o:getDuration()
	return o
end


return shaveStubbleAction





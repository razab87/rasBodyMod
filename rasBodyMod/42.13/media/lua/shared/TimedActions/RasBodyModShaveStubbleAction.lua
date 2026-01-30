-- implements the timed action for shaving beard stubble
--
--
-- by razab


local rasSharedData = require("RasBodyModSharedData")
local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG")

local isRazor = {}
isRazor["Base.Razor"] = true
isRazor["Base.StraightRazor"] = true



RasBodyModShaveStubbleAction = ISBaseTimedAction:derive("RasBodyModShaveStubbleAction")


function RasBodyModShaveStubbleAction:isValid()

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


function RasBodyModShaveStubbleAction:update()
	if self.item then
		self.item:setJobDelta(self:getJobDelta());
	end
end


function RasBodyModShaveStubbleAction:start()
	if isClient() and self.item then		
		self.item = self.character:getInventory():getItemById(self.item:getID())		
	end
           
    self.item:setJobType(getText("Shave Stubble"))
    self.item:setJobDelta(0.0)
    self:setActionAnim(CharacterActionAnims.Shave)
	self:setOverrideHandModels(self.item:getStaticModel() or "DisposableRazor", nil)
end


function RasBodyModShaveStubbleAction:stop()
    ISBaseTimedAction.stop(self)
    self.item:setJobDelta(0.0)
end


function RasBodyModShaveStubbleAction:perform()
	
    if self.item then
	   self.item:setJobDelta(0.0)
    end
	
    self.character:resetBeardGrowingTime()

    local data = self.character:getModData().RasBodyMod
	data.BeardStubble = 0	 	
    data.DaysTilGrow.BeardStubble = 4 + ZombRand(2) -- reset counter for stubble growth         

    local queue = {
            {functionName = "EquipBeardStubble", args = {}},
            {functionName = "TransferDirtToSkin", args = {}} -- vanilla game sometimes removes dirt visuals from body when clothing items are (un-)equipped; we fix by manually re-setting dirt
    }        
    manageBody.executeQueue(self.character, queue, true) -- parameter true means we update the in-game avatar after equipping the items
 
    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end


function RasBodyModShaveStubbleAction:complete()

    if self.item then
         self.item:UseAndSync() 
	end
	
    self.character:resetBeardGrowingTime()

	return true
end


function RasBodyModShaveStubbleAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
    return 300
end


function RasBodyModShaveStubbleAction:new(character, item)
	local o = ISBaseTimedAction.new(self, character)
	o.stopOnWalk = true
	o.stopOnRun = true
	o.item = item
	o.maxTime = o:getDuration()
	return o
end






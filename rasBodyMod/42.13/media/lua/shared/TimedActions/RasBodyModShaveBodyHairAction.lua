-- implements the timed action for body hair shaving
--
--
-- by razab



local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG")
local rasSharedData = require("RasBodyModSharedData")

local locID = rasSharedData.ModLocationID

local isRazor = {}
isRazor["Base.Razor"] = true
isRazor["Base.StraightRazor"] = true

local shaveBodyHairAction = ISBaseTimedAction:derive("shaveBodyHairAction") -- can be accessed via "require(TimedActions/RasBodyModShaveBodyHairAction)" in other client files



local function isValidShaveOption(player, bodyLocation, choice, data)

      local gender = "Male"
      if player:isFemale() then
           gender = "Female"
      end
            
      local currentStyle = data[locID[bodyLocation]]
      if rasSharedData["ShaveTable"][gender][currentStyle] then
         for _,v in pairs(rasSharedData["ShaveTable"][gender][currentStyle]) do
              if v.canBeShavedTo == choice then
                     return true
              end
         end
      end

      return false
end



function shaveBodyHairAction:isValid()

     if self.item and isRazor[self.item:getFullType()] and (not self.item:isBroken()) and self.item:getCurrentUses() >=1 then
             local data = self.character:getModData().RasBodyMod             
             if data[locID[self.bodyLocation]] ~= "None" then
                  if self.choice == "None" then
                      return true
                  end
                  if isValidShaveOption(self.character, self.bodyLocation, self.choice, data) then
                      return true
                  end                  
             end	
    end

    return false
end


function shaveBodyHairAction:update()
	if self.item then
		self.item:setJobDelta(self:getJobDelta())
	end
end

function shaveBodyHairAction:start()
	if self.item then
		self.item:setJobType(getText("Shave Body Hair"))
		self.item:setJobDelta(0.0)
	end
end


function shaveBodyHairAction:stop()
    ISBaseTimedAction.stop(self)
    self.item:setJobDelta(0.0)
end


function shaveBodyHairAction:perform()
        
    if self.item then
       self.item:setJobDelta(0.0)
    end
	 
    local modData = self.character:getModData()
    local data = modData.RasBodyMod

    data["DaysTilGrow"][locID[self.bodyLocation]] = 4 + ZombRand(2) -- reset counter for body hair growth 
   	
	data[locID[self.bodyLocation]] = self.choice -- update body hair info
	manageBody.EquipBodyHair(self.character, self.bodyLocation) -- equip new body hair item  
 
	triggerEvent("OnClothingUpdated", self.character) -- necessary to update the avatar in character screen; also triggers "manageBody.ManageMalePrivatePart()" for equpping the correct penis model
        
    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end


function shaveBodyHairAction:complete()

    if self.item then
        self.item:UseAndSync()
	end
	  	
	--local modData = self.character:getModData()
    --local data = modData.RasBodyMod

    --data["DaysTilGrow"][locID[self.bodyLocation]] = 4 + ZombRand(2) -- reset counter for body hair growth 
   	
	--data[locID[self.bodyLocation]] = self.choice -- update body hair info
	--manageBody.EquipBodyHair(self.character, self.bodyLocation) -- equip new body hair item  
 
	--triggerEvent("OnClothingUpdated", self.character) -- necessary to update the avatar in character screen; also triggers "manageBody.ManageMalePrivatePart()" for equpping the correct penis model
 
    return true
end



function shaveBodyHairAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
    return 300
end


function shaveBodyHairAction:new(character, choice, bodyLocation, item)
	local o = ISBaseTimedAction.new(self, character)
	o.character = character
	o.stopOnWalk = true
	o.stopOnRun = true
	o.item = item
	o.choice = choice
    o.bodyLocation = bodyLocation
	o.maxTime = o:getDuration()
	return o
end



return shaveBodyHairAction





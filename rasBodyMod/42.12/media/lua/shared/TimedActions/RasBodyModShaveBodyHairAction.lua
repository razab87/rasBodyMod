-- implements the timed action for body hair shaving
--
--
-- by razab



local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG")
local rasSharedData = require("RasBodyModSharedData")

local isRazor = {}
isRazor["Base.Razor"] = true
isRazor["Base.StraightRazor"] = true

local shaveBodyHairAction = ISBaseTimedAction:derive("shaveBodyHairAction") -- can be accessed via "require(TimedActions/RasBodyModShaveBodyHairAction)" in other client files



local function isValidShaveOption(player, bodyLocation, choice, data)

      local gender = "Male"
      if player:isFemale() then
           gender = "Female"
      end
      
      local currentStyle = data[bodyLocation]
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
             if data[self.bodyLocation] ~= "None" then
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
	         
    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end


function shaveBodyHairAction:complete()

    if self.item then
        self.item:Use() 
	end
	  	
	local modData = self.character:getModData()
    local data = modData.RasBodyMod

    data["DaysTilGrow"][self.bodyLocation] = 4 + ZombRand(2) -- reset counter for body hair growth 
   	
	data[self.bodyLocation] = self.choice -- update body hair info
	manageBody.EquipBodyHair(self.character, self.bodyLocation) -- equip new body hair item  
 
	triggerEvent("OnClothingUpdated", self.character) -- necessary to update the avatar in character screen; also triggers "manageBody.ManageMalePrivatePart()" for equpping the correct penis model
 
    return true
end


function shaveBodyHairAction:new(character, choice, bodyLocation, item)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.item = item;
	o.choice = choice
    o.bodyLocation = bodyLocation
	o.maxTime = 300;
	if o.character:isTimedActionInstant() then
		o.maxTime = 1;
	end
	return o;
end


return shaveBodyHairAction





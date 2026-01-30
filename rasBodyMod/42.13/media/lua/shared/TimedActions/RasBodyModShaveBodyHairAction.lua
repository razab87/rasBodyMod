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

RasBodyModShaveBodyHairAction = ISBaseTimedAction:derive("RasBodyModShaveBodyHairAction") -- can be accessed via "require(TimedActions/RasBodyModRasBodyModShaveBodyHairAction)" in other client files



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



function RasBodyModShaveBodyHairAction:isValid()

     if self.item and isRazor[self.item:getFullType()] and (not self.item:isBroken()) and self.item:getCurrentUses() >=1 then
             local data = self.character:getModData().RasBodyMod 
             local theLocation = ItemBodyLocation.get(ResourceLocation.of(self.bodyLocation)) -- we need this conversion since we cannot call timedActions with ItemBodyLocation objects            
             if data[locID[theLocation]] ~= "None" then
                  if self.choice == "None" then
                      return true
                  end
                  if isValidShaveOption(self.character, theLocation, self.choice, data) then
                      return true
                  end                  
             end	
    end

    return false
end


function RasBodyModShaveBodyHairAction:update()
	if self.item then
		self.item:setJobDelta(self:getJobDelta())
	end
end

function RasBodyModShaveBodyHairAction:start()
	if self.item then
		self.item:setJobType(getText("Shave Body Hair"))
		self.item:setJobDelta(0.0)
	end
end


function RasBodyModShaveBodyHairAction:stop()
    ISBaseTimedAction.stop(self)
    self.item:setJobDelta(0.0)
end


function RasBodyModShaveBodyHairAction:perform()
        
    if self.item then
       self.item:setJobDelta(0.0)
    end
	     
    local theLocation = ItemBodyLocation.get(ResourceLocation.of(self.bodyLocation))	  	

	local data = self.character:getModData().RasBodyMod
    data["DaysTilGrow"][locID[theLocation]] = 4 + ZombRand(2) -- reset counter for body hair growth   
	data[locID[theLocation]] = self.choice -- update body hair info 
  
    local queue = { 
        {functionName = "EquipBodyHair", args = {bodyLocation = theLocation}},
        {functionName = "ManageMalePrivatePart", args = {}}, -- for male characters, we may need to change private part model according to pubic hair style
        {functionName = "TransferDirtToSkin", args = {}} -- vanilla game sometimes removes dirt visuals from body when clothing items are (un-)equipped; we fix by manually re-setting dirt
    }
    manageBody.executeQueue(self.character, queue, true) -- parameter true will update the in-game avatar
    
    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end


function RasBodyModShaveBodyHairAction:complete()

    if self.item then
        self.item:UseAndSync()
	end

    return true
end



function RasBodyModShaveBodyHairAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
    return 300
end


function RasBodyModShaveBodyHairAction:new(character, choice, bodyLocation, item) -- note: bodyLocation is the stringID, not the actual location object
	local o = ISBaseTimedAction.new(self, character)
	o.stopOnWalk = true
	o.stopOnRun = true
	o.item = item
	o.choice = choice
    o.bodyLocation = bodyLocation
	o.maxTime = o:getDuration()
	return o
end






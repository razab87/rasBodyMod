-- if male character starts the situp animation, we equip a different penis model for better visuals; modifies some from the vanilla file TimedAction ISFitnessAction.lua in client and from ISUI/ISFitnessUI.lua;
--
--
-- by razab






local util = require("ManageAnimations/RasBodyModAnimUtil.lua")


local ADDED_EQUIPDEFAULTPENIS_TO_EVENTS = false 
local FITNESS_STOPPED = false -- will be true in case fitness has stopped



-- if fitness stops due to fitness time over, too low endurance or movment key WASD pressed, we re-equip the default penis model here; 
-- cannot be done in stop() or perform() since those function are triggered to late and have therefore bad timing for re-equipping (-> looks glichty then)
local vanilla_update = ISFitnessAction.update
function ISFitnessAction.update(self, ...) 
        
    if getGameTime():getCalender():getTimeInMillis() > self.endMS then -- fix a vanilla bug (remove command forceStop() which makes character "flip-out" of the animation; remove on later vanilla updates)
        self.character:setVariable("ExerciseStarted", false)
        self.character:setVariable("ExerciseEnded", true)
        self.character:setMetabolicTarget(self.exeData.metabolics)
    else	
        vanilla_update(self, ...) -- execute vanilla code
    end
					
	if self.exercise == "situp" and not self.character:isFemale() then

	      if not ADDED_EQUIPDEFAULTPENIS_TO_EVENTS and 
                 (self.character:pressedMovement(true) or self.character:getMoodles():getMoodleLevel(MoodleType.ENDURANCE) > ISFitnessUI.enduranceLevelThreshold 
                       or getGameTime():getCalender():getTimeInMillis() > self.endMS) then -- condition when fitness stops

                        FITNESS_STOPPED = true
                        local data = self.character:getModData()
                        data.RasBodyMod.PrepareForSitups = nil -- don't need to sync this with server since it is only used client side

                        local delay = 825        
                        local speed = getGameSpeed()
                        if speed == 2 then
                            delay = delay/4
                        elseif speed == 3 then
                            delay = delay / 9
                        elseif speed == 4 then
                            delay = delay / 16
                        end

                        local startTime = nil
                        local function equipDefaultPenis(tick)
                        
                               if not startTime then
                                    startTime = getTimestampMs()
                               end

                               if getTimestampMs() >= startTime + delay then   -- equip the model after a short delay for better visuals 
                                      Events.OnTick.Remove(equipDefaultPenis) 
                                      data.RasBodyMod.PlayerMode = "default"               
                                      util.equipNow(self.character) -- will actually equip the model                                     
                               end
                        end

                        Events.OnTick.Add(equipDefaultPenis)  
                        ADDED_EQUIPDEFAULTPENIS_TO_EVENTS = true -- make sure that we don't add the function several times                
         end
   end	
end

-- when fitness is over due to pressing ESC, CANCEL or using a right-click action, we re-equip the default penis here
local vanilla_stop = ISFitnessAction.stop
function ISFitnessAction.stop(self, ...)  -- if player uses a right-click-action to abort fitness, we use this to trigger that fitness has ended (for suitable timing)     
	
    vanilla_stop(self, ...) -- execute vanilla code
	
    if self.exercise == "situp" and not self.character:isFemale() and not ADDED_EQUIPDEFAULTPENIS_TO_EVENTS then   -- unequip the "PenisSitting" model when situps ended and equip the default penis again

            FITNESS_STOPPED = true 
            local data = self.character:getModData()
            data.RasBodyMod.PrepareForSitups = nil	           

            local delay = 825        
            local speed = getGameSpeed()
            if speed == 2 then
                delay = delay/4
            elseif speed == 3 then
                delay = delay / 9
            elseif speed == 4 then
                delay = delay / 16
            end

           local startTime = nil
           local function equipDefaultPenis(tick)
            
                   if not startTime then
                        startTime = getTimestampMs()
                   end

                   if getTimestampMs() >= startTime + delay then   -- equip the model after a short delay for better visuals 
                          Events.OnTick.Remove(equipDefaultPenis)
                          data.RasBodyMod.PlayerMode = "default"                   
                          util.equipNow(self.character) -- will actually equip the model                         
                   end
           end

           Events.OnTick.Add(equipDefaultPenis)
           ADDED_EQUIPDEFAULTPENIS_TO_EVENTS = true
	end	
end



local vanilla_start = ISFitnessAction.start
function ISFitnessAction.start(self, ...)
        
    vanilla_start(self, ...) -- execute vanilla code   
 	    
	if self.exercise == "situp" and not self.character:isFemale() then   -- equip the Sitting penis model when male player's do situps
 	          
            local data = self.character:getModData()
            data.RasBodyMod.PrepareForSitups = true

            ADDED_EQUIPDEFAULTPENIS_TO_EVENTS = false
            FITNESS_STOPPED = false

            local delay = 825  
            local speed = getGameSpeed()
            if speed == 2 then
                delay = delay/4
            elseif speed == 3 then
                delay = delay / 9
            elseif speed == 4 then
                delay = delay / 16
            end

           local startTime = nil
           local function equipSitupPenis(tick)
            
                   if not startTime then
                       startTime = getTimestampMs()
                   end

                   if getTimestampMs() >= startTime + delay then   -- equip the new model after a short delay for better visuals  
                          Events.OnTick.Remove(equipSitupPenis) 
                          if not FITNESS_STOPPED then 
                                  data.RasBodyMod.PlayerMode = "situps"               
                                  util.equipNow(self.character) -- will actually equip the model 
                          end                         
                   end
           end

           Events.OnTick.Add(equipSitupPenis)
	end
end



-- next function is called in case player cancels fitness by pressing "Cancel" button in the fitness UI menu; modifes vanilla function from
-- lua/client/ISUI/ISFitnessUI.lua
local vanilla_ISFitnessOnClick = ISFitnessUI.onClick
function ISFitnessUI.onClick(self, button, ...) 

   if button.internal == "CANCEL" then

            local player = getPlayer()
            local data = player:getModData()

            if not player:isFemale() and data.RasBodyMod.PrepareForSitups and not ADDED_EQUIPDEFAULTPENIS_TO_EVENTS then -- in case player aborts with "cancel" button before the animation starts
            
                    FITNESS_STOPPED = true            
                    data.RasBodyMod.PrepareForSitups = nil	           

                    local delay = 825        
                    local speed = getGameSpeed()
                    if speed == 2 then
                        delay = delay/4
                    elseif speed == 3 then
                        delay = delay / 9
                    elseif speed == 4 then
                        delay = delay / 16
                    end

                   local startTime = nil
                   local function equipDefaultPenis(tick)
                    
                           if not startTime then
                                startTime = getTimestampMs()
                           end

                           if getTimestampMs() >= startTime + delay then   -- equip the model after a short delay for better visuals 
                                  Events.OnTick.Remove(equipDefaultPenis)
                                  data.RasBodyMod.PlayerMode = "default"                   
                                  util.equipNow(player) -- will actually equip the model                        
                           end
                   end

                   Events.OnTick.Add(equipDefaultPenis)
                   ADDED_EQUIPDEFAULTPENIS_TO_EVENTS = true
            end
   end

   if button.internal == "CANCEL" then -- fix vanilla bug (remove forceStop() command)
         self.player:setVariable("ExerciseStarted", false)
         self.player:setVariable("ExerciseEnded", true)
   else     
      vanilla_ISFitnessOnClick(self, button, ...) -- execute vanilla code
   end
end





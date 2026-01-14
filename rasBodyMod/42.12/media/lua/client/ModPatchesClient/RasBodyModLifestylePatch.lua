-- compatibility patch for bathing in the mod "Lifestyle"; the bathing options from the mod should also clean the skins introduced by ra's Body Mod
--
--
-- by razab




if getActivatedMods():contains("\\LifestyleHobbies") then
 
          local useShower = require("TimedActions/LSUseShower") -- patch TimedAction for showering 
          if useShower then

                    local original_Lifestyle_update_Shower = useShower.update
                    local function patchedUpdateShower(self, ...)

                           local skin = self.character:getWornItem("RasSkin") 
                           if skin then                
                                  local cleanVal = self.showerCleanVal                               
                                  local coveredParts = BloodClothingType.getCoveredParts(skin:getBloodClothingType())
                                  for i=1,coveredParts:size() do  
                                       local part = coveredParts:get(i-1)    
		                               local dirt = skin:getDirt(part)                                   
                                       if dirt > 0 and (dirt-cleanVal >= 0) then -- remove some dirt from the modded player skin
                                              skin:setDirt(part, dirt-cleanVal) 
                                       elseif dirt ~= 0 then 
                                              skin:setDirt(part, 0) 
                                       end
                                       local blood = skin:getBlood(part)
                                       local bloodCleanVal = cleanVal-0.01
                                       if blood > 0 and (blood-bloodCleanVal >= 0) then -- remove some blood from the modded player skin
                                              skin:setBlood(part, blood-bloodCleanVal)
                                       elseif blood ~= 0 then 
                                              skin:setBlood(part, 0)
                                       end
                                  end
                           end 
                           original_Lifestyle_update_Shower(self, ...) -- execute original mod code                       
                    end
                    useShower.update = patchedUpdateShower -- patch function from "Lifestyle"
          end
 

          local useTub = require("TimedActions/LSUseTub") -- patch TimedAction for using tub 
          if useTub then

                    local original_Lifestyle_update_Tub = useTub.update
                    local function patchedUpdateTub(self, ...)
                           local skin = self.character:getWornItem("RasSkin") 
                           if skin then                
                                  local cleanVal = 0.03                             
                                  local coveredParts = BloodClothingType.getCoveredParts(skin:getBloodClothingType())
                                  for i=1,coveredParts:size() do  
                                       local part = coveredParts:get(i-1)    
		                               local dirt = skin:getDirt(part)                                   
                                       if dirt > 0 and (dirt-cleanVal >= 0) then -- remove some dirt from the modded player skin
                                              skin:setDirt(part, dirt-cleanVal) 
                                       elseif dirt ~= 0 then 
                                              skin:setDirt(part, 0) 
                                       end
                                       local blood = skin:getBlood(part)
                                       local bloodCleanVal = cleanVal-0.01
                                       if blood > 0 and (blood-bloodCleanVal >= 0) then -- remove some blood from the modded player skin
                                              skin:setBlood(part, blood-bloodCleanVal)
                                       elseif blood ~= 0 then 
                                              skin:setBlood(part, 0)
                                       end
                                  end
                           end 
                           original_Lifestyle_update_Tub(self, ...) -- execute original mod code                       
                    end
                    useTub.update = patchedUpdateTub -- patch function from "Lifestyle"
          end
end



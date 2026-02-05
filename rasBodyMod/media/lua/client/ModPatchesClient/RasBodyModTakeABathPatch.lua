-- compatibility patch for the mod "Take A Bath"
--
--
-- by razab



local modInfo = getModInfoByID("fol_Take_A_Bath")
if modInfo and isModActive(modInfo) then
          if Fol_Take_A_Bath_Action and Fol_Take_A_Bath_TUB_Action then

                    local original_Fol_Take_A_Bath_Action_perform_Shower = Fol_Take_A_Bath_Action.perform
                    local function patchedPerformShower(self, ...)

                           local skin = self.character:getWornItem("RasSkin") -- remove all dirt/blood from the modded player skin
                           if skin then
                                  local coveredParts = BloodClothingType.getCoveredParts(skin:getBloodClothingType())
                                  for i=1,coveredParts:size() do
                                     local part = coveredParts:get(i-1)
                                     skin:setBlood(part, 0)
                                     skin:setDirt(part, 0)
                                  end
                           end 

                           original_Fol_Take_A_Bath_Action_perform_Shower(self, ...) -- execute original mod code                       
                    end

                    local original_Fol_Take_A_Bath_Action_perform_Tub = Fol_Take_A_Bath_TUB_Action.perform
                    local function patchedPerformTub(self, ...)

                           local skin = self.character:getWornItem("RasSkin") -- remove all dirt/blood from the modded player skin
                           if skin then
                                  local coveredParts = BloodClothingType.getCoveredParts(skin:getBloodClothingType())
                                  for i=1,coveredParts:size() do
                                     local part = coveredParts:get(i-1)
                                     skin:setBlood(part, 0)
                                     skin:setDirt(part, 0)
                                  end
                           end 

                           original_Fol_Take_A_Bath_Action_perform_Tub(self, ...) -- execute original mod code                        
                    end

                    Fol_Take_A_Bath_Action.perform = patchedPerformShower -- patch functions from "Take A Bath"
                    Fol_Take_A_Bath_TUB_Action.perform = patchedPerformTub
          end
end





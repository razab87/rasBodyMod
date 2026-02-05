-- this implements the body hair and beard stubble growth
--
--
--
-- by razab



local rasSharedData = require("RasBodyModSharedData")
local manageBody = require("ManageBody/RasBodyModManageBodyIG")


local growthTable = {}

growthTable.Female = {}
growthTable.Female["RasPubicHair"] = { full = "RasBodyMod.FemalePubicNatural", int = "RasBodyMod.FemalePubicNatural_Int" }
growthTable.Female["RasArmpitHair"] = { full = "RasBodyMod.FemaleArmpit", int = "RasBodyMod.FemaleArmpit_Int" }
growthTable.Female["RasLegHair"] = { full = "RasBodyMod.FemaleLeg", int = "RasBodyMod.FemaleLeg_Int" }

growthTable.Male = {}
growthTable.Male["RasPubicHair"] = { full = "RasBodyMod.MalePubicNatural", int = "RasBodyMod.MalePubicNatural_Int" }
growthTable.Male["RasArmpitHair"] = { full = "RasBodyMod.MaleArmpit", int = "RasBodyMod.MaleArmpit_Int" }
growthTable.Male["RasLegHair"] = { full = "RasBodyMod.MaleLeg", int = "RasBodyMod.MaleLeg_Int" }
growthTable.Male["RasChestHair"] = { full = "RasBodyMod.MaleChest", int = "RasBodyMod.MaleChest_Int" }



local function growBodyHair()
       local player = getPlayer()
       local data = player:getModData().RasBodyMod
       local somethingChanged = false
       local gender = "Male"
       if player:isFemale() then
            gender = "Female"
       end
       
       local improvedHairMenuActive = false    -- disable beard stubble growth when mod "Improved Hair Menu" is active; this mod overwrites critical vanilla functions, so we disable
       local modInfo = getModInfoByID("improvedhairmenu")  
       if modInfo and isModActive(modInfo) then            
           improvedHairMenuActive = true
       end

       -- count days since last change for body hair/beard occured       
       data.DaysTilGrow.RasPubicHair = data.DaysTilGrow.RasPubicHair - 1
       data.DaysTilGrow.RasArmpitHair = data.DaysTilGrow.RasArmpitHair - 1
       data.DaysTilGrow.RasLegHair = data.DaysTilGrow.RasLegHair - 1
       if gender == "Male" then
          data.DaysTilGrow.RasChestHair = data.DaysTilGrow.RasChestHair - 1
          if not improvedHairMenuActive then
             data.DaysTilGrow.BeardStubble = data.DaysTilGrow.BeardStubble - 1
          end
       end
       
       if gender == "Female" then -- for women           
              for location,_ in pairs(rasSharedData.BodyHairLocations) do
                  if location ~= "RasChestHair" then
                      if data["DaysTilGrow"][location] <= 0 then
                          data["DaysTilGrow"][location] = 3 + ZombRand(2) -- reset counter
                          if data[location] ~= growthTable[gender][location]["full"] then -- only grow smth when body hair is not yet full
                                 if data[location] == growthTable[gender][location]["int"] then
                                     data[location] = growthTable[gender][location]["full"]
                                 else
                                     data[location] = growthTable[gender][location]["int"]
                                 end 
                                 manageBody.EquipBodyHair(player, location) -- equip correct body hair
                                 somethingChanged = true
                          end
                      end
                  end
              end
       else -- for men
              for location,_ in pairs(rasSharedData.BodyHairLocations) do
                  if data["DaysTilGrow"][location] <= 0 then
                      data["DaysTilGrow"][location] = 3 + ZombRand(2) -- reset counter
                      if data[location] ~= growthTable[gender][location]["full"] then -- only grow smth when body hair is not yet full
                             if data[location] == growthTable[gender][location]["int"] or data[location] == "RasBodyMod.MalePubicStrip_Int" then
                                 data[location] = growthTable[gender][location]["full"]
                             elseif data[location] == "RasBodyMod.MalePubicStrip" then
                                 data[location] = "RasBodyMod.MalePubicStrip_Int"
                             else
                                 data[location] = growthTable[gender][location]["int"]
                             end 
                             manageBody.EquipBodyHair(player, location) -- equip correct body hair
                             somethingChanged = true
                      end
                  end
              end
              if (not improvedHairMenuActive) and data.DaysTilGrow.BeardStubble <= 0 then -- men also grow beard stubble
                 data.DaysTilGrow.BeardStubble = 3 + ZombRand(2) -- reset counter
                 if data.BeardStubble == 0 then
                    data.BeardStubble = 1
                    somethingChanged = true
                 end
              end
       end
      

       if somethingChanged then
          triggerEvent("OnClothingUpdated", player) -- necessary to update the avatar in character screen; also triggers "manageBody.ManageMalePrivatePart()" for equpping the correct penis model 
       end                                           -- and "manageBody.EquipBeardStubble()" for equipping correct beard stubble
end



Events.EveryDays.Add(growBodyHair) -- check once a day whether hair should grow







-- this implements the body hair and beard stubble growth
--
--
--
-- by razab



local rasSharedData = require("RasBodyModSharedData")
local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG")


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
       local locID = rasSharedData.ModLocationID       


       -- count days since last change for body hair/beard occured       
       data.DaysTilGrow.RasPubicHair = data.DaysTilGrow.RasPubicHair - 1
       data.DaysTilGrow.RasArmpitHair = data.DaysTilGrow.RasArmpitHair - 1
       data.DaysTilGrow.RasLegHair = data.DaysTilGrow.RasLegHair - 1
       if gender == "Male" then
          data.DaysTilGrow.RasChestHair = data.DaysTilGrow.RasChestHair - 1
          data.DaysTilGrow.BeardStubble = data.DaysTilGrow.BeardStubble - 1
       end
       
       if gender == "Female" then -- for women           
              for location,_ in pairs(rasSharedData.BodyHairLocations) do
                  local loc = locID[location]
                  if loc ~= "RasChestHair" then
                      if data["DaysTilGrow"][loc] <= 0 then
                          data["DaysTilGrow"][loc] = 4 + ZombRand(2) -- reset counter
                          if data[loc] ~= growthTable[gender][loc]["full"] then -- only grow smth when body hair is not yet full
                                 if data[loc] == growthTable[gender][loc]["int"] then
                                     data[loc] = growthTable[gender][loc]["full"]
                                 else
                                     data[loc] = growthTable[gender][loc]["int"]
                                 end 
                                 manageBody.EquipBodyHair(player, location) -- equip correct body hair
                                 somethingChanged = true
                          end
                      end
                  end
              end
       else -- for men
              for location,_ in pairs(rasSharedData.BodyHairLocations) do
                  local loc = locID[location]
                  if data["DaysTilGrow"][loc] <= 0 then
                      data["DaysTilGrow"][loc] = 4 + ZombRand(2) -- reset counter
                      if data[loc] ~= growthTable[gender][loc]["full"] then -- only grow smth when body hair is not yet full
                             if data[loc] == growthTable[gender][loc]["int"] or data[loc] == "RasBodyMod.MalePubicStrip_Int" then -- men also have an "int" state for strips
                                 data[loc] = growthTable[gender][loc]["full"]
                             elseif data[loc] == "RasBodyMod.MalePubicStrip" then
                                 data[loc] = "RasBodyMod.MalePubicStrip_Int"
                             else
                                 data[loc] = growthTable[gender][loc]["int"]
                             end 
                             manageBody.EquipBodyHair(player, location) -- equip correct body hair
                             manageBody.ManageMalePrivatePart(player, false)
                             somethingChanged = true
                      end
                  end
              end
              if data.DaysTilGrow.BeardStubble <= 0 then -- men also grow beard stubble
                 data.DaysTilGrow.BeardStubble = 4 + ZombRand(2) -- reset counter
                 if data.BeardStubble == 0 then
                    data.BeardStubble = 1
                    manageBody.EquipBeardStubble(player)
                    somethingChanged = true
                 end
              end
       end
      

       if somethingChanged then
          triggerEvent("OnClothingUpdated", player)  -- necessary to update the avatar in character screen and equip correct body hair items
       end
end



Events.EveryDays.Add(growBodyHair) -- check once a day whether hair should grow


--Events.EveryTenMinutes.Add(growBodyHair) -- for testing only: check every 10 min whether hair should grow 





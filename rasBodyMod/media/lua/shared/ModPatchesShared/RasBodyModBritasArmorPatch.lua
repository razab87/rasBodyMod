-- patch for the mod "Birta's Armor Pack"; add some modded clothig items to the ExceptionalClothes table to make sure that no glitches occur when worn by male characters; also add clothes to the UndressTable so that they
-- get undressed when shaving body hair
--
--
-- by razab


local rasSharedData = require("RasBodyModSharedData")

local modInfo = getModInfoByID("Brita_2")
if modInfo and isModActive(modInfo) then

        -- add stuff to ExceptionalClothes

        -- "Necklace_Long" location
        if not rasSharedData.ExceptionalClothes["Necklace_Long"] then 
           rasSharedData.ExceptionalClothes["Necklace_Long"] = {}
        end
        rasSharedData.ExceptionalClothes["Necklace_Long"]["Base.Chain_Coat"] = { hideWhileStanding = true, hideWhileSitting = false }  
        rasSharedData.ExceptionalClothes["Necklace_Long"]["Base.Metro_Coat"] = { hideWhileStanding = true, hideWhileSitting = false } 
        rasSharedData.ExceptionalClothes["Necklace_Long"]["Base.Military_Ghillie"] = { hideWhileStanding = true, hideWhileSitting = true } 
        rasSharedData.ExceptionalClothes["Necklace_Long"]["Base.Military_Ghillie_B"] = { hideWhileStanding = true, hideWhileSitting = false } 
        
        -- "Skirt" location 
        if not rasSharedData.ExceptionalClothes["Skirt"] then
              rasSharedData.ExceptionalClothes["Skirt"] = {}
        end
        rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Check"] = { hideWhileStanding = true, hideWhileSitting = false } 
        rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Heather"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Lisa"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Maria"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Office"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Office_Long"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Nurse"] = { hideWhileStanding = true, hideWhileSitting = false }
       
        -- "Jacket" location
        if not rasSharedData.ExceptionalClothes["Jacket"] then
              rasSharedData.ExceptionalClothes["Jacket"] = {}
        end
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Antibelok_ON"] = { hideWhileStanding = true, hideWhileSitting = true } 
        rasSharedData.ExceptionalClothes["Jacket"]["Base.BARS_Hoodie"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.BARS_Hoodie_ON"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Gorka6_Hoodie"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Gorka6_Hoodie_ON"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Bandit_Jacket_ON"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Bandit_Jacket"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Bloodsucker"] = { hideWhileStanding = true, hideWhileSitting = true }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Chara_Jacket"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Gorka5_Jacket"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Huntrite_Jacket"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.TEC_Jacket"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.EOD_Jacket"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Hunter_Jacket"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.JUGG_Jacket"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Police_Waterproof_Jacket"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Paramedic_Jacket"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Tactical_Hood"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Tactical_Hood_ON"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Kawaii_Hood"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Kawaii_Hood_ON"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.M65_Jacket"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.M65_Jacket_ON"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Jacket_Polizei"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Rose_Jacket"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.SH_Nurse"] = { hideWhileStanding = true, hideWhileSitting = true }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.SH_Nurse_2"] = { hideWhileStanding = true, hideWhileSitting = true }
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Light_Woman"] = { hideWhileStanding = true, hideWhileSitting = true }   
        rasSharedData.ExceptionalClothes["Jacket"]["Base.SH_Closer"] = { hideWhileStanding = true, hideWhileSitting = true }  
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Susie_Hood"] = { hideWhileStanding = true, hideWhileSitting = false }  
        rasSharedData.ExceptionalClothes["Jacket"]["Base.Susie_Hood_ON"] = { hideWhileStanding = true, hideWhileSitting = false }

        -- "TorsoExtra" location
        if not rasSharedData.ExceptionalClothes["TorsoExtra"] then
              rasSharedData.ExceptionalClothes["TorsoExtra"] = {}
        end
        rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.SET_Armor"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.SET_Armor_FULL"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.EOD_Armor"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Armor_Defender"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Armor_Defender_Set"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Hunter_Armor"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.JUGG_Armor"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Armor_Dozer"] = { hideWhileStanding = true, hideWhileSitting = false }
        rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.USCM_Armor"] = { hideWhileStanding = true, hideWhileSitting = false }

        -- add items to the UndressSpecificItems table for undressing them when shaving body hair

        -- for legs
        local legLocations = {"Necklace", "Necklace_Long", "Right_MiddleFinger", "Left_MiddleFinger", "Right_RingFinger", "FannyPackFront", "FannyPackBack"}
        local legException = {}
        legException["Base.Choker_Maria"] = true
        legException["Base.Hand_Band_Heather"] = true
        for _,v in pairs(legLocations) do
                 local itemList = getAllItemsForBodyLocation(v)
                 for _,item in pairs(itemList) do
                      local scriptItem = ScriptManager.instance:getItem(item)
                      if scriptItem:getModID() == "Brita_2" and not legException[item] then
                            rasSharedData.UndressSpecificItems.Legs[item] = true
                      end
                 end
        end

        -- for pubic hair
        local pubicLocations = {"Necklace_Long", "FannyPackBack"}
        for _,v in pairs(pubicLocations) do
                 local itemList = getAllItemsForBodyLocation(v)
                 for _,item in pairs(itemList) do
                      local scriptItem = ScriptManager.instance:getItem(item)
                      if scriptItem:getModID() == "Brita_2" then
                            rasSharedData.UndressSpecificItems.Pubic[item] = true
                      end
                 end
        end

        -- for chest
        local chestLocations = {"Necklace_Long", "Neck", "Left_RingFinger", "FannyPackBack"}
        for _,v in pairs(chestLocations) do
                 local itemList = getAllItemsForBodyLocation(v)
                 for _,item in pairs(itemList) do
                      local scriptItem = ScriptManager.instance:getItem(item)
                      if scriptItem:getModID() == "Brita_2" then
                            rasSharedData.UndressSpecificItems.Chest[item] = true
                      end
                 end
        end

end









-- store all relevant data in the player's modData when a new game starts; when game is loaded, we retrieve those data from the modData and ensure
-- that the player wears correct skin and body hair
--
--
-- mod data are summarized under the field getModData().RasBodyMod:
--           
--
--               RasBodyMod.PlayerMode = string telling what the player is currently doing ("sit" for sitting on ground, "situps" for sit-ups, "turn" for turning around, "cover" for 
--                                                                                           taking cover near a wall, "coverWalk" for cover and walk, "default" for anything else)                
--
--               RasBodyMod.SkinColorIndex = index of player's skin color (1=ligthest, 5=drakest)
--
--               RasBodyMod.RasPubicHair = pubic hair script ID ("RasBodyMod.something" or "None")
--               RasBodyMod.RasArmpitHair = armpit hair script ID
--               RasBodyMod.RasLegHair = leg hair script ID
--               RasBodyMod.RasChestHair = chest hair script ID (for males only)
--
--               RasBodyMod.PenisType = string, penis type equipped = script ID of the penis or "None"
--
--               RasBodyMod.BeardStubble = 0 or 1, 1 if player has beard stubbles
--               RasBodyMod.HeadStubble = 0 or 1, 1 if player has head stubble
--
--               RasBodyMod.DaysTilGrow.RasPubicHair = integer, days until pubic hair item will enter next growth state
--               RasBodyMod.DaysTilGrow.RasArmpitHair = same...
--               RasBodyMod.DaysTilGrow.RasLegHair = 
--               RasBodyMod.DaysTilGrow.RasChestHair =
--               RasBodyMod.DaysTilGrow.BeardStubble =
--
--
-- by razab





local rasClientData = require("RasBodyModClientData")
local rasSharedData = require("RasBodyModSharedData")
local manageBody = require("ManageBody/RasBodyModManageBodyIG") 
local manageTurnAround = require("ManageBody/RasBodyModManageTurnAround")
local manageSneaking = require("ManageBody/RasBodyModManageSneaking")




-- next function briefly equips the different penis models and re-quip the intended penis afterwards; this is for better visual behavior since the first equippment of the different models
-- will result in a small graphics glitch (flickering of the model); the glitch only occurs during the first equippment, so we equipp it briefly once when game starts and have no problems later
local clothingBackUp = {}
local modeBackUp = "default"
local function calibrateMale(tick)

     local player = getPlayer()
     local data = player:getModData().RasBodyMod

     if tick == 1 then           
           local items = player:getWornItems()
           local group = BodyLocations.getGroup("Human")
           for i=1,items:size() do -- backUp clothing info
                 local wornItem = items:get(i-1)
                 local item = wornItem:getItem()
                 local bodyLocation = item:getBodyLocation()
                 if group:getLocation(bodyLocation) and (not rasSharedData.BodyHairLocations[bodyLocation]) and bodyLocation ~= "RasSkin" and bodyLocation ~= "RasMalePrivatePart" 
                    and bodyLocation ~= "RasBeardStubble" and bodyLocation ~= "RasHeadStubble" then
                          table.insert(clothingBackUp, {clothing = item, location = bodyLocation, weight = item:getWeight(), actualWeight = item:getActualWeight()})
                          item:setWeight(0) -- briefly change weight so that players do not surpass inventory limit
                          item:setActualWeight(0)                                                  
                 end
           end

           for _,v in pairs(clothingBackUp) do
              player:setWornItem(v.location, nil) -- briefly unequip clothing
           end
           
           modeBackUp = data.PlayerMode
           data.PlayerMode = "turn" 
           manageBody.ManageMalePrivatePart(player, true) -- briefly equipp turn Around model
     elseif tick == 2 then
           data.PlayerMode = "cover"
           manageBody.ManageMalePrivatePart(player, true) -- briefly equip cover model
     elseif tick == 3 then
           data.PlayerMode = "coverWalk"
           manageBody.ManageMalePrivatePart(player, true) -- briefly equip coverWalk model
     elseif tick > 3 then

           -- re-equip clothing and restore data
           for _,v in pairs(clothingBackUp) do -- re-equip all clothing
                   local item = v.clothing
                   player:setWornItem(v.location, item)
                   item:setWeight(v.weight) -- restore weight
                   item:setActualWeight(v.actualWeight)                  
           end

           data.PlayerMode = modeBackUp           
           manageBody.ManageMalePrivatePart(player, true) -- re-equip desired model

           modeBackUp = "default"
           clothingBackUp = {}
           Events.OnTick.Remove(calibrateMale) -- remove event
   end
end




-- when new game is started, store all data in player's modData
local function mainInitFunction(player, square)    
                  
      local gender = "Male"
      if player:isFemale() then
           gender = "Female"
      end
     
      local data = player:getModData()
      data.RasBodyMod = {}
      data.RasBodyMod.ModVersion = "1.5" -- actual mod version            
      data.RasBodyMod.PlayerMode = "default" -- when new game starts, player is always in "default mode"  
      data.RasBodyMod.PenisType = "None"
      data.RasBodyMod.SkinColorIndex =  rasClientData.SkinColorIndex -- store skin color index 


      -- store body hair info as choosen during character creation
      if gender == "Female" then
              data.RasBodyMod.RasPubicHair = rasClientData.SelectedBodyHair.Female.RasPubicHair
              data.RasBodyMod.RasArmpitHair = rasClientData.SelectedBodyHair.Female.RasArmpitHair
              data.RasBodyMod.RasLegHair = rasClientData.SelectedBodyHair.Female.RasLegHair
              data.RasBodyMod.HeadStubble = rasClientData.HeadStubble
      else
              data.RasBodyMod.RasPubicHair = rasClientData.SelectedBodyHair.Male.RasPubicHair
              data.RasBodyMod.RasArmpitHair = rasClientData.SelectedBodyHair.Male.RasArmpitHair
              data.RasBodyMod.RasLegHair = rasClientData.SelectedBodyHair.Male.RasLegHair
              data.RasBodyMod.RasChestHair = rasClientData.SelectedBodyHair.Male.RasChestHair
              data.RasBodyMod.BeardStubble = rasClientData.BeardStubble
              data.RasBodyMod.HeadStubble = rasClientData.HeadStubble
      end
      
      -- store number of days until body hair enters the next growing state  
      data.RasBodyMod.DaysTilGrow = {}
      data.RasBodyMod.DaysTilGrow.RasChestHair = 3 + ZombRand(2)   -- note: ZombRand(2) = 0 or 1
      data.RasBodyMod.DaysTilGrow.RasArmpitHair = 3 + ZombRand(2)   
      data.RasBodyMod.DaysTilGrow.RasPubicHair = 3 + ZombRand(2)   
      data.RasBodyMod.DaysTilGrow.RasLegHair = 3 + ZombRand(2)   
      data.RasBodyMod.DaysTilGrow.BeardStubble = 3 + ZombRand(2)  

      manageBody.VestGlitchFixNewGame(player)  
      manageBody.VestGlitchFix(player)      
end


Events.OnNewGame.Add(mainInitFunction) -- init player and data on new game




-- if game starts, equip correct body items (called when new games starts and when game is loaded) 
local function onStart(player)

     local gender = "Male"
     if player:isFemale() then
          gender = "Female"
     end    
 
     local data = player:getModData()
       
     -- in case modData have not been initialised, initialise them with random values (can happen when mod is added to a save game/running server or mod was active with pre 1.5 version)
     if (not data.RasBodyMod) or (not data.RasBodyMod.ModVersion) then 

             data.RasBodyMod = {}
             data.RasBodyMod.ModVersion = "1.5"

             local visual = player:getHumanVisual() -- get player's actual skin color 
             data.RasBodyMod.SkinColorIndex = visual:getSkinTextureIndex() + 1 
                                     
   
             if gender == "Female" then -- for female characters

                      local n = ZombRand(101)
                      if n <= 55 then
                             data.RasBodyMod.RasPubicHair = "RasBodyMod.FemalePubicNatural"
                      elseif n <= 85 then
                             data.RasBodyMod.RasPubicHair = "RasBodyMod.FemalePubicTrimmed"
                      elseif n <= 95 then
                             data.RasBodyMod.RasPubicHair = "RasBodyMod.FemalePubicStrip"
                      else
                             data.RasBodyMod.RasPubicHair = "None"
                      end
                      n = ZombRand(101)
                      if n <= 30 then
                          data.RasBodyMod.RasArmpitHair = "RasBodyMod.FemaleArmpit"
                      else
                          data.RasBodyMod.RasArmpitHair = "None"
                      end
                      n = ZombRand(101)
                      if n <= 5 then
                          data.RasBodyMod.RasLegHair = "RasBodyMod.FemaleLeg"
                      else
                          data.RasBodyMod.RasLegHair = "None"
                      end

                      data.RasBodyMod.HeadStubble = 0

             else -- for male characters

                    local n = ZombRand(101)
                    if n <= 85 then        
                         data.RasBodyMod.RasPubicHair = "RasBodyMod.MalePubicNatural"
                    else
                         data.RasBodyMod.RasPubicHair = "RasBodyMod.MalePubicStrip"
                    end 
                    n = ZombRand(101)
                    if n <= 5 then
                         data.RasBodyMod.RasArmpitHair = "None"
                    else
                         data.RasBodyMod.RasArmpitHair = "RasBodyMod.MaleArmpit"
                    end
                    n = ZombRand(101)
                    if n <= 5 then
                        data.RasBodyMod.RasLegHair = "None"
                    else
                        data.RasBodyMod.RasLegHair = "RasBodyMod.MaleLeg"
                    end
                    n = ZombRand(101)
                    if n <= 10 then
                        data.RasBodyMod.RasChestHair = "None"
                        n = ZombRand(101)
                        if n <= 80 then
                            data.RasBodyMod.RasPubicHair = "RasBodyMod.MalePubicNatural"
                        elseif n <= 95 then
                            data.RasBodyMod.RasPubicHair = "RasBodyMod.MalePubicStrip"
                        else
                            data.RasBodyMod.RasPubicHair = "None"
                        end
                    else
                        data.RasBodyMod.RasChestHair = "RasBodyMod.MaleChest"
                    end

                    data.RasBodyMod.BeardStubble = 0
                    data.RasBodyMod.HeadStubble = 0
             end
             
             data.RasBodyMod.PlayerMode = "default"
             data.RasBodyMod.PenisType = "None"

             data.RasBodyMod.DaysTilGrow = {}
             data.RasBodyMod.DaysTilGrow.RasChestHair = 3 + ZombRand(2)   -- note: ZombRand(2) = randomly 0 or 1
             data.RasBodyMod.DaysTilGrow.RasArmpitHair = 3 + ZombRand(2)
             data.RasBodyMod.DaysTilGrow.RasPubicHair = 3 + ZombRand(2)
             data.RasBodyMod.DaysTilGrow.RasLegHair = 3 + ZombRand(2)    
             data.RasBodyMod.DaysTilGrow.BeardStubble = 3 + ZombRand(2)                  
     end
         

     if (not SandboxVars.RasBodyMod.PerformanceMode) and (data.RasBodyMod.PlayerMode == "cover" or data.RasBodyMod.PlayerMode == "coverWalk") then
            data.RasBodyMod.PlayerMode = "cover"
     else
            data.RasBodyMod.PlayerMode = "default"
     end
    
     -- equip body items
     manageBody.EquipSkin(player) -- equip skin    
     manageBody.EquipBodyHair(player, "RasPubicHair") -- equip body hair items
     manageBody.EquipBodyHair(player, "RasLegHair")
     manageBody.EquipBodyHair(player, "RasArmpitHair")
     manageBody.EquipHeadStubble(player) -- equip head stubble   
     if gender == "Male" then
           manageBody.EquipBodyHair(player, "RasChestHair")
           data.RasBodyMod.PenisType = "None"
           manageBody.ManageMalePrivatePart(player, true) -- make sure correct penis is equipped
           manageBody.EquipBeardStubble(player) -- equip beard stubble
     end
          
     -- retrieve blood and dirt from player's vanilla body and put it on the skin
     local visual = player:getHumanVisual()
     local skin = player:getWornItem("RasSkin")
     if skin then
          local coveredParts = BloodClothingType.getCoveredParts(skin:getBloodClothingType())
          for i=1,coveredParts:size() do
	         local part = coveredParts:get(i-1)
	         skin:setBlood(part, visual:getBlood(part))
	         skin:setDirt(part, visual:getDirt(part))
          end
     end      
end


local function mainStartFunction()

     local player = getPlayer()
     onStart(player)

     if (not SandboxVars.RasBodyMod.PerformanceMode) and (not player:isFemale()) then -- enable graphical enhancements for male characters
        Events.OnTick.Add(calibrateMale)
        Events.OnKeyStartPressed.Add(manageTurnAround.OnMovementKeyPressed)
        Events.OnKeyPressed.Add(manageTurnAround.OnMovementKeyReleased) 
        Events.OnKeyKeepPressed.Add(manageTurnAround.OnMovementKeyKeepPressed) 
        Events.OnPlayerUpdate.Add(manageSneaking.OnPlayerUpdate)        
    end        
end


Events.OnGameStart.Add(mainStartFunction) -- load data and equip correct items whenever player starts or loads a game




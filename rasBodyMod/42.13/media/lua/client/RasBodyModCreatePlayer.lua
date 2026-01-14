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
local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG") 
local manageTurnAround = require("ManageBodyClient/RasBodyModManageTurnAround")
local manageSneaking = require("ManageBodyClient/RasBodyModManageSneaking")

local Regs = RasBodyModRegistries


-- equip body items 
local function equipBodyItems(player)

      -- equip body items
      manageBody.EquipSkin(player) -- equip skin    
      manageBody.EquipBodyHair(player, Regs.PubicHair) -- equip body hair items
      manageBody.EquipBodyHair(player, Regs.LegHair)
      manageBody.EquipBodyHair(player, Regs.ArmpitHair)
      manageBody.EquipHeadStubble(player) -- equip head stubble   
      if not player:isFemale() then
           manageBody.EquipBodyHair(player, Regs.ChestHair)
           manageBody.ManageMalePrivatePart(player, true) -- make sure correct penis is equipped; true makes it check for exceptional clothes
           manageBody.EquipBeardStubble(player) -- equip beard stubble
      end

      manageBody.VestGlitchFixNewGame(player) -- when a new game starts, we need to make sure player wears vanilla vest  
      manageBody.VestGlitchFix(player) -- apply the glitch fix for vests 
end


-- when new game is started, store all data in player's modData and equip correct body items
local ADDED_TO_EVENTS = false
local function mainInitFunction(player, square)    
                  
    local gender = "Male"
    if player:isFemale() then
        gender = "Female"
    end

    local data = player:getModData()
    data.RasBodyMod = {}
    data.RasBodyMod.ModVersion = "1.5" -- actual mod version (not really...)            
    data.RasBodyMod.PlayerMode = "default" -- when new game starts, player is always in "default mode"  
    data.RasBodyMod.PenisType = "None"
    data.RasBodyMod.SkinColorIndex =  rasClientData.SkinColorIndex -- store skin color index 


    -- store body hair info as choosen during character creation
    if gender == "Female" then
        data.RasBodyMod.RasPubicHair = rasClientData["SelectedBodyHair"]["Female"][Regs.PubicHair]
        data.RasBodyMod.RasArmpitHair = rasClientData["SelectedBodyHair"]["Female"][Regs.ArmpitHair]
        data.RasBodyMod.RasLegHair = rasClientData["SelectedBodyHair"]["Female"][Regs.LegHair]
        data.RasBodyMod.HeadStubble = rasClientData["HeadStubble"]
    else
        data.RasBodyMod.RasPubicHair = rasClientData["SelectedBodyHair"]["Male"][Regs.PubicHair]
        data.RasBodyMod.RasArmpitHair = rasClientData["SelectedBodyHair"]["Male"][Regs.ArmpitHair]
        data.RasBodyMod.RasLegHair = rasClientData["SelectedBodyHair"]["Male"][Regs.LegHair]
        data.RasBodyMod.RasChestHair = rasClientData["SelectedBodyHair"]["Male"][Regs.ChestHair]
        data.RasBodyMod.BeardStubble = rasClientData["BeardStubble"]
        data.RasBodyMod.HeadStubble = rasClientData["HeadStubble"]
    end

    -- store number of days until body hair enters the next growing state  
    data.RasBodyMod.DaysTilGrow = {}
    data.RasBodyMod.DaysTilGrow.RasChestHair = 4 + ZombRand(2)   -- note: ZombRand(2) = 0 or 1
    data.RasBodyMod.DaysTilGrow.RasArmpitHair = 4 + ZombRand(2)   
    data.RasBodyMod.DaysTilGrow.RasPubicHair = 4 + ZombRand(2)   
    data.RasBodyMod.DaysTilGrow.RasLegHair = 4 + ZombRand(2)   
    data.RasBodyMod.DaysTilGrow.BeardStubble = 4 + ZombRand(2)  

    equipBodyItems(player) 

    if (not SandboxVars.RasBodyMod.PerformanceMode) then  
        if (not player:isFemale()) and not ADDED_TO_EVENTS then -- enable graphical enhancements for male characters
            Events.OnKeyStartPressed.Add(manageTurnAround.OnMovementKeyPressed)
            Events.OnKeyPressed.Add(manageTurnAround.OnMovementKeyReleased) 
            Events.OnKeyKeepPressed.Add(manageTurnAround.OnMovementKeyKeepPressed) 
            Events.OnPlayerUpdate.Add(manageSneaking.OnPlayerUpdate)
            ADDED_TO_EVENTS = true       
        elseif player:isFemale() and ADDED_TO_EVENTS then
            Events.OnKeyStartPressed.Remove(manageTurnAround.OnMovementKeyPressed)
            Events.OnKeyPressed.Remove(manageTurnAround.OnMovementKeyReleased) 
            Events.OnKeyKeepPressed.Remove(manageTurnAround.OnMovementKeyKeepPressed) 
            Events.OnPlayerUpdate.Remove(manageSneaking.OnPlayerUpdate)
            ADDED_TO_EVENTS = false
        end      
    end 
end


Events.OnNewGame.Add(mainInitFunction) -- init player and data on new game




-- if game starts, equip correct body items (called when new games starts and when game is loaded) 
local function onStart(player)

     local gender = "Male"
     if player:isFemale() then
          gender = "Female"
     end    
 
     local data = player:getModData()
       
     -- in case modData have not been initialised, initialise them with random values (can happen when mod is added to a save game/running game or mod was active with pre 1.5 version)
     if (not data.RasBodyMod) or (not data.RasBodyMod.ModVersion) then 

             data.RasBodyMod = {}
             data.RasBodyMod.ModVersion = "1.5"

             local visual = player:getHumanVisual() -- get player's actual skin color 
             data.RasBodyMod.SkinColorIndex = visual:getSkinTextureIndex() + 1 
                                     
   
             if gender == "Female" then -- for female characters

                      local n = ZombRand(101)
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
                      n = ZombRand(101)
                      if n <= 55 then
                             data.RasBodyMod.RasPubicHair = "RasBodyMod.FemalePubicNatural"
                      elseif n <= 85 then
                             data.RasBodyMod.RasPubicHair = "RasBodyMod.FemalePubicTrimmed"
                      elseif n <= 95 then
                             data.RasBodyMod.RasPubicHair = "RasBodyMod.FemalePubicStrip"
                      else
                             data.RasBodyMod.RasPubicHair = "None"
                             data.RasBodyMod.RasLegHair = "None"
                             data.RasBodyMod.RasArmpitHair = "None"
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
             --data.RasBodyMod.PenisType = "None"

             data.RasBodyMod.DaysTilGrow = {}
             data.RasBodyMod.DaysTilGrow.RasChestHair = 4 + ZombRand(2)   -- note: ZombRand(2) = randomly 0 or 1
             data.RasBodyMod.DaysTilGrow.RasArmpitHair = 4 + ZombRand(2)
             data.RasBodyMod.DaysTilGrow.RasPubicHair = 4 + ZombRand(2)
             data.RasBodyMod.DaysTilGrow.RasLegHair = 4 + ZombRand(2)    
             data.RasBodyMod.DaysTilGrow.BeardStubble = 4 + ZombRand(2)                  
     end
         

     data.RasBodyMod.PenisType = "None"
     if (not SandboxVars.RasBodyMod.PerformanceMode) and (data.RasBodyMod.PlayerMode == "cover" or data.RasBodyMod.PlayerMode == "coverWalk") then
            data.RasBodyMod.PlayerMode = "cover"
     else
            data.RasBodyMod.PlayerMode = "default"
     end
    
     equipBodyItems(player)
  
     -- retrieve blood and dirt from player's vanilla body and put it on the skin (we use vanilla body to store dirt and blood on body)
     local visual = player:getHumanVisual()
     local skin = player:getWornItem(Regs.Skin)
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

    if (not SandboxVars.RasBodyMod.PerformanceMode) then  
        if (not player:isFemale()) and not ADDED_TO_EVENTS then -- enable graphical enhancements for male characters
            Events.OnKeyStartPressed.Add(manageTurnAround.OnMovementKeyPressed)
            Events.OnKeyPressed.Add(manageTurnAround.OnMovementKeyReleased) 
            Events.OnKeyKeepPressed.Add(manageTurnAround.OnMovementKeyKeepPressed) 
            Events.OnPlayerUpdate.Add(manageSneaking.OnPlayerUpdate)
            ADDED_TO_EVENTS = true       
        elseif player:isFemale() and ADDED_TO_EVENTS then
            Events.OnKeyStartPressed.Remove(manageTurnAround.OnMovementKeyPressed)
            Events.OnKeyPressed.Remove(manageTurnAround.OnMovementKeyReleased) 
            Events.OnKeyKeepPressed.Remove(manageTurnAround.OnMovementKeyKeepPressed) 
            Events.OnPlayerUpdate.Remove(manageSneaking.OnPlayerUpdate)
            ADDED_TO_EVENTS = false
        end      
    end        
end


Events.OnGameStart.Add(mainStartFunction) -- load data and equip correct items whenever player starts or loads a game














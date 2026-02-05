-- when players briefly tap a movement button so that their character turns around but does not move, we equip the "turn" penis model for male characters; default penis model will look glitchy when doing 
-- this; the glitch of the default model is caused by the bones it is attached; since I wasn't able to find bone attachments where the model looks good in all cases, I try to solve the issue manual;
-- can be disabled in Sandbox by selecting "Performance Mode"
--
--
-- by razab





local manageBody = require("ManageBody/RasBodyModManageBodyIG")
local manageSneaking = require("ManageBody/RasBodyModManageSneaking")



-- some local variables used in this .lua:
local IS_MOVING = false
local PLAYER_DIR = nil
local UPDATE_TURN = false
local OLD_KEY = nil



-- will store key bindings: 
local KEY_FORWARD = nil
local KEY_LEFT = nil
local KEY_BACK = nil
local KEY_RIGHT = nil
local movementKey = {} -- will contain info about movements keys WASD (which key is pressed, how long, direction player is facing)


-- initialise keys when game starts (should be done OnGameStart; otherwise there will be strange behavior when PZ is booted while the mod is active)
local function onStart()
  KEY_FORWARD = getCore():getKey("Forward")
  KEY_LEFT = getCore():getKey("Left")
  KEY_BACK = getCore():getKey("Backward")
  KEY_RIGHT = getCore():getKey("Right")
 
  movementKey[KEY_FORWARD] = {pressed = false, time = 0, cancel = false, direction = "NW"} -- W key (with default key binding)
  movementKey[KEY_LEFT] = {pressed = false, time = 0, cancel = false, direction = "SW"} -- A key
  movementKey[KEY_BACK] = {pressed = false, time = 0, cancel = false, direction = "SE"} -- S key
  movementKey[KEY_RIGHT] = {pressed = false, time = 0, cancel = false, direction = "NE"} -- D key
end

Events.OnGameStart.Add(onStart)




-- equip the normal penis after player has turned
local function equipDefaultPenisLater(player, key)
          
          local delay = 655 -- approximately the time the turning-around animation seems to take in ms
           
          local startTime = nil               
          local function equipAfterDelay(tick)
              if (not startTime) or UPDATE_TURN then
                   startTime = getTimestampMs()
                   UPDATE_TURN = false
              end

              if getTimestampMs() >= startTime + delay or IS_MOVING or (movementKey[key] and movementKey[key]["cancel"]) then 
                    local data = player:getModData().RasBodyMod 
                    if player:isSneaking() and (not player:isAiming()) and (not player:isSitOnGround()) and (not player:getVehicle()) and 
                       player:checkIsNearWall() >= 1 and manageSneaking.isValid(player) then -- can be true if player presses sneak button while turning around
                            data.PlayerMode = "cover" -- in this case, equip the CrouchWall version of the penis
                    else
                        data.PlayerMode = "default"
                    end
                    manageBody.ManageMalePrivatePart(player, false) -- re-equip the old penis
                    if movementKey[key] then                      
                       movementKey[key]["cancel"] = false
                    end       
                    Events.OnTick.Remove(equipAfterDelay) -- remove function from event                 
              end
         end
         Events.OnTick.Add(equipAfterDelay)
end                                    


-- next function checks whether we have a TimedAction which should block equipping the TurnAround penis; actionExceptions contain actions where TurnAround penis should still be equpped
local actionExceptions = {}
actionExceptions["ISEquipWeaponAction"] = true
actionExceptions["ISUnequipAction"] = true
actionExceptions["ISAttachItemHotbarAction"] = true
actionExceptions["ISDetachItemHotbarAction"] = true
actionExceptions["ISEatFoodAction"] = true
local function isValid(player)
     local action = ISTimedActionQueue.getTimedActionQueue(player).queue[1]
     if action == nil then
           return true
     elseif actionExceptions[action.Type] then
           return true
     end

     return false
end




local manageTurnAround = {} -- can be accessed via require("ManageBody/RasBodyModManageTurnAround") by other .lua files from client


-- check which key the player presses and store some data about it
function manageTurnAround.OnMovementKeyPressed(key)

    local player = getPlayer()
    if (not player:isFemale()) and (not player:isSitOnGround()) and (not player:getVehicle()) and movementKey[key] then
          local time = getTimestampMs()
          local oldTime = 0
          if OLD_KEY then
               oldTime = movementKey[OLD_KEY]["time"]
          end
          movementKey[key]["pressed"] = true -- update info about pressed key  
          movementKey[key]["time"] = time
          movementKey[key]["cancel"] = false                          
          PLAYER_DIR = player:getDir():toString()                  
          if time - oldTime < 200 then -- in case player presses buttons in rapid succession, we cancel the process for buttons pressed previously
                movementKey[OLD_KEY]["cancel"] = true
          end
          OLD_KEY = key                                                 
    end
end


-- here we check whether a key has shortly been tapped to apply the procedure for turning aroung
function manageTurnAround.OnMovementKeyReleased(key)
  
    local player = getPlayer()   
    if (not player:isFemale()) and (not player:isSitOnGround()) and (not player:getVehicle()) and movementKey[key] then 
               movementKey[key]["pressed"] = false
               if (not player:isAiming()) and (not player:isSneaking()) then                                                               
                        if not movementKey[KEY_FORWARD]["pressed"] and not movementKey[KEY_LEFT]["pressed"] and not movementKey[KEY_BACK]["pressed"] and not movementKey[KEY_RIGHT]["pressed"]  then 
                             IS_MOVING = false
                        end

                        -- in case a movement key has been shortly tapped triggering the turn-around animation...
                        if not IS_MOVING and (getTimestampMs() - movementKey[key]["time"] < 200) and movementKey[key]["direction"] ~= PLAYER_DIR and (not movementKey[key]["cancel"]) 
                           and isValid(player) then 
                                  local data = player:getModData().RasBodyMod
                                  if data.PlayerMode ~= "turn" then   
                                      data.PlayerMode = "turn"                        
                                      manageBody.ManageMalePrivatePart(player, false) -- equip the TurnAround penis 
                                      equipDefaultPenisLater(player, key) -- re-equip default penis after some delay     
                                  else
                                      UPDATE_TURN = true --prolong equippment of turnAround penis
                                  end                                  
                        end      
               end            
   end
end


-- checks whether player keeps movement key pressed for moving
function manageTurnAround.OnMovementKeyKeepPressed(key)

    local player = getPlayer()
    if (not player:isFemale()) and (not player:getVehicle()) and (not player:isSitOnGround()) and movementKey[key] and (not IS_MOVING) and (getTimestampMs() - movementKey[key]["time"] >= 200) then  
             IS_MOVING = true
    end 
end


-- make sure that KEY_FORWARD, KEY_LEFT etc. have the correct values in case players change key bindings during game; is called in this mod's file client/OptionScreens/RasBodyModUpdateKeyBinding.lua
function manageTurnAround.UpdateLocals()

     KEY_FORWARD = getCore():getKey("Forward")
     KEY_LEFT = getCore():getKey("Left")
     KEY_BACK = getCore():getKey("Backward")
     KEY_RIGHT = getCore():getKey("Right")

     movementKey = {}
     movementKey[KEY_FORWARD] = {pressed = false, time = 0, cancel = false, direction = "NW"} 
     movementKey[KEY_LEFT] = {pressed = false, time = 0, cancel = false, direction = "SW"} 
     movementKey[KEY_BACK] = {pressed = false, time = 0, cancel = false, direction = "SE"} 
     movementKey[KEY_RIGHT] = {pressed = false, time = 0, cancel = false, direction = "NE"}

     OLD_KEY = nil
end



return manageTurnAround



 





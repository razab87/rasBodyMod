-- when players are sneaking near a wall/fence so that their character goes into a take-cover position, we equip a different penis model which looks better than the default model in such a situation; there will be two 
-- different models: one for crouch-walking and one for standing still while crouching; the default model will cause visual glitches in those situations which is due to the bones it is attached to; since I wasn't able 
-- to find bone attachments where the model looks good in all cases, I try to solve the issue manually;
-- can be disabled in Sandbox by choosing "Performance Mode"
--
--
-- by razab



local manageBody = require("ManageBody/RasBodyModManageBodyIG") 


-- equip a penis model with some delay
local function equipPenisWithDelay(player, delay)

         local startTime = nil
         local function equip(tick)
              if not startTime then
                   startTime = getTimestampMs()
              end
             
              if getTimestampMs() >= startTime + delay then
                   manageBody.ManageMalePrivatePart(player, false)
                   Events.OnTick.Remove(equip) -- remove from event
              end 
         end
         Events.OnTick.Add(equip)
end



local manageSneaking = {} -- can be accessed via require("ManageBody/RasBodyModManageSneaking") by other .lua files from client


-- next function checks whether we have a TimedAction which should block equipping the Crouch penis; actionExceptions contain actions for which it should not be blocked (but
-- we block for most actions to keep things simple)
local actionExceptions = {}
actionExceptions["ISEquipWeaponAction"] = true
actionExceptions["ISUnequipAction"] = true
actionExceptions["ISWearClothing"] = true
actionExceptions["ISAttachItemHotbarAction"] = true
actionExceptions["ISDetachItemHotbarAction"] = true
actionExceptions["ISEatFoodAction"] = true
function manageSneaking.isValid(player)
       local action = ISTimedActionQueue.getTimedActionQueue(player).queue[1]
       if action == nil then
            return true
       elseif actionExceptions[action.Type] then
            return true
       end

       return false
end


-- equip/unequip the cover version of the penis model; is added to event "OnPlayerUpdate" in RasBodyModCreatePlayer.lua
function manageSneaking.OnPlayerUpdate(player)

    if (not player:isFemale()) then 
            if player:getVehicle() then -- make sure the default penis is equipped if player is within a vehicle
                      local data = player:getModData().RasBodyMod
                      if data.PlayerMode ~= "default" then 
                           data.PlayerMode = "default"
                           equipPenisWithDelay(player, 0) -- equip default penis
                      end
            elseif (not player:isSitOnGround()) then   
                      local data = player:getModData().RasBodyMod                   
                      if player:isSneaking() then -- while player is sneaking
                            if player:checkIsNearWall() >= 1 and (not player:isAiming()) and manageSneaking.isValid(player) then 
                                  if player:isPlayerMoving() then
                                      if data.PlayerMode ~= "coverWalk" then
                                           data.PlayerMode = "coverWalk"
                                           equipPenisWithDelay(player, 180) -- equip coverWalk penis
                                      end
                                  else
                                      if data.PlayerMode ~= "cover" then
                                          data.PlayerMode = "cover"
                                          equipPenisWithDelay(player, 180) -- equip cover penis
                                      end
                                  end     
                            elseif data.PlayerMode == "cover" or data.PlayerMode == "coverWalk" then
                                     data.PlayerMode = "default"
                                     equipPenisWithDelay(player, 180) -- equip default penis
                            end 
                     else -- when not sneaking, re-equip default model
                         if (data.PlayerMode == "cover" or data.PlayerMode == "coverWalk") then
                             data.PlayerMode = "default"
                             equipPenisWithDelay(player, 200) -- equip default penis
                         end
                     end            
            end
     end
end



return manageSneaking




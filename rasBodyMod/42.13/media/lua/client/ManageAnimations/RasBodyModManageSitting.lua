-- if a male character sits on ground, we equip a different penis model for better visuals; modifies vanilla a function from ISWorldObjectContextMenu.lua, client/ISUI
--
--
-- by razab






local util = require("ManageAnimations/RasBodyModAnimUtil.lua")


local MOVEMENT_PRESSED = false



-- is called when player starts sitting
local function onSittingStarted(player)

   local delay = 900 -- old 990
   local speed = getGameSpeed()
   if speed == 2 then -- adjust in case player does not choose default game speed
      delay = delay / 4
   elseif speed == 3 then
      delay = delay / 9
   elseif speed == 4 then
      delay = delay / 16
   end

   local startTime = nil
   local function equipSittingPenis(tick) -- equip sitting version of penis with some delay when player goes into sitting animation

         if not startTime then
               startTime = getTimestampMs()  
         end

         if getTimestampMs() >= startTime + delay then  
                Events.OnTick.Remove(equipSittingPenis) -- remove from onTick event
                if not MOVEMENT_PRESSED and player:isSitOnGround() then
                    local data = player:getModData()
                    data.RasBodyMod.PlayerMode = "sit"                         
                    util.equipNow(player) -- will actually equip the model 
                end                                                   
         end
   end
   Events.OnTick.Add(equipSittingPenis)
end


-- is called when player stops sitting and sneaking near a wall (to equip CrouchWall penis model)
local function crouchNearWall(player)

       local delay = 1200
       local speed = getGameSpeed()
       if speed == 2 then
          delay = delay / 4
       elseif speed == 3 then
          delay = delay / 9
       elseif speed == 4 then
          delay = delay / 16
       end

       local startTime = nil
       local function equipCrouchPenis(tick) -- equip cover model with some delay
              
              if not startTime then
                   startTime = getTimestampMs()
              end

              if getTimestampMs() >= startTime + delay then
                      Events.OnTick.Remove(equipCrouchPenis) -- remove from OnTick event
                      local data = player:getModData()
                      data.RasBodyMod.PlayerMode = "cover"
                      util.equipNow(player) -- will actually equip the model 
              end
       end
       Events.OnTick.Add(equipCrouchPenis)

end


-- is called when player cancels sitting and starts moving (triggered by event OnPlayerMove)
local function onSittingEnded(player)               

       MOVEMENT_PRESSED = true -- in case player aborts sitting before sitting penis is equipped (i.e. within 900ms after pressing "Sit on Ground")

       local delay = 825
       local speed = getGameSpeed()
       if speed == 2 then
          delay = delay / 4
       elseif speed == 3 then
          delay = delay / 9
       elseif speed == 4 then
          delay = delay / 16
       end

       local startTime = nil
       local function equipDefaultPenis(tick) -- re-equip default penis with some delay
              
              if not startTime then
                   startTime = getTimestampMs()
              end

              if getTimestampMs() >= startTime + delay then
                      Events.OnTick.Remove(equipDefaultPenis) -- remove from OnTick event
                      local data = player:getModData()
                      data.RasBodyMod.PlayerMode = "default"
                      util.equipNow(player) -- will actually equip the model 
                      if player:isSneaking() and player:checkIsNearWall() >= 1 and (not SandboxVars.RasBodyMod.PerformanceMode) then -- if player stops sitting and is sneaking near a wall...
                           crouchNearWall(player)
                      end                      
              end
       end
       Events.OnTick.Add(equipDefaultPenis)
end


local function checkForSittingEnded(tick)

    local player = getPlayer()
    local anim = player:getAnimationStateName()
    if anim == "getup" then -- "getup" is the animState when player goes in the "get up from ground sitting" animation
        Events.OnTick.Remove(checkForSittingEnded) -- remove from event
        onSittingEnded(player) -- equip default penis
    end
end


-- modify the vanilla function which is called when player starts sitting on ground
local vanilla_onSitOnGround = ISWorldObjectContextMenu.onSitOnGround
function ISWorldObjectContextMenu.onSitOnGround(player, ...)
        
    vanilla_onSitOnGround(player, ...) -- execute vanilla code
    
    -- whenever a male character goes into the sitting animation, we trigger appropriate penis managament
    local playerObj = getSpecificPlayer(player)    
	if not playerObj:isFemale() then            

           MOVEMENT_PRESSED = false

           onSittingStarted(playerObj) -- equip sitting penis model
           Events.OnTick.Add(checkForSittingEnded) -- check whether sitting animation ends
	end	
end











-- contains several functions which manage the body while game is running (i.e. equip correct skin, body hair, penis model; make sure dirtyness/bloodyness patterns on player body
-- behave correctly)
--
--
-- by razab




local rasSharedData = require("RasBodyModSharedData")

local Regs = RasBodyModRegistries



-- util function: will be used to temporarily reduce weight of some inventory items when new body items are equipped; otherwise there can be problems in case 
-- players somehow manage to surpass their inventory weight limit of 50
local function reduceInvWeight(player, playerInv, backUp)

      local invCapacity = playerInv:getCapacity()
      if player:getInventoryWeight() >= invCapacity then 
           local items = playerInv:getItems()                  
           for i=1,items:size() do
               local item = items:get(i-1)  
               --sendClientCommand(player, "rasBodyMod", "reduceWeight", { item = item })  
               table.insert(backUp, {item = item, weight = item:getWeight(), actualWeight = item:getActualWeight()}) 
               item:setWeight(0)
               item:setActualWeight(0)                      
               if player:getInventoryWeight() < invCapacity then
                      break;
               end
           end 
     end
end

-- restore the weight
local function restoreWeight(player, playerInv, backUp)

    for _,v in pairs(backUp) do
        local item = v.item
        item:setWeight(v.weight)
        item:setActualWeight(v.actualWeight)
    end
end



-- util function: check whether player torso is nude so that we have to apply the vest glitch fix
local function torsoNude(player)

     local locations = rasSharedData.TorsoLocations
     for _,loc in pairs(locations) do
              local theLocation = ItemBodyLocation.get(ResourceLocation.of(loc))
              if theLocation then
                 local item = player:getWornItem(theLocation)                          
                 if item and not rasSharedData.TorsoLocationsException[item:getFullType()] then
                    return false
                 end
              end
     end 

     return true
end





local manageBody = {} -- can be accessed via require("ManageBody/RasBodyModManageBodyIG")



-- fix for a small visual bug related to bullet proof vest and similar items: when players groin area is nude and a bullt proof
-- vest is equipped, there appears a glitchy black bar in the pubic hair area; is somehow (?) caused by the masking system for the vest
-- solution: in this situation, exchange the visuals of the vanilla vest with a modded vest which uses different mask definition so that the glitch
-- disappears
function manageBody.VestGlitchFix(player)

      local locations = {ItemBodyLocation.TORSO_EXTRA_VEST_BULLET, ItemBodyLocation.TORSO_EXTRA_VEST}
      for _,loc in pairs(locations) do
              local item = player:getWornItem(loc)
              if item and rasSharedData.GlitchedItems[item:getFullType()] then
                     local visual = item:getVisual()                    
                     if visual then
                         local visualType = visual:getItemType()
                         if rasSharedData.GlitchedItems[visualType] then
                              if torsoNude(player) then                              
                                    local newItem = rasSharedData.GlitchedItems[visualType]
                                    local texture = visual:getTextureChoice()
                                    
                                    visual:setItemType(newItem) 
                                    visual:setClothingItemName(newItem)
                                    if texture then
			                             visual:setTextureChoice(texture) -- also apply correct extra texture ("Type 1", "Type 2" etc)
                                    end
                              end
                         elseif rasSharedData.GlitchedItemsReverse[visualType] then
                              if not torsoNude(player) then
                                     local newItem = rasSharedData.GlitchedItemsReverse[visualType]
                                     local texture = visual:getTextureChoice()

                                     visual:setItemType(newItem) 
                                     visual:setClothingItemName(newItem)
                                     if texture then
			                             visual:setTextureChoice(texture)
                                     end
                              end
                         end
                   end
              end
      end
end


-- this function is called only once a new game starts (called in client/RasBodyModCreatePlayer.lua); ensures that
-- player starts with a vanilla vest (glitch fix will then be applied as a second step)
function manageBody.VestGlitchFixNewGame(player)

     local locations = {ItemBodyLocation.TORSO_EXTRA_VEST_BULLET, ItemBodyLocation.TORSO_EXTRA_VEST}
     for _,loc in pairs(locations) do
           local item = player:getWornItem(loc)
           if item then 
                local newItem = rasSharedData.GlitchedItemsReverse[item:getFullType()]
                if newItem then                     
                     local playerInv = player:getInventory()
                     playerInv:Remove(item) 
                     player:setWornItem(loc, nil)
                     local vest = instanceItem(newItem)
                     playerInv:addItem(vest)
                     player:setWornItem(loc, vest)                                     
                end
           end
     end 
end



-- equips the correct skin (only called once when game starts in RasBodyModCreatePlayer)
function manageBody.EquipSkin(player) 
    local data = player:getModData().RasBodyMod
    local gender = "Male"
    if player:isFemale() then
         gender = "Female"
    end
    local playerInv = player:getInventory()

    local backUp = {}
    reduceInvWeight(player, playerInv, backUp) -- temporarily reduce inventory weight (restored below) 
             
    -- equip the correct skin:
    local skin = player:getWornItem(Regs.Skin)
    if not skin then 
        local skinItem = rasSharedData.Skins[gender][data.SkinColorIndex]
        skin = instanceItem(skinItem)
        player:setWornItem(Regs.Skin, skin)
    end

    if skin then
       playerInv:Remove(skin) -- remove skin from inventory (will still be worn)
    end

    restoreWeight(player, playerInv, backUp) -- restore weight values of items 
end



-- equip correct body hair item
function manageBody.EquipBodyHair(player, bodyLocation)
         
     local locID = rasSharedData.ModLocationID

     local data = player:getModData().RasBodyMod  
     local skinColor = data.SkinColorIndex
     local gender = "Male"
     if player:isFemale() then
          gender = "Female"
     end
     local playerInv = player:getInventory()

     local backUp = {}
     reduceInvWeight(player, playerInv, backUp) -- temporarily reduce inventory weight when it exceeds limit (restored below)

     -- equip the body hair item
     local oldItem = player:getWornItem(bodyLocation)
     local newItem = nil
     local hairItem = data[locID[bodyLocation]]

     if hairItem == "None" then
          player:setWornItem(bodyLocation, nil)
     else

          -- some skin colors might get slightly different hair items for better visuals
          local optimizedItem = hairItem
          local optimizedTable = rasSharedData.OptimizedBodyHair[gender]
          if optimizedTable[skinColor] then
                optimizedItem = hairItem .. "_" .. optimizedTable[skinColor]
          end         
          
          local item = instanceItem(optimizedItem)
          if not item then  -- if optimized version doesn't exist, take default version
               item = instanceItem(hairItem)
          end

          player:setWornItem(bodyLocation, item) -- equip item
          newItem = item
     end

     if oldItem then
          playerInv:Remove(oldItem) -- remove from inventory
     end
     if newItem then
         playerInv:Remove(newItem)
     end 

     restoreWeight(player, playerInv, backUp) -- restore weight values of items        
end



-- apply beard stubble
function manageBody.EquipBeardStubble(player)

    if not player:isFemale() then
        
          local data = player:getModData().RasBodyMod               
          local playerInv = player:getInventory() 

          local backUp = {}          
          reduceInvWeight(player, playerInv, backUp) -- temporarily reduce inventory weight when it exceeds limit (restored below)
        
          local oldStubble = player:getWornItem(Regs.BeardStubble)
          local currentBeard = getBeardStylesInstance():FindStyle(player:getHumanVisual():getBeardModel())
          local beardID = nil
          if currentBeard then
               beardID = currentBeard:getName()
          end 

          if rasSharedData.FullBeards[beardID] then -- never show stubble if player has full beard (for better visuals)
                player:setWornItem(Regs.BeardStubble, nil) 
                --if oldStubble then
                --     playerInv:Remove(oldStubble)
                --end
                data.BeardStubble = 1 -- full beard will always have stubbles (though not visibile)
          elseif data.BeardStubble == 0 then
                  player:setWornItem(Regs.BeardStubble, nil)
                  --if oldStubble then 
                  --  playerInv:Remove(oldStubble)
                  --end
          elseif oldStubble == nil and data.BeardStubble == 1 then
                 local stubble = instanceItem("RasBodyMod.StubbleBeard_Light")
                 if data.SkinColorIndex == 4 or data.SkinColorIndex == 5 then
                     stubble = instanceItem("RasBodyMod.StubbleBeard_Dark")
                 end
		         player:setWornItem(Regs.BeardStubble, stubble)
                 playerInv:Remove(stubble)
          end

          if oldStubble then
               playerInv:Remove(oldStubble)
          end

          restoreWeight(player, playerInv, backUp) -- restore weight values of items
    end
end



-- apply head stubble (only called once when game starts in RasBodyModCreatePlayer.lua)
function manageBody.EquipHeadStubble(player)
        
          local data = player:getModData().RasBodyMod 

          if data.HeadStubble == 1 then   

                  local playerInv = player:getInventory()

                  local oldStubble = player:getWornItem(Regs.HeadStubble)
                  if oldStubble then
                      playerInv:Remove(oldStubble) -- remove from inventory (will sill be worn)
                  else                    
                      local backUp = {} 
                      reduceInvWeight(player, playerInv, backUp) -- temporarily reduce inventory weight (restored below)

                      if player:isFemale() then
                              local stubble = instanceItem("RasBodyMod.StubbleHead_Light_F")
                              if data.SkinColorIndex == 4 or data.SkinColorIndex == 5 then
                                    stubble = instanceItem("RasBodyMod.StubbleHead_Dark_F")
                              end
	                          player:setWornItem(Regs.HeadStubble, stubble)
                              playerInv:Remove(stubble) -- remove from inventory (will sill be worn)
                      else
                              local stubble = instanceItem("RasBodyMod.StubbleHead_Light_M")
                              if data.SkinColorIndex == 4 or data.SkinColorIndex == 5 then
                                    stubble = instanceItem("RasBodyMod.StubbleHead_Dark_M")
                              end
	                          player:setWornItem(Regs.HeadStubble, stubble)
                              playerInv:Remove(stubble) -- remove from inventory (will sill be worn)
                     end
                      
                     restoreWeight(player, playerInv, backUp) -- restore weight values of items
                 end
          end
end





-- check whether character wears an exceptional clothing item while in game (is used by ManageMalePrivatePart below)
local function wearsExceptionalClothing(player, mode)

      local myTable = rasSharedData.ExceptionalClothes
      
      local locationGroup = BodyLocations.getGroup("Human") 
      for bodyLocation,_ in pairs(myTable) do
               local loc = ItemBodyLocation.get(ResourceLocation.of(bodyLocation))
               if loc then
                       local item = player:getWornItem(loc)
                       if item then
                              local itemName = item:getFullType()
                              if myTable[bodyLocation][itemName] then
                                      if myTable[bodyLocation][itemName][mode] then
                                             return true
                                      end
                              end
                       end
               end
      end 

      return false
end



-- equip or unequip suitable penis model while in game
local EXCEPTIONAL_DEFAULT = nil
local EXCEPTIONAL_SITTING = nil
local DATA_INITIALISED = false
function manageBody.ManageMalePrivatePart(player, calledByClothingUpdate)
      if not player:isFemale() then

             -- in case the function is called by a clothingUpdate, we update info about exceptional clothing
             if (not DATA_INITIALISED) or calledByClothingUpdate then
                  EXCEPTIONAL_DEFAULT = wearsExceptionalClothing(player, "hideWhileStanding")
                  EXCEPTIONAL_SITTING = wearsExceptionalClothing(player, "hideWhileSitting")
                  DATA_INITIALISED = true
             end

             local data = player:getModData().RasBodyMod               
             local playerInv = player:getInventory()           

                 
             local backUp = {}
             reduceInvWeight(player, playerInv, backUp) -- temporarily reduce inventory weight (restored below)


             -- now equip the corrcet penis model
             local oldPenis = player:getWornItem(Regs.MalePrivatePart)
             local newPenis = nil

             local wearsExceptionalClothes = EXCEPTIONAL_DEFAULT
             if data.PlayerMode ~= "default" and data.PlayerMode ~= "turn" then
                   wearsExceptionalClothes = EXCEPTIONAL_SITTING
             end 

             if wearsExceptionalClothes then
                   player:setWornItem(Regs.MalePrivatePart, nil)
                   data.PenisType = "None"
             else
                   local itemID = rasSharedData.PenisTable[data.SkinColorIndex][data.PlayerMode]
                   if data.PlayerMode == "default" or data.PlayerMode == "turn" then -- those cases have special hairy variants
                          if data.RasPubicHair ~= "None" then
                                   itemID = itemID .. "_Hair"
                          end
                   end
                   if data.PenisType ~= itemID then
                        newPenis = instanceItem(itemID)
                        player:setWornItem(Regs.MalePrivatePart, newPenis)
                        data.PenisType = itemID
                   end   
             end


             if oldPenis then
                 playerInv:Remove(oldPenis) -- remove from inventory
             end
             if newPenis then
                 playerInv:Remove(newPenis)
             end  

             restoreWeight(player, playerInv, backUp) -- restore weight values of items                                  
      end
end



-- this function transfers all blood and dirt from the skin to the player's body so that the "wash yourself" option is shown properly
-- when the skin is dirty; will also store dirtyness when game is saved and loaded; is done on every clothingUpdate
function manageBody.TransferDirtToBody(player)
       local visual = player:getHumanVisual()
       local skin = player:getWornItem(Regs.Skin)
       if skin and visual then
          local coveredParts = BloodClothingType.getCoveredParts(skin:getBloodClothingType())
          for i=1,coveredParts:size() do
	         local part = coveredParts:get(i-1)
	         visual:setBlood(part, skin:getBlood(part))
	         visual:setDirt(part, skin:getDirt(part))
          end
       end
end



-- some of the functions from this lua need to be executed OnClothingUpdate
function manageBody.onClothingUpdate(player)

    if (not isServer()) and player then -- only in single player or on client side
        if isClient() then
            manageBody.EquipHeadStubble(player)
            manageBody.EquipSkin(player)
            for v,_ in pairs(rasSharedData.BodyHairLocations) do
                manageBody.EquipBodyHair(player, v)
            end
        end
        manageBody.VestGlitchFix(player)
        manageBody.EquipBeardStubble(player)
        manageBody.TransferDirtToBody(player)
        manageBody.ManageMalePrivatePart(player, true) -- parameter "true" tells the function that it should check for exceptionalClothes
    end      
end

Events.OnClothingUpdated.Add(manageBody.onClothingUpdate) -- call whenever smth about clothes changes 





return manageBody





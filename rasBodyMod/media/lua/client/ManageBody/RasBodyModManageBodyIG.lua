-- contains several functions which manage the body while game is running (i.e. equip correct skin, body hair, penis model; make sure dirtyness/bloodyness patterns on player body
-- behave correctly)
--
--
-- by razab




local rasSharedData = require("RasBodyModSharedData")



-- util function: will be used to temporarily reduce weight of some inventory items when new body items are equipped; otherwise there can be problems in case 
-- players somehow manage to surpass their inventory weight limit of 50
local function reduceInvWeight(player, playerInv, backUpItems)

      local invCapacity = playerInv:getCapacity()
      if player:getInventoryWeight() >= invCapacity then 
           local items = playerInv:getItems()                  
           for i=1,items:size() do
               local item = items:get(i-1)                            
               table.insert(backUpItems, {theItem = item, actualWeight = item:getActualWeight(), weight = item:getWeight()} )
               item:setActualWeight(0) -- lower weight of some items until overall weight is less than limit
               item:setWeight(0)
               if player:getInventoryWeight() < invCapacity then
                      break;
               end
           end 
     end
end


-- util function: check whether player torso is nude so that we have to apply the vest glitch fix
local function torsoNude(player)

     local locations = rasSharedData.TorsoLocations
     for _,loc in pairs(locations) do
              local item = player:getWornItem(loc)                          
              if item and not rasSharedData.TorsoLocationsException[item:getFullType()] then
                  return false
              end
     end 

     return true
end




local manageBody = {} -- can be accessed via require("ManageBody/RasBodyModManageBodyIG") in other client files



-- fix for a small visual bug related to bullet proof vest and similar items: when players groin area is nude and a bullt proof
-- vest is equipped, there appears a glitchy black bar in the pubic hair area; is somehow (?) caused by the masking system for the vest
-- solution: in this situation, exchange the visuals of the vanilla vest with a modded vest which uses different mask definition so that the glitch
-- disappears
function manageBody.VestGlitchFix(player)

      local loc = "TorsoExtraVest"
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

Events.OnClothingUpdated.Add(manageBody.VestGlitchFix) -- apply when smth about clothing changes





-- this function is called only once a new game starts (called in client/RasBodyModCreatePlayer.lua); ensures that
-- player starts with a vanilla vest (glitch fix will then be applied as a second step)
function manageBody.VestGlitchFixNewGame(player)

       local loc = "TorsoExtraVest"
       local item = player:getWornItem(loc)
       if item then 
            local newItem = rasSharedData.GlitchedItemsReverse[item:getFullType()]
            if newItem then                     
                 local playerInv = player:getInventory()
                 playerInv:Remove(item) 
                 player:setWornItem(loc, nil)
                 local vest = InventoryItemFactory.CreateItem(newItem)
                 playerInv:addItem(vest)
                 player:setWornItem(loc, vest)                                     
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


    local backUpItems = {}
    reduceInvWeight(player, playerInv, backUpItems) -- temporarily reduce inventory weight (restored below) 
         
         
    -- equip the correct skin:
    local skin = player:getWornItem("RasSkin")
    if not skin then 
        local skinItem = rasSharedData.Skins[gender][data.SkinColorIndex]
        skin = InventoryItemFactory.CreateItem(skinItem)
        player:setWornItem("RasSkin", skin)
    end

    if skin then
       playerInv:Remove(skin) -- remove skin from inventory (will still be worn)
    end


    for _,v in pairs(backUpItems) do -- restore weight values of items
          v.theItem:setWeight(v.weight)
          v.theItem:setActualWeight(v.actualWeight)                    
    end
   
end


-- equip correct body hair item
function manageBody.EquipBodyHair(player, bodyLocation)
         
     local data = player:getModData().RasBodyMod  
     local skinColor = data.SkinColorIndex
     local gender = "Male"
     if player:isFemale() then
          gender = "Female"
     end
     local playerInv = player:getInventory()


     local backUpItems = {} 
     reduceInvWeight(player, playerInv, backUpItems) -- temporarily reduce inventory weight (restored below)


     -- equip the body hair item
     local oldItem = player:getWornItem(bodyLocation)
     local newItem = nil
     local hairItem = data[bodyLocation]

     if hairItem == "None" then
          player:setWornItem(bodyLocation, nil)
     else

          -- some skin colors might get slightly different hair items for better visuals
          local optimizedItem = hairItem
          local optimizedTable = rasSharedData.OptimizedBodyHair[gender]
          if optimizedTable[skinColor] then
                optimizedItem = hairItem .. "_" .. optimizedTable[skinColor]
          end         
          
          local item = InventoryItemFactory.CreateItem(optimizedItem)
          if not item then  -- if optimized version doesn't exist, take default version
               item = InventoryItemFactory.CreateItem(hairItem)
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


     for _,v in pairs(backUpItems) do -- restore weight values of items
         v.theItem:setWeight(v.weight)
         v.theItem:setActualWeight(v.actualWeight)                    
     end         
end



-- apply beard stubble
function manageBody.EquipBeardStubble(player)

    if not player:isFemale() then
        
          local data = player:getModData().RasBodyMod               
          local playerInv = player:getInventory() 


          local backUpItems = {}          
          reduceInvWeight(player, playerInv, backUpItems) -- temporarily reduce inventory weight (restored below)

        
          local oldStubble = player:getWornItem("RasBeardStubble")
          local currentBeard = getBeardStylesInstance():FindStyle(player:getHumanVisual():getBeardModel())
          local beardID = nil
          if currentBeard then
               beardID = currentBeard:getName()
          end 

          local improvedHairMenuActive = false     -- simplify beard stubble management when mod "Improved Hair Menu" is active; this mod overwrites critical vanilla functions, so we disable some features
          local modInfo = getModInfoByID("improvedhairmenu")  
          if modInfo and isModActive(modInfo) then            
             improvedHairMenuActive = true
          end

          if (not improvedHairMenuActive) and rasSharedData.FullBeards[beardID] then -- never show stubble if player has full beard (for better visuals); always show with Improved Hair Menu
                player:setWornItem("RasBeardStubble", nil) 
                if oldStubble then
                     playerInv:Remove(oldStubble)
                end
                data.BeardStubble = 1 -- full beard will always have stubbles (though not visibile)
          elseif data.BeardStubble == 0 then
                  player:setWornItem("RasBeardStubble", nil)
                  if oldStubble then 
                    playerInv:Remove(oldStubble)
                  end
          elseif oldStubble == nil and data.BeardStubble == 1 then
                 local stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleBeard_Light")
                 if data.SkinColorIndex == 4 or data.SkinColorIndex == 5 then
                     stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleBeard_Dark")
                 end
		         player:setWornItem("RasBeardStubble", stubble)
                 playerInv:Remove(stubble)
          end


          for _,v in pairs(backUpItems) do -- restore weight values of items
             v.theItem:setWeight(v.weight)
             v.theItem:setActualWeight(v.actualWeight)                    
          end
    end
end

Events.OnClothingUpdated.Add(manageBody.EquipBeardStubble) -- is always called when smth about beard changes 




-- apply head stubble (only called once when game starts in RasBodyModCreatePlayer.lua)
function manageBody.EquipHeadStubble(player)
        
          local data = player:getModData().RasBodyMod 

          if data.HeadStubble == 1 then   

                  local playerInv = player:getInventory()

                  local oldStubble = player:getWornItem("RasHeadStubble")
                  if oldStubble then
                      playerInv:Remove(oldStubble) -- remove from inventory (will sill be worn)
                  else           
                      local backUpItems = {}          
                      reduceInvWeight(player, playerInv, backUpItems) -- temporarily reduce inventory weight (restored below)
                    

                      if player:isFemale() then
                              local stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleHead_Light_F")
                              if data.SkinColorIndex == 4 or data.SkinColorIndex == 5 then
                                    stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleHead_Dark_F")
                              end
	                          player:setWornItem("RasHeadStubble", stubble)
                              playerInv:Remove(stubble) -- remove from inventory (will sill be worn)
                      else
                              local stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleHead_Light_M")
                              if data.SkinColorIndex == 4 or data.SkinColorIndex == 5 then
                                    stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleHead_Dark_M")
                              end
	                          player:setWornItem("RasHeadStubble", stubble)
                              playerInv:Remove(stubble) -- remove from inventory (will sill be worn)
                     end


                     for _,v in pairs(backUpItems) do -- restore weight values of items
                        v.theItem:setWeight(v.weight)
                        v.theItem:setActualWeight(v.actualWeight)                    
                     end
                 end
          end
end





-- check whether character wears an exceptional clothing item while in game (is used by ManageMalePrivatePart below)
local function wearsExceptionalClothing(player, mode)

      local myTable = rasSharedData.ExceptionalClothes
      
      local locationGroup = BodyLocations.getGroup("Human") 
      for bodyLocation,_ in pairs(myTable) do
               if locationGroup:getLocation(bodyLocation) then
                       local item = player:getWornItem(bodyLocation)
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

             
             local backUpItems = {}          
             reduceInvWeight(player, playerInv, backUpItems) -- temporarily reduce inventory weight (restored below)


             -- now equip the corrcet penis model
             local oldPenis = player:getWornItem("RasMalePrivatePart")
             local newPenis = nil

             local wearsExceptionalClothes = EXCEPTIONAL_DEFAULT
             if data.PlayerMode ~= "default" and data.PlayerMode ~= "turn" then
                   wearsExceptionalClothes = EXCEPTIONAL_SITTING
             end 

             if wearsExceptionalClothes then
                   player:setWornItem("RasMalePrivatePart", nil)
                   data.PenisType = "None"
             else
                   local itemID = rasSharedData.PenisTable[data.SkinColorIndex][data.PlayerMode]
                   if data.PlayerMode == "default" or data.PlayerMode == "turn" then -- those cases have special hairy variants
                          if data.RasPubicHair ~= "None" then
                                   itemID = itemID .. "_Hair"
                          end
                   end
                   if data.PenisType ~= itemID then
                        newPenis = InventoryItemFactory.CreateItem(itemID)
                        player:setWornItem("RasMalePrivatePart", newPenis)
                        data.PenisType = itemID
                   end   
             end


             if oldPenis then
                 playerInv:Remove(oldPenis) -- remove from inventory
             end
             if newPenis then
                 playerInv:Remove(newPenis)
             end  


             for _,v in pairs(backUpItems) do -- restore weight values of items in case we changed smth
                    v.theItem:setWeight(v.weight)
                    v.theItem:setActualWeight(v.actualWeight)                    
             end                                   
      end
end


-- when clothing updates, check for correct penis model
local function onClothingUpdate(player)

  manageBody.ManageMalePrivatePart(player, true) -- parameter "true" tells the function that it should check for exceptionalClothes     
 
end

Events.OnClothingUpdated.Add(onClothingUpdate) -- call whenever smth about clothes changes 



-- this function transfers all blood and dirt from the skin to the player's body so that the "wash yourself" option is shown properly
-- when the skin is dirty; will also store dirtyness when game is saved and loaded; is done on every clothingUpdate
function manageBody.TransferDirtToBody(player)
       local visual = player:getHumanVisual()
       local skin = player:getWornItem("RasSkin")
       if skin and visual then
          local coveredParts = BloodClothingType.getCoveredParts(skin:getBloodClothingType())
          for i=1,coveredParts:size() do
	         local part = coveredParts:get(i-1)
	         visual:setBlood(part, skin:getBlood(part))
	         visual:setDirt(part, skin:getDirt(part))
          end
       end
end

Events.OnClothingUpdated.Add(manageBody.TransferDirtToBody) -- call whenever smth about player's dirtyness/bloodyness changes (will trigger OnClothingUpdate)


return manageBody





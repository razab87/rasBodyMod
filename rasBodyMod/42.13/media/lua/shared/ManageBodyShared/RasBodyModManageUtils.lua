-- contains some util functions we need for body management; the functions here will be called by server and client in MP (mostly by server)
--
--
-- by razab





local rasSharedData = require("RasBodyModSharedData")

local Regs = RasBodyModRegistries


-- some auxiliary local functions:

-- next two functions will be used to temporarily reduce weight of some inventory items when new body items are equipped; otherwise there can be problems in case 
-- players somehow manage to surpass their inventory weight limit of 50; will be used when equipping body items
local function reduceInvWeight(player, playerInv, backUp)

    local invCapacity = playerInv:getCapacity()

    if player:getInventoryWeight() >= invCapacity then 
        local items = playerInv:getItems()                  
        for i=1,items:size() do
            local item = items:get(i-1)  
            table.insert(backUp, {item = item, weight = item:getWeight(), actualWeight = item:getActualWeight(), customWeight = item:isCustomWeight()}) 
            item:setActualWeight(0)         
            item:setWeight(0)          
            item:setCustomWeight(true)
            syncItemFields(player, item) -- note: lowering weight does not work as expected; client only shows lowered weight after item has been removed from inventory                   
            if player:getInventoryWeight() < invCapacity then
                break
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
        item:setCustomWeight(v.customWeight)
        item:syncItemFields()
    end
end




-- main functions of this lua
local manageUtils = {} -- can be accessed by require("ManageBodyShared/RasBodyModManageUtils")


-- this function is called only once a new game starts; ensures that player starts with a vanilla vest (glitch fix will then be applied as a second step)
function manageUtils.VestGlitchFixNewGame(player, args)

     local locations = {ItemBodyLocation.TORSO_EXTRA_VEST_BULLET, ItemBodyLocation.TORSO_EXTRA_VEST}
     for _,loc in pairs(locations) do
           local item = player:getWornItem(loc)
           if item then 
                local newItem = rasSharedData.GlitchedItemsReverse[item:getFullType()]
                if newItem then                     
                     local playerInv = player:getInventory()

                     player:setWornItem(loc, nil)
                     sendClothing(player, loc, nil)
                     playerInv:Remove(item) 
                     sendRemoveItemFromContainer(playerInv, item)                        
                     
                     local vest = instanceItem(newItem)
                     playerInv:addItem(vest)
                     sendAddItemToContainer(playerInv, vest)   
                     player:setWornItem(loc, vest) 
                     sendClothing(player, loc, vest)                                   
                end
           end
     end 
end



-- exchange visuals of bullet proof vests and similar clothing items for fixing a specific visual glitch (see ManageBodyIG for more information)
function manageUtils.ExchangeVestVisuals(player, args)

    if not args then
        return
    end

    local bodyLocation = ItemBodyLocation.get(ResourceLocation.of(args.bodyLocation))

    if bodyLocation then
        local vest = player:getWornItem(bodyLocation)
        if vest then
            local visual = vest:getVisual()
            if visual then

                local inv = player:getInventory()

                player:setWornItem(bodyLocation, nil)
                inv:Remove(vest)
	            sendRemoveItemFromContainer(inv, vest) -- note: in MP, exchanging visuals seems only possible when item is not equipped and not in inventory (???)

                local visualType = visual:getItemType()
                local newVestType = rasSharedData.GlitchedItems[visualType]
                if args.revert then
                    newVestType = rasSharedData.GlitchedItemsReverse[visualType]
                end

                if newVestType then
                    local texture = visual:getTextureChoice()

                    visual:setItemType(newVestType) 
                    visual:setClothingItemName(newVestType)
                    if texture then
                         visual:setTextureChoice(texture) -- also apply correct extra texture ("Type 1", "Type 2" etc)
                    end
                     
                    vest:synchWithVisual()                
                end

                inv:AddItem(vest)
                sendAddItemToContainer(inv, vest)
                player:setWornItem(bodyLocation, vest)
                sendClothing(player, bodyLocation, vest)
            end
        end
    end
end



-- transfer all blood and dirt from the skin to the player's body so that the "wash yourself" option is shown properly
-- when the skin is dirty; will also store dirtyness when game is saved and loaded; is done on every clothingUpdate
function manageUtils.TransferDirtToBody(player, args)

    local visual = player:getHumanVisual()
    local skin = player:getWornItem(Regs.Skin)

    if skin and visual then
        local coveredParts = BloodClothingType.getCoveredParts(skin:getBloodClothingType())
        for i=1,coveredParts:size() do
            local part = coveredParts:get(i-1)  
            visual:setBlood(part, skin:getBlood(part))
            visual:setDirt(part, skin:getDirt(part))
        end
        sendHumanVisual(player) -- syncs the client's non-modded player body (as in vanilla TimedAction ISWashyourself)
    end
end


-- same as above but inverted
function manageUtils.TransferDirtToSkin(player, args)

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

        syncItemFields(player, skin) -- syncs the client's skin (as in vanilla TimedAction ISWashClothing)
        syncVisuals(player)
    end  
end




-- equips body items to player
function manageUtils.EquipBodyItem(player, args)

    if not args then
        return
    end
    
    if args.itemID == nil then
        if args.bodyLocation then
            local location = ItemBodyLocation.get(ResourceLocation.of(args.bodyLocation))
            if rasSharedData.ModdedLocation(location) then -- anti-cheat: only for bodyLocations coming from our mod

                local oldItem = player:getWornItem(location)

                player:setWornItem(location, nil)
                
                local inv = player:getInventory()
                if oldItem then
                    inv:Remove(oldItem)
                    sendRemoveItemFromContainer(inv, oldItem)
                end

                sendClothing(player, location, nil)  
            end
        end
    else
        local item = instanceItem(args.itemID)
        if item then
            local location = item:getBodyLocation()
            if rasSharedData.ModdedLocation(location) then -- anti-cheat: do not equip items not coming from this mod
                                
                local oldItem = player:getWornItem(location)

                player:setWornItem(location, item)                

                local inv = player:getInventory()
                if oldItem then
                    inv:Remove(oldItem)
                    sendRemoveItemFromContainer(inv, oldItem)
                end
                inv:Remove(item)
                sendRemoveItemFromContainer(inv, item) 

                sendClothing(player, location, item)                        
            end
        end
    end
end


-- execute all commands from the queue
function manageUtils.executeCommands(player, queue, shouldReduceWeight)

    local backUp = {}
    local inv = player:getInventory()
    if shouldReduceWeight then
        reduceInvWeight(player, inv, backUp)
    end

    for _,v in ipairs(queue) do
        if manageUtils[v.actionName] then -- better check this (to avoid cheaters triggering server errors by sending wrong data)
            manageUtils[v.actionName](player, v.args)
        end
    end

    restoreWeight(player, inv, backUp)
end




function manageUtils.calibrateMale(player, queue)

    local clothingBackUp = {}
    local startTick = nil
    local function calibrate(tick)
        
        if not startTick then
            startTick = tick
        end

        if tick == startTick then

            local items = player:getWornItems()
            local group = BodyLocations.getGroup("Human")
            for i=1,items:size() do -- backUp clothing info
                local wornItem = items:get(i-1)
                local item = wornItem:getItem()
                local bodyLocation = item:getBodyLocation()
                if group:getLocation(bodyLocation) and (not rasSharedData.ModdedLocation(bodyLocation)) then
                    table.insert(clothingBackUp, {clothing = item, location = bodyLocation, weight = item:getWeight(), actualWeight = item:getActualWeight(), customWeight = item:isCustomWeight()})
                    item:setWeight(0) -- briefly change weight so that players do not surpass inventory limit
                    item:setActualWeight(0)  
                    item:setCustomWeight(true)
                    syncItemFields(player, item)                                                
                end
            end

            for _,v in pairs(clothingBackUp) do
                player:setWornItem(v.location, nil) -- briefly unequip clothing
                sendClothing(player, v.location, nil)
            end

            local v = queue[1]
            if v and manageUtils[v.actionName] then
                manageUtils[v.actionName](player, v.args)
            end
        elseif tick == startTick + 1 then
            local v = queue[2]
            if v and manageUtils[v.actionName] then
                manageUtils[v.actionName](player, v.args)
            end
        elseif tick == startTick + 2 then
            local v = queue[3]
            if v and manageUtils[v.actionName] then
                manageUtils[v.actionName](player, v.args)
            end
        elseif tick > startTick + 2 then
           
            -- re-equip clothing and restore data
            for _,v in pairs(clothingBackUp) do -- re-equip all clothing
                local item = v.clothing             
                item:setWeight(v.weight) -- restore weight
                item:setActualWeight(v.actualWeight) 
                item:setCustomWeight(v.customWeight)
                item:syncItemFields() 
                player:setWornItem(v.location, item)  
                sendClothing(player, v.location, item)              
            end

            local v = queue[4]
            if v and manageUtils[v.actionName] then
                manageUtils[v.actionName](player, v.args)
            end

            manageUtils.TransferDirtToSkin(player, {})
            
            Events.OnTick.Remove(calibrate)
            clothingBackUp = {}
            startTick = nil
        end
    end

    Events.OnTick.Add(calibrate)
end




return manageUtils





-- some inventory manipulations which have to be realized on server
--
--
-- by razab

local function reduceWeight(player, args)
  
    local item = args.item
    --player:setWornItem(item:getBodyLocation(), nil) 
    --player:getInventory():Remove(item)
    --sendRemoveItemFromContainer(player:getInventory(), item)
    --item:setCustomWeight(true)
    --item:setActualWeight(0.1) -- lower weight of some items until overall weight is less than limit
    --item:setWeight(0.1)
    --item:setCustomWeight(true)
    --item:syncItemFields()
    --sendItemStats(item)
    --syncItemFields(player, item)
    --player:getInventory():AddItem(item)
    --sendAddItemToContainer(player:getInventory(), item)
    --player:setWornItem(item:getBodyLocation(), item)
end

local function restoreWeight(player, args)

    local item = args.item
    item:setWeight(args.weight)
    item:setActualWeight(args.actualWeight)
    sendItemStats(item)
    item:syncItemFields()
    syncItemFields(player, item)
end


local function unequipItem(player, args)

    local item = args.item
    player:setWornItem(item:getBodyLocation(), nil)    
end

local function equipItem(player, args)

    local item = args.item
    local bodyLocation = item:getBodyLocation()
    player:setWornItem(bodyLocation, item)
    --bodyLocation = item:getBodyLocation() 
    --print("TEST_OUTPUT ", bodyLocation)
    triggerEvent("OnClothingUpdated", player)
    sendEquip(player)
    syncVisuals(player)
    sendClothing(player, bodyLocation, item)
    sendPlayerEffects(player)
    triggerEvent("OnClothingUpdated", player)
    --item:setEquipParent(player)  
    --item:syncItemFields()
    --triggerEvent("OnClothingUpdated", player)
    --sendEquip(player)
end



local function onClientCommand(mod, command, player, args)

    if mod == "rasBodyMod" then
        if command == "reduceWeight" then
            --print("TEST_OUTPUT hello from client")
            reduceWeight(player, args)
        elseif command == "restoreWeight" then
            restoreWeight(player, args)
        elseif command == "unequipItem" then
            unequipItem(player, args)
        elseif command == "equipItem" then
            equipItem(player, args)
        end    
    end
end


Events.OnClientCommand.Add(onClientCommand)

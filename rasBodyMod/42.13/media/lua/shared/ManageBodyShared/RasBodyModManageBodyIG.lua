-- contains several functions which manage the body while game is running (i.e. equip correct skin, body hair, male private part model; make sure dirtyness/bloodyness patterns on player body
-- behave correctly); functions are only called by client when in MP; executing functions from this lua is always done via a queue; this is to enable us to send whole queues to server when
-- in MP so that we can ensure that the server executes the functions in correct the order; in SP, the system is not necessary but I decided to use it anyway so that we have the same code
-- structure and can use the same system in both cases
--
--
-- by razab




local rasSharedData = require("RasBodyModSharedData")
local manageUtils = require("ManageBodyShared/RasBodyModManageUtils")

local Regs = RasBodyModRegistries







-- check whether lower torso area is nude (will be used by the VestGlitchFix, see below)
local function torsoNude(player)

    local myTable = rasSharedData.TorsoLocations

    for _,loc in pairs(myTable) do
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




local manageBody = {} -- can be accessed via require("ManageBodyShared/RasBodyModManageBodyIG")



-- check whether character wears an exceptional clothing item while in game (is used by ManageMalePrivatePart below)
function manageBody.WearsExceptionalClothing(player, mode)

    local myTable = rasSharedData.ExceptionalClothes

    --local locationGroup = BodyLocations.getGroup("Human") 
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


-- check whether groin area is nude (is only used in the manageAnim functions from the client folder)
function manageBody.GroinNude(player, mode)

    local myTable = rasSharedData.HidesGroin
 
    for _,bodyLocation in pairs(myTable) do
        local loc = ItemBodyLocation.get(ResourceLocation.of(bodyLocation))
        if loc then
            local item = player:getWornItem(loc)
            if item then
                return false
            end
        end
    end 

    return true
end






-- next functions are the main functions of this lua



-- next function realize a fix for a visual bug related to bullet proof vests and some similar items: when player's groin area is nude and a bullet proof
-- vest is equipped, there appears a glitchy black bar in the pubic hair area; is somehow (?) caused by the masking system for the vest
-- solution: in this situation, exchange the visuals of the vanilla vest with a modded vest which uses different mask definition so that the glitch
-- disappears; the vest items are not exchaned, only their visuals are; also revert the visuals to their default version when they aren't
-- needed any more
local glitchedLocations = {ItemBodyLocation.TORSO_EXTRA_VEST_BULLET, ItemBodyLocation.TORSO_EXTRA_VEST}
function manageBody.VestGlitchFix(player, args, equipQueue)

    for _,loc in pairs(glitchedLocations) do
        local item = player:getWornItem(loc)
        if item then
            local visual = item:getVisual()
            if visual then
                local visualType = visual:getItemType()
                if torsoNude(player) then -- if torso is nude and we wear a glitched vest, exchange                
                    if rasSharedData.GlitchedItems[visualType] then 
                        --manageUtils.exchangeVestVisuals(player, item, visual, visualType, false)
                        table.insert(equipQueue, {actionName = "ExchangeVestVisuals", args = {bodyLocation = loc:toString(), revert = false}})
                    end                                    
                else -- if torso not nude and we wear a gltich-fix-vest, revert back to normal vest
                    if rasSharedData.GlitchedItemsReverse[visualType] then
                        --manageUtils.exchangeVestVisuals(player, item, visual, visualType, true) 
                        table.insert(equipQueue, {actionName = "ExchangeVestVisuals", args = {bodyLocation = loc:toString(), revert = true}})
                    end
                end
            end
        end
    end
end



-- equips the correct skin (only called once when game starts in RasBodyModCreatePlayer)
function manageBody.EquipSkin(player, args, equipQueue)
 
    local data = player:getModData().RasBodyMod
    local gender = "Male"
    if player:isFemale() then
        gender = "Female"
    end
             
    -- equip the correct skin:
    local itemID = rasSharedData.Skins[gender][data.SkinColorIndex]
    table.insert(equipQueue, {actionName = "EquipBodyItem", args = {bodyLocation = "rasbomo:skin", itemID = itemID}})
end



-- equip correct body hair item
function manageBody.EquipBodyHair(player, args, equipQueue)
         
    local bodyLocation = args.bodyLocation

    local locID = rasSharedData.ModLocationID

    local data = player:getModData().RasBodyMod  
    local skinColor = data.SkinColorIndex
    local gender = "Male"
    if player:isFemale() then
        gender = "Female"
    end

    -- equip the body hair item
    local hairItem = data[locID[bodyLocation]]
    if hairItem == "None" then
        table.insert(equipQueue, {actionName = "EquipBodyItem", args = {bodyLocation = bodyLocation:toString(), itemID = nil}})
    else        
        local itemID = hairItem
        local optimizedTable = rasSharedData.OptimizedBodyHair[gender]
        if optimizedTable[skinColor] then -- some skin colors might get slightly different hair items for better visuals
            itemID = hairItem .. "_" .. optimizedTable[skinColor]
        end         

        local itemExists = instanceItem(itemID)
        if not itemExists then  -- if optimized version doesn't exist, take default version
            itemID = hairItem
        end

        table.insert(equipQueue, {actionName = "EquipBodyItem", args = {bodyLocation = bodyLocation:toString(), itemID = itemID}})
    end
end



-- apply beard stubble
function manageBody.EquipBeardStubble(player, args, equipQueue)

    if not player:isFemale() then

        local data = player:getModData().RasBodyMod               
        
        local currentBeard = getBeardStylesInstance():FindStyle(player:getHumanVisual():getBeardModel())
        local beardID = nil
        if currentBeard then
            beardID = currentBeard:getName()
        end 

        local oldStubble = player:getWornItem(Regs.BeardStubble)
        if rasSharedData.FullBeards[beardID] then -- never show stubble if player has full beard (for better visuals) 
            table.insert(equipQueue, {actionName = "EquipBodyItem", args = {bodyLocation = "rasbomo:beardstubble", itemID = nil}})
            data.BeardStubble = 1 -- full beard will always have stubbles (though not visibile)
        elseif data.BeardStubble == 0 then
            table.insert(equipQueue, {actionName = "EquipBodyItem", args = {bodyLocation = "rasbomo:beardstubble", itemID = nil}})
        elseif oldStubble == nil and data.BeardStubble == 1 then
            local itemID = "RasBodyMod.StubbleBeard_Light"
            if data.SkinColorIndex == 4 or data.SkinColorIndex == 5 then
                itemID = "RasBodyMod.StubbleBeard_Dark"
            end
            table.insert(equipQueue, {actionName = "EquipBodyItem", args = {bodyLocation = "rasbomo:beardstubble", itemID = itemID}})
        end
    end
end



-- apply head stubble (only called once when game starts in RasBodyModCreatePlayer.lua)
function manageBody.EquipHeadStubble(player, args, equipQueue)

    local data = player:getModData().RasBodyMod 

    if data.HeadStubble == 1 then   
                   
        if player:isFemale() then
            local itemID = "RasBodyMod.StubbleHead_Light_F"
            if data.SkinColorIndex == 4 or data.SkinColorIndex == 5 then
                itemID = "RasBodyMod.StubbleHead_Dark_F"
            end
            table.insert(equipQueue, {actionName = "EquipBodyItem", args = {bodyLocation = "rasbomo:headstubble", itemID = itemID}})
        else
            local itemID = "RasBodyMod.StubbleHead_Light_M"
            if data.SkinColorIndex == 4 or data.SkinColorIndex == 5 then
                itemID = "RasBodyMod.StubbleHead_Dark_M"
            end
            table.insert(equipQueue, {actionName = "EquipBodyItem", args = {bodyLocation = "rasbomo:headstubble", itemID = itemID}})
        end
    else
        table.insert(equipQueue, {actionName = "EquipBodyItem", args = {bodyLocation = "rasbomo:headstubble", itemID = nil}})
    end
end




function manageBody.ManageMalePrivatePart(player, args, equipQueue)
    
    if not player:isFemale() then

        local data = player:getModData().RasBodyMod

        local wearsExceptionalClothes = data.WearsExceptionalClothesDefault
        if data.PlayerMode ~= "default" and data.PlayerMode ~= "turn" then
            wearsExceptionalClothes = data.WearsExceptionalClothesSitting
        end 

        if wearsExceptionalClothes then
            table.insert(equipQueue, {actionName = "EquipBodyItem", args = {bodyLocation = "rasbomo:maleprivatepart", itemID = nil}})
            data.PenisType = "None"
        else
            local itemID = rasSharedData.PenisTable[data.SkinColorIndex][data.PlayerMode]
            if data.PlayerMode == "default" or data.PlayerMode == "turn" then -- those cases have special hairy variants
                if data.RasPubicHair ~= "None" then
                    itemID = itemID .. "_Hair"
                end
            end

            if data.PenisType ~= itemID then
                table.insert(equipQueue, {actionName = "EquipBodyItem", args = {bodyLocation = "rasbomo:maleprivatepart", itemID = itemID}})
                data.PenisType = itemID
            end   
        end                                
    end
end




local isEquipAction = {}
isEquipAction["EquipSkin"] = true
isEquipAction["EquipBodyHair"] = true
isEquipAction["EquipBeardStubble"] = true
isEquipAction["EquipHeadStubble"] = true
isEquipAction["ManageMalePrivatePart"] = true


-- next function executes the queue to modify the body visuals; for some funcions, we first run through the function and only collect the relevant commands;
-- those commands are then put into a second queue and this queue is then finally executed here or when in MP on server; I decided to use the construction with the additional queue to
-- minimize the work which is done on server to save server performance
local FIRST_TIME = true
function manageBody.executeQueue(player, queue, updateAvatar)
       
    local shouldReduceWeight = false

    if isClient() then
       
        local queueForServer = {}
        for _,v in ipairs(queue) do -- construct the queues of commands to be executed
            if isEquipAction[v.functionName] then -- for the equip functions, run the manageBody function first and only collect the relevant commands
                manageBody[v.functionName](player, v.args, queueForServer)
                shouldReduceWeight = true
            elseif v.functionName == "VestGlitchFix" then
                manageBody.VestGlitchFix(player, v.args, queueForServer)
            else
                table.insert(queueForServer, {actionName = v.functionName, args = {}})
            end
        end

        local data = player:getModData().RasBodyMod
        sendClientCommand(player, "rasBodyMod", "syncModData", {modData = data}) -- make server sync modData (note: modData not needed by server for computation, we just need to store them there)
        if FIRST_TIME then            
            sendClientCommand(player, "rasBodyMod", "executeCommands", {queue = queueForServer, updateAvatar = updateAvatar, shouldReduceWeight = shouldReduceWeight, firstTime = true}) -- send queue to server
            FIRST_TIME = false
        else
            sendClientCommand(player, "rasBodyMod", "executeCommands", {queue = queueForServer, updateAvatar = updateAvatar, shouldReduceWeight = shouldReduceWeight}) -- send queue to server
        end

    else -- in SP, do everything directly

        local defaultQueue = {}
        for _,v in ipairs(queue) do -- construct the queue of commands to be executed
            if isEquipAction[v.functionName] then
                manageBody[v.functionName](player, v.args, defaultQueue)
                shouldReduceWeight = true
            elseif v.functionName == "VestGlitchFix" then
                manageBody.VestGlitchFix(player, v.args, defaultQueue)
            else
                table.insert(defaultQueue, {actionName = v.functionName, args = {}})
            end
        end

        manageUtils.executeCommands(player, defaultQueue, shouldReduceWeight)

        if updateAvatar then
            if ISCharacterInfoWindow and ISCharacterInfoWindow.instance and ISCharacterInfoWindow.instance.charScreen then
                ISCharacterInfoWindow.instance.charScreen.refreshNeeded = true 
            end 
        end
    end
end


-- a special variant of the above function which is only used in MP when updating the avatar; queue will only contain the ManageMalePrivate and TransferDirtToSkin command
function manageBody.executeQueueAndHackAvatar(player, queue)

    local queueForServer = {}
    for _,v in ipairs(queue) do -- construct the queues of commands to be executed
        if isEquipAction[v.functionName] then        
            manageBody[v.functionName](player, v.args, queueForServer)
        else
            table.insert(queueForServer, {actionName = v.functionName, args = {}})
        end
    end

    sendClientCommand(player, "rasBodyMod", "hackAvatar", {queue = queueForServer, shouldReduceWeight = true}) -- send queue to server
end


-- again a function to make the avatar behave correctly in game when in MP: in the simplest case, we can equip models on client-side since
-- we are only tweaking client-side UI (above case requires doing it server-side since we have to temporarily reduce inventory weight to avoid a
-- specific bug occuring when inventory weight is above the limit)
function manageBody.executeQueueOnClient(player, queue)

    local defaultQueue = {}
    for _,v in ipairs(queue) do -- construct the queue of commands to be executed
        if isEquipAction[v.functionName] then
            manageBody[v.functionName](player, v.args, defaultQueue)
        else
            table.insert(defaultQueue, {actionName = v.functionName, args = {}})
        end
    end

    manageUtils.executeCommands(player, defaultQueue, false) -- execute on client
end


-- some of the functions from this lua need to be executed OnClothingUpdate
function manageBody.onClothingUpdate(player)

    if (not isServer()) then -- only trigger this when in singleplayer or in MP on client-side
 
        local data = player:getModData().RasBodyMod

        if not player:isFemale() then
            data.WearsExceptionalClothesDefault = manageBody.WearsExceptionalClothing(player, "hideWhileStanding") -- check whether we wear exceptional clothes which should hide the groin area
            data.WearsExceptionalClothesSitting = manageBody.WearsExceptionalClothing(player, "hideWhileSitting")

            data.GroinNudeDefault = manageBody.GroinNude(player, "hideWhileStanding")
            data.GroinNudeSitting = manageBody.GroinNude(player, "hideWhileSitting")
        end

        local queue = {
            {functionName = "EquipBeardStubble", args = {}},
            {functionName = "ManageMalePrivatePart", args = {}},
            {functionName = "TransferDirtToBody", args = {}},
            {functionName = "VestGlitchFix", args = {}},
            {functionName = "TransferDirtToSkin", args = {}} -- vanilla game sometimes removes dirt visuals from body when clothing items are (un-)equipped (??); this command seems to fix it
        }
        manageBody.executeQueue(player, queue, true) -- parameter true means we update the in-game avatar after equipping the items
    end         
end


-- sometimes, we only call our customClothingUpdate to avoid frequent triggering of vannilla events
function manageBody.CustomClothingUpdate(player)

    if (not isServer()) then -- only trigger this when in singleplayer or in MP on client-side
 
        local data = player:getModData().RasBodyMod

        if not player:isFemale() then
            data.WearsExceptionalClothesDefault = manageBody.WearsExceptionalClothing(player, "hideWhileStanding") -- check whether we wear exceptional clothes which should hide the groin area
            data.WearsExceptionalClothesSitting = manageBody.WearsExceptionalClothing(player, "hideWhileSitting")

            data.GroinNudeDefault = manageBody.GroinNude(player, "hideWhileStanding")
            data.GroinNudeSitting = manageBody.GroinNude(player, "hideWhileSitting")
        end

        local queue = {
            {functionName = "ManageMalePrivatePart", args = {}},
            {functionName = "VestGlitchFix", args = {}},
            {functionName = "TransferDirtToSkin", args = {}} -- vanilla game sometimes removes dirt visuals from body when clothing items are (un-)equipped (??); this command seems to fix it
        }
        manageBody.executeQueue(player, queue, true) -- parameter true means we update the in-game avatar after equipping the items
    end         
end



Events.OnClothingUpdated.Add(manageBody.onClothingUpdate) -- call whenever smth about clothes changes 



return manageBody





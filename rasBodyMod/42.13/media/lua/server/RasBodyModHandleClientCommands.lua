-- handles the commands coming from client; client will send a queue of commands which the server then executes in the given order
--
--
-- by razab


--local rasSharedData = require("RasBodyModSharedData")
local manageUtils = require("ManageBodyShared/RasBodyModManageUtils")

local Regs = RasBodyModRegistries



local function onClientCommand(mod, command, player, args)

    if mod == "rasBodyMod" then
        if command == "executeCommands" and args and type(args.queue) == "table" then
            manageUtils.executeCommands(player, args.queue, args.shouldReduceWeight)
            if args.updateAvatar then
                sendServerCommand(player, "rasBodyMod", "updateAvatar", {}) -- send command to client: update the in-game avatar
            end
            if args.firstTime then
                sendServerCommand(player, "rasBodyMod", "calibrateMale", {}) -- send command to client: calibrate male character 
            end
        elseif command == "initPlayer" then -- when new character should be initialized
            sendServerCommand(player, "rasBodyMod", "stopRequestingAndInit", {}) -- tell the client to stop requesting and start the init process  
        elseif command == "loadPlayer" then -- when game with an existing character is loaded
            local data = player:getModData() -- get modData from previous save game                                           
            sendServerCommand(player, "rasBodyMod", "stopRequestingAndLoad", {modData = data.RasBodyMod}) -- tell the client to stop requesting and start the load process 
        elseif command == "executeCalibrateQueue" and args and type(args.queue) == "table" then 
            manageUtils.calibrateMale(player, args.queue) -- execute the queue
        elseif command == "removeBeardStubbleFromInventory" then            
            local stubble = player:getWornItem(Regs.BeardStubble)
            local inv = player:getInventory()
            if stubble then
                inv:Remove(stubble)
                sendRemoveItemFromContainer(inv, stubble)
            end
        elseif command == "syncModData" and args then
            local data = player:getModData()
            data.RasBodyMod = args.modData
        elseif command == "hackAvatar" and args and type(args.queue) == "table" then
            manageUtils.executeCommands(player, args.queue, args.shouldReduceWeight)
            sendServerCommand(player, "rasBodyMod", "hackAvatar", {}) -- send command back to client   
        end         
    end
end


Events.OnClientCommand.Add(onClientCommand)




-- additional debug options, only for testing the mod
--[[local function onClientCommandDebug(mod, command, player, args)

    if mod == "rasBodyMod" then
        if command == "addBloodVest" then
            local vest = player:getWornItem(ItemBodyLocation.TORSO_EXTRA_VEST_BULLET)
            if vest then
                local coveredParts = BloodClothingType.getCoveredParts(vest:getBloodClothingType())
                for i=1,coveredParts:size() do
                    local part = coveredParts:get(i-1)
                    --vest:setBlood(part, 1)
                    player:addBlood(part, false, true, false)                  
                end
                syncItemFields(player, vest)
                vest:synchWithVisual()
                --skin:syncItemFields()
                --sendServerCommand(player, "rasBodyMod", "triggerClothingUpdate", {})
                sendServerCommand(player, "rasBodyMod", "updateAvatar", {})                
            end
        elseif command == "addBloodSkin" then
            local skin = player:getWornItem(Regs.Skin)
            if skin then

                player:getInventory():AddItem(skin)
	            sendAddItemToContainer(player:getInventory(), skin)

                print("TEST_OUTPUT skin present")
                local coveredParts = BloodClothingType.getCoveredParts(skin:getBloodClothingType())
                for i=1,coveredParts:size() do
                    local part = coveredParts:get(i-1)
                    --skin:setBlood(part, 1)
                    player:addBlood(part, false, true, false) 
                    local bloodLvl = skin:getBlood(part)
                    skin:setBlood(part, bloodLvl)                 
                end
                --syncItemFields(player, skin)
                skin:syncItemFields()
                skin:synchWithVisual() 
                syncVisuals(player)
              
                sendServerCommand(player, "rasBodyMod", "triggerClothingUpdate", {})
                --sendServerCommand(player, "rasBodyMod", "updateAvatar", {}) 

                player:getInventory():Remove(skin)
                sendRemoveItemFromContainer(player:getInventory(), skin)                
            end
        elseif command == "addBloodTorso" then
            local skin = player:getWornItem(Regs.Skin)
            if skin then

                player:getInventory():AddItem(skin)
	            sendAddItemToContainer(player:getInventory(), skin)

                print("TEST_OUTPUT skin present")
                player:addBlood(BloodBodyPartType.Torso_Upper, false, true, false) 
                local bloodLvl = skin:getBlood(BloodBodyPartType.Torso_Upper)
                skin:setBlood(BloodBodyPartType.Torso_Upper, bloodLvl)                 

                --syncItemFields(player, skin)
                skin:syncItemFields()
                skin:synchWithVisual() 
                syncVisuals(player)
              
                sendServerCommand(player, "rasBodyMod", "triggerClothingUpdate", {})
                --sendServerCommand(player, "rasBodyMod", "updateAvatar", {}) 

                player:getInventory():Remove(skin)
                sendRemoveItemFromContainer(player:getInventory(), skin)                
            end
        end
    end
end

Events.OnClientCommand.Add(onClientCommandDebug)]]--







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
local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG") 
local manageTurnAround = require("ManageAnimations/RasBodyModManageTurnAround")
local manageSneaking = require("ManageAnimations/RasBodyModManageSneaking")
local manageUtils = require("ManageBodyShared/RasBodyModManageUtils")

local Regs = RasBodyModRegistries



local calibrateTick = nil
local function calibrateMale(tick)

    if not calibrateTick then
        calibrateTick = tick 
    end

    if isClient() then 

        if tick >= calibrateTick + 1 then

            local player = getPlayer()            
            local data = player:getModData().RasBodyMod
            local modeBackUp = data.PlayerMode

            local queueForServer = {}

            data.PlayerMode = "turn"
            manageBody.ManageMalePrivatePart(player, {}, queueForServer)

            data.PlayerMode = "cover"
            manageBody.ManageMalePrivatePart(player, {}, queueForServer)

            data.PlayerMode = "coverWalk"
            manageBody.ManageMalePrivatePart(player, {}, queueForServer)

            data.PlayerMode = modeBackUp
            manageBody.ManageMalePrivatePart(player, {}, queueForServer)

            sendClientCommand(player, "rasBodyMod", "executeCalibrateQueue", {queue = queueForServer}) -- send queue to server            

            Events.OnTick.Remove(calibrateMale) -- remove from events
            calibrateTick = nil  
        end       
    else
        if tick >= calibrateTick + 1 then

            local player = getPlayer()            
            local data = player:getModData().RasBodyMod
            local modeBackUp = data.PlayerMode

            local queue = {}

            data.PlayerMode = "turn"
            manageBody.ManageMalePrivatePart(player, {}, queue)

            data.PlayerMode = "cover"
            manageBody.ManageMalePrivatePart(player, {}, queue)

            data.PlayerMode = "coverWalk"
            manageBody.ManageMalePrivatePart(player, {}, queue)

            data.PlayerMode = modeBackUp
            manageBody.ManageMalePrivatePart(player, {}, queue)

            manageUtils.calibrateMale(player, queue) -- execute the queue

            Events.OnTick.Remove(calibrateMale) -- remove from events
            calibrateTick = nil
        end
    end
end



-- enable graphical enhancement for male characters
local ADDED_TO_EVENTS = false
local function graphicalEnhance(player) 

    if (not SandboxVars.RasBodyMod.PerformanceMode) then -- only when "Performance Mode" in sandbox is disabled 
        if (not player:isFemale()) and (not ADDED_TO_EVENTS) then -- enable graphical enhancements for male characters
            if not isClient() then
                Events.OnTick.Add(calibrateMale)
            end
            Events.OnKeyStartPressed.Add(manageTurnAround.OnMovementKeyPressed)
            Events.OnKeyPressed.Add(manageTurnAround.OnMovementKeyReleased) 
            Events.OnKeyKeepPressed.Add(manageTurnAround.OnMovementKeyKeepPressed) 
            Events.OnPlayerUpdate.Add(manageSneaking.OnPlayerUpdate)
            ADDED_TO_EVENTS = true       
        elseif player:isFemale() and ADDED_TO_EVENTS then -- disable enhancements for female characters
            Events.OnKeyStartPressed.Remove(manageTurnAround.OnMovementKeyPressed)
            Events.OnKeyPressed.Remove(manageTurnAround.OnMovementKeyReleased) 
            Events.OnKeyKeepPressed.Remove(manageTurnAround.OnMovementKeyKeepPressed) 
            Events.OnPlayerUpdate.Remove(manageSneaking.OnPlayerUpdate)
            ADDED_TO_EVENTS = false
        end      
    end 
end



-- init modData with data coming from the character creation screen
local function initModData(player)

    local gender = "Male"
    if player:isFemale() then
        gender = "Female"
    end

    local data = player:getModData()
    data.RasBodyMod = {}
    data.RasBodyMod.ModVersion = "B42"             
    data.RasBodyMod.PlayerMode = "default" -- when new game starts, player is always in "default mode"  
    data.RasBodyMod.PenisType = "None"
    data.RasBodyMod.SkinColorIndex =  rasClientData.SkinColorIndex -- store skin color index 

    -- store body hair info as choosen during character creation
    if gender == "Female" then
        data.RasBodyMod.RasPubicHair = rasClientData["SelectedBodyHair"]["Female"]["rasbomo:pubichair"]
        data.RasBodyMod.RasArmpitHair = rasClientData["SelectedBodyHair"]["Female"]["rasbomo:armpithair"]
        data.RasBodyMod.RasLegHair = rasClientData["SelectedBodyHair"]["Female"]["rasbomo:leghair"]
        data.RasBodyMod.HeadStubble = rasClientData["HeadStubble"]
    else
        data.RasBodyMod.RasPubicHair = rasClientData["SelectedBodyHair"]["Male"]["rasbomo:pubichair"]
        data.RasBodyMod.RasArmpitHair = rasClientData["SelectedBodyHair"]["Male"]["rasbomo:armpithair"]
        data.RasBodyMod.RasLegHair = rasClientData["SelectedBodyHair"]["Male"]["rasbomo:leghair"]
        data.RasBodyMod.RasChestHair = rasClientData["SelectedBodyHair"]["Male"]["rasbomo:chesthair"]
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
    
    -- will store whether player wears exceptional clothes
    data.RasBodyMod.ExceptionalClothes = {}
    data.RasBodyMod.ExceptionalClothes.Default = false 
    data.RasBodyMod.ExceptionalClothes.Sitting = false
end



-- randomize modData; is applied if mod is added to an existing save where modData have not been initialized (can happen when mod is added to an existing game)
local function randomizeModData(player)

    local gender = "Male"
    if player:isFemale() then
        gender = "Female"
    end    
    local data = player:getModData()

    data.RasBodyMod = {}
    data.RasBodyMod.ModVersion = "B42"
    data.RasBodyMod.PlayerMode = "default"
    data.RasBodyMod.PenisType = "None"
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

    data.RasBodyMod.DaysTilGrow = {}
    data.RasBodyMod.DaysTilGrow.RasChestHair = 4 + ZombRand(2)   -- note: ZombRand(2) = randomly 0 or 1
    data.RasBodyMod.DaysTilGrow.RasArmpitHair = 4 + ZombRand(2)
    data.RasBodyMod.DaysTilGrow.RasPubicHair = 4 + ZombRand(2)
    data.RasBodyMod.DaysTilGrow.RasLegHair = 4 + ZombRand(2)    
    data.RasBodyMod.DaysTilGrow.BeardStubble = 4 + ZombRand(2)                     
end




-- equip the body items when game starts; we write all commands to a queue so we can ensure that they are exectued in correct order when in MP where we always
-- send the whole queue of commands to server
local function initBody(player)

    local queue = {
        {functionName = "EquipSkin", args = {}},
        {functionName = "EquipBodyHair", args = {bodyLocation = Regs.PubicHair}},
        {functionName = "EquipBodyHair", args = {bodyLocation = Regs.LegHair}},
        {functionName = "EquipBodyHair", args = {bodyLocation = Regs.ArmpitHair}},
        {functionName = "EquipHeadStubble", args = {}}
    }

    if not player:isFemale() then -- additional items for male characters
        table.insert(queue, {functionName = "EquipBodyHair", args = {bodyLocation = Regs.ChestHair}})
        table.insert(queue, {functionName = "ManageMalePrivatePart", args = {checkForExceptionalClothes = true}}) -- make sure correct penis is equipped
        table.insert(queue, {functionName = "EquipBeardStubble", args = {}})      
    end

    table.insert(queue, {functionName = "VestGlitchFixNewGame", args = {}}) -- apply the glitch fix for vests
    table.insert(queue, {functionName = "VestGlitchFix", args = {}}) 
    table.insert(queue, {functionName = "TransferDirtToSkin", args = {}}) 

    if isClient() then -- we have to remove beard stubble manually from inventory to initalize the player correctly when game starts
        sendClientCommand(player, "rasBodyMod", "removeBeardStubbleFromInventory", {})       
    else 
        local beardStubble = player:getWornItem(Regs.BeardStubble)
        player:getInventory():Remove(beardStubble)        
    end

    local data = player:getModData().RasBodyMod

    if not player:isFemale() then 
        data.WearsExceptionalClothesDefault = manageBody.WearsExceptionalClothing(player, "hideWhileStanding") -- check whether we wear exceptional clothes which should hide the groin area
        data.WearsExceptionalClothesSitting = manageBody.WearsExceptionalClothing(player, "hideWhileSitting")
        data.GroinNudeDefault = manageBody.GroinNude(player, "hideWhileStanding")
        data.GroinNudeSitting = manageBody.GroinNude(player, "hideWhileSitting")
    end

    data.PenisType = "None" -- hack to ensure the male privart part is equipped correctly in MP; this fixes a problem which happens because we can init the body
                            -- only after a few ticks in MP; it is not necessary for singleplayer   
    manageBody.executeQueue(player, queue, true) -- parameter true tells the function to update the in-game avatar screen after equipping 
end


-- next functions are the main functions which make sure everything is executed when game starts


-- when new game is started, store all data in player's modData and equip correct body items
local PLAYER_INIT = false
local function mainInitFunction(player, square)    
   
    PLAYER_INIT = true
                  
    if isClient() then -- in MP, we can only send commands to server after the first few game ticks, so we send several commands until the server responds and we know that server-client-communication can start
        
        local startTick = nil
        local function initInMP(tick)
            if not startTick then
                startTick = tick
            end

            if tick >= startTick + 2 then 
                sendClientCommand(player, "rasBodyMod", "initPlayer", {}) -- send command to server               
            end
        end 

        Events.OnTick.Add(initInMP)

        local function onServerCommandStopAndInit(mod, command, args)
            if mod == "rasBodyMod" then
                if command == "stopRequestingAndInit" then -- when server responds the first time, we stop sending init commands and execute the initBody() function
                    Events.OnTick.Remove(initInMP) -- remove from events
                    Events.OnServerCommand.Remove(onServerCommandStopAndInit)
        
                    initModData(player) -- initialize modData when new player is created for the first time                      
                    initBody(player) -- equip body items to player
                    graphicalEnhance(player) 
                end
            end
        end

        Events.OnServerCommand.Add(onServerCommandStopAndInit)
    else
        initModData(player) -- initialize modData when new player is created for the first time
        initBody(player) -- equip body items to player
        graphicalEnhance(player)
    end     
end

Events.OnNewGame.Add(mainInitFunction) -- init player and data on new game



-- when game starts, we have to reset some modData to default values so that player creation works properly; in case there no modData present, we
-- we initalize them with random data (can happen when mod is added to an existing game)
local function setUpModData(player)

    local data = player:getModData()
    if (not data.RasBodyMod) or (not data.RasBodyMod.ModVersion) then
        randomizeModData(player) -- randomize modData 
    end

    if (not SandboxVars.RasBodyMod.PerformanceMode) and (data.RasBodyMod.PlayerMode == "cover" or data.RasBodyMod.PlayerMode == "coverWalk") then
        data.RasBodyMod.PlayerMode = "cover"
    else
        data.RasBodyMod.PlayerMode = "default"
    end  
    data.RasBodyMod.PenisType = "None" -- must always be None when game starts
end


-- when player loads a game with an existing character
local function mainStartFunction()
 
    if PLAYER_INIT then -- only when player isn't already initialized (i.e. only when game with an existing player is loaded)
        return
    end

    local player = getPlayer()

    if isClient() then -- for MP; the procedure is mainly the same as in the init function but this time for loading a game with an existing character  
     
        local startTick = nil
        local function loadInMP(tick)
            if not startTick then
                startTick = tick
            end
            if tick >= startTick + 3 then 
                sendClientCommand(player, "rasBodyMod", "loadPlayer", {}) -- send commands until server responds for the first time 
            end                                                           
        end
        
        Events.OnTick.Add(loadInMP)   

        local function onServerCommandStopAndLoad(mod, command, args)
            if mod == "rasBodyMod" then
                if command == "stopRequestingAndLoad" then -- when server responds the first time, we stop sending load commands and execute the load functions
                    Events.OnTick.Remove(loadInMP) -- remove from events
                    Events.OnServerCommand.Remove(onServerCommandStopAndLoad)
        
                    local data = player:getModData()
                    if args then
                        data.RasBodyMod = args.modData -- modData coming from server (note: args table will be nil when mod is added to an existing game) 
                    end 
                    setUpModData(player)
                    initBody(player) -- equip body items to player
                    graphicalEnhance(player)
                end
            end
        end

        Events.OnServerCommand.Add(onServerCommandStopAndLoad)
     
    else -- for SP        
        setUpModData(player)
        initBody(player) -- equip body items to player 
        graphicalEnhance(player)                    
    end          
end

Events.OnGameStart.Add(mainStartFunction) -- load data and equip correct items whenever player starts or loads a game



local createPlayerInMP = {} -- can be accessed by other luas in client folder via require("RasBodyModCreatePlayer"); only used in MP


-- for calibrating male characters in MP
function createPlayerInMP.calibrateMalePlayer(player)

    if (not SandboxVars.RasBodyMod.PerformanceMode) and (not player:isFemale()) then
        Events.OnTick.Add(calibrateMale)
    end
end


return createPlayerInMP





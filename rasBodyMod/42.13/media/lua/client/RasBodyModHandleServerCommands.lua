-- handle commands coming from server
--
--
-- by razab





local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG") 
local createPlayerInMP = require("RasBodyModCreatePlayer")



local function onServerCommand(mod, command, args)

    if mod == "rasBodyMod" then 
        if command == "customClothingUpdate" then
            local player = getPlayer()
            manageBody.CustomClothingUpdate(player)             
        elseif command == "updateAvatar" then
            if ISCharacterInfoWindow and ISCharacterInfoWindow.instance and ISCharacterInfoWindow.instance.charScreen then
                ISCharacterInfoWindow.instance.charScreen.refreshNeeded = true 
            end   
        elseif command == "createPlayerOnClient" then
            local player = getPlayer()
            if args then
                createPlayerInMP.create(player, args.modData)
            else
                createPlayerInMP.create(player, nil)
            end
        elseif command == "calibrateMale" then
            local player = getPlayer()
            createPlayerInMP.calibrate(player)
        elseif command == "triggerClothingUpdate" then
            local player = getPlayer()
            triggerEvent("OnClothingUpdated", player)
        end
    end
end


Events.OnServerCommand.Add(onServerCommand)

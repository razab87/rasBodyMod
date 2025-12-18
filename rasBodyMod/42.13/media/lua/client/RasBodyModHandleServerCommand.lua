-- handle command coming from server
--
--
-- by razab



local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG") 

local function onServerCommand(mod, command, nonPlayer, args)

    if mod == "rasBodyMod" and command == "clothingUpdate" then
        local player = getPlayer()
        manageBody.onClothingUpdate(player)
    end
end



Events.OnServerCommand.Add(onServerCommand)

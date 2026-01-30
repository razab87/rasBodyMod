-- util function: put ManageMalePrivatePart with approriate args to the queue, then call manageBody.executeQueue to execute the function;
-- when optimizing animation visual, we only need to use ManageMalePrivatePart, so we can just hardcode it here
--
--
-- by razab


local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG")


local util = {} -- can be accessed via require("ManageAnimations/RasBodyModAnimUtil.lua")

function util.equipNow(player)

    local data = player:getModData().RasBodyMod

    local groinNude = data.GroinNudeDefault
    if data.PlayerMode ~= "default" and data.PlayerMode ~= "turn" then
        groinNude = data.GroinNudeSitting
    end

    if groinNude then -- only when private part is visible
        local queue = { {functionName = "ManageMalePrivatePart", args = {}},
                        {functionName = "TransferDirtToSkin", args = {}} -- vanilla game sometimes removes dirt visuals from body when clothing items are (un-)equipped (??); this command seems to fix it
                      }
        manageBody.executeQueue(player, queue, false)
    elseif isClient() then -- in MP, we still may have to sync modData since some player modes are save game persistent
        if data.PlayerMode == "default" or data.PlayerMode == "cover" then
            sendClientCommand(player, "rasBodyMod", "syncModData", {modData = data})
        end
    end
end


return util

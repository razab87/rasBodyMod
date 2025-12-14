-- when event OnClothingUpdate is triggered on server, we send a command to the client so that it can execute the
-- appropriate functions
--
--
-- by razab




local function onClothingUpdate(player)
    
    if isServer() then
        sendServerCommand(player, "rasBodyMod", "clothingUpdate", {})
    end
end




Events.OnClothingUpdated.Add(onClothingUpdate)

-- compatibility for the mod Yaki's Barber Shop




local rasSharedData = require("RasBodyModSharedData")


local modInfo = getModInfoByID("YakiBS")
if modInfo and isModActive(modInfo) then

    if rasSharedData and rasSharedData.FullBeards then
       rasSharedData.FullBeards["DuckTail"] = true
       rasSharedData.FullBeards["FrenchFork"] = true      
    end

end




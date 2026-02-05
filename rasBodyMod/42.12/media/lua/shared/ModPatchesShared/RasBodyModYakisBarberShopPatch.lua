-- compatibility for the mod Yaki's Barber Shop




local rasSharedData = require("RasBodyModSharedData")


if getActivatedMods():contains("\\YakiBS42") then

    if rasSharedData and rasSharedData.FullBeards then
       rasSharedData.FullBeards["DuckTail"] = true
       rasSharedData.FullBeards["FrenchFork"] = true      
    end
end




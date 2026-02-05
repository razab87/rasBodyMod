-- compatibility for the mod Tariq's Beards




local rasSharedData = require("RasBodyModSharedData")


local modInfo = getModInfoByID("Tariq's Beards")
if modInfo and isModActive(modInfo) then

    if rasSharedData and rasSharedData.FullBeards then
       rasSharedData.FullBeards["Tsar"] = true
       rasSharedData.FullBeards["Bandholz"] = true
       rasSharedData.FullBeards["Kratos"] = true
       rasSharedData.FullBeards["Homeless"] = true
       rasSharedData.FullBeards["Axe"] = true
       rasSharedData.FullBeards["AxeM"] = true
       rasSharedData.FullBeards["Santatest"] = true
       rasSharedData.FullBeards["braidedbeardred"] = true
       rasSharedData.FullBeards["braidbeard"] = true
       rasSharedData.FullBeards["MexicanStyle"] = true
       rasSharedData.FullBeards["Thor"] = true
    end

end




-- add some clothing items from the mod "The Last of Us: Factions & Gear" to ExceptionalClothes table so that they correctly hide the male private part
-- when worn by male characters
--
--
-- by razab



local rasSharedData = require("RasBodyModSharedData")

local modInfo = getModInfoByID("TLOUClothingFEDRA")
if modInfo and isModActive(modInfo) then

  if not rasSharedData.ExceptionalClothes["Dress"] then
           rasSharedData.ExceptionalClothes["Dress"] = {}
  end
  rasSharedData.ExceptionalClothes["Dress"]["TLOU.Suit_Fedra"] = { hideWhileStanding = true, hideWhileSitting = true }

end

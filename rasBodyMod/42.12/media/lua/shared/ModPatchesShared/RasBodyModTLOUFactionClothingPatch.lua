-- add some clothing items from the mod "The Last of Us: Factions & Gear" to ExceptionalClothes table so that they correctly hide the male private part
-- when worn by male characters
--
--
-- by razab



local rasSharedData = require("RasBodyModSharedData")

if getActivatedMods():contains("\\TLOUClothingFEDRA") then

  if not rasSharedData.ExceptionalClothes["Dress"] then
           rasSharedData.ExceptionalClothes["Dress"] = {}
  end
  rasSharedData.ExceptionalClothes["Dress"]["TLOU.Suit_Fedra"] = { hideWhileStanding = true, hideWhileSitting = true }

end

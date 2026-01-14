

Here is a guide for modders showing how to make a clothing mod compatible with ra's Body Mod.


How to avoid clipping issues in case of male characters


Some modded clothing items may cause clipping issues when worn by male characters. Specifically, the male "extra 3d object" may clip through clothes. How to avoid this? The mod is configured in a way so that clothing items from the following body locations will automatically hide the male 3d object:

   UnderwearBottom, Underwear, Torso1Legs1, Legs1, Pants, FullSuit, FullSuitHead, BathRobe, Boilersuit, Jacket_Down (B41 list, for B42 see ... 42/media/lua/shared/NPCs/RasBodyModLocations.lua)

Hence, all modded clothing items assigned to those locations will never cause any clipping issues and you don't have to do anything special for them. However, there are body locations which contain some clothes which should hide the 3d object while others clothes from the locations should not. (Example: The b41 vanilla "Jacket" location contains short jackets which should not hide the object and longer jackets which should hide it.) Clothes from those locations should therefore be treated manually. So, if your mod contains a clothing item which 

1. does not belong to one of the body locations listed above and 
2. hides the groin area and is therefore prone to clipping 

you have to manually tell the game that the respective clothing item should hide the male 3d object. To achieve this, simply add the following lines of lua code to your mod's shared folder:


   if getActivatedMods():contains("\\rasBodyMod") then -- check if ra's Body Mod is enabled

-- in B41, use   
--    local modInfo = getModInfoByID("rasBodyMod")
--    if modInfo and isModActive(modInfo) then
-- instead as first lines
         
           local rasSharedData = require("RasBodyModSharedData") -- import data from ra's Body Mod

           if rasSharedData and rasSharedData.ExceptionalClothes then -- just in case...
                if not rasSharedData.ExceptionalClothes["BodyLocation"] then
                    rasSharedData.ExceptionalClothes["BodyLocation"] = {}  -- initialize a new field for the body location in case it is not already present
                end
                rasSharedData.ExceptionalClothes["BodyLocation"]["Base.YourClothingItem"] = { hideWhileStanding = true, hideWhileSitting = true } -- hide the male 3d object when wearing "YourClothingItem"
                rasSharedData.ExceptionalClothes["BodyLocation"]["Base.YourClothingItem2"] = { hideWhileStanding = true, hideWhileSitting = true } 
               
                -- this can be done for several body locations:

                if not rasSharedData.ExceptionalClothes["AnotherBodyLocation"] then
                    rasSharedData.ExceptionalClothes["AnotherBodyLocation"] = {}  -- in case you have a second body locaion which may cause trouble...
                end
                rasSharedData.ExceptionalClothes["AnotherBodyLocation"]["Base.AnotherClothingItem"] = { hideWhileStanding = true, hideWhileSitting = true }

                -- and so on...
 
           end
   end


"BodyLocation" is the body location your clothing item belongs to (example: "Jacket"). "Base.YourClothingItem" the item's script.txt ID (ofc, replacing "Base." with a suitable module in case you use a different one). The parameter "hideWhileSitting" tells the game whether the male 3d object should be hidden when the male character is in the sitting animation. For example, for the vanilla mini skirt, we would like to have

               rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Mini"] = { hideWhileStanding = true, hideWhileSitting = false }

Result: When male characters wear a mini skirt and no underpants, the 3d object will be hidden when standing/walking/running but will be visible when sitting.


The above procedure also works for modded body locations (presupposed that your mod does not simply overwrite the whole vanilla BodyLocations.lua; general suggestion: when modding body location, NEVER simply overwrite the BodyLocations.lua because this could make your mod incompatible with any other mod touching the body location system!).


In case there are any questions or if you think something doesn't work properly, feel free to ask.

Thanks for reading! :D



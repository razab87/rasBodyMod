-- patch for the mod "Clothes Box Redux"; add some modded clothig items to the ExceptionalClothes table to make sure that no glitches occur when worn by male characters; also add clothes to the UndressLocation 
-- table so that they get undressed when shaving body hair
--
--
-- by razab


local rasSharedData = require("RasBodyModSharedData")

local modInfo = getModInfoByID("ClothesBoxRedux")
if modInfo and isModActive(modInfo) then

        -- add items to ExceptionalClothes

        -- Jacket location
        if not rasSharedData.ExceptionalClothes["Jacket"] then
              rasSharedData.ExceptionalClothes["Jacket"] = {}
        end
        rasSharedData.ExceptionalClothes["Jacket"]["Base.CBX_Kurtk_10"] = { hideWhileStanding = true, hideWhileSitting = true }   
        rasSharedData.ExceptionalClothes["Jacket"]["Base.CBX_Kurtk_7"] = { hideWhileStanding = true, hideWhileSitting = true } 
        rasSharedData.ExceptionalClothes["Jacket"]["Base.CBX_Kurtk_7_1"] = { hideWhileStanding = true, hideWhileSitting = true } 
        rasSharedData.ExceptionalClothes["Jacket"]["Base.CBX_Kurtk_8"] = { hideWhileStanding = true, hideWhileSitting = true } 
        rasSharedData.ExceptionalClothes["Jacket"]["Base.CBX_RUB"] = { hideWhileStanding = true, hideWhileSitting = true } 
        rasSharedData.ExceptionalClothes["Jacket"]["Base.CBX_Kurtk_2"] = { hideWhileStanding = true, hideWhileSitting = true } 

        -- custom location "010" 
        rasSharedData.ExceptionalClothes["010"] = {}
        rasSharedData.ExceptionalClothes["010"]["Base.CBX_Waterproof"] = { hideWhileStanding = true, hideWhileSitting = true } 


        -- add items to UndressLocation Table for undressing when shaving

        -- for shaving pubic hair
        rasSharedData.UndressLocation.Pubic["010"] = {exceptions = {}} -- coverall and tactical stuff
        rasSharedData.UndressLocation.Pubic["888"] = {exceptions = {}} -- bags attached to leg
        rasSharedData.UndressLocation.Pubic["898"] = {exceptions = {}} -- bags attached to leg

        -- for shaving armpits and chest
        rasSharedData.UndressLocation.Chest["101"] = {exceptions = {}} -- duster
        rasSharedData.UndressLocation.Chest["010"] = {exceptions = {}} -- coverall and tactical stuff 
        rasSharedData.UndressLocation.Chest["999"] = {exceptions = {}} -- satchel type bags
        rasSharedData.UndressLocation.Chest["989"] = {exceptions = {}} -- satchel type bags

        -- for shaving legs
        rasSharedData.UndressLocation.Legs["101"] = {exceptions = {}} -- duster
        local customExceptions = {}
        customExceptions["Base.CBX_Ras_army"] = true
        customExceptions["Base.CBX_Ras_ohota"] = true
        rasSharedData.UndressLocation.Legs["010"] = {exceptions = customExceptions} -- coverall and tactical stuff
        rasSharedData.UndressLocation.Legs["888"] = {exceptions = {}} -- bags attached to leg
        rasSharedData.UndressLocation.Legs["898"] = {exceptions = {}} -- bags attached to leg
end





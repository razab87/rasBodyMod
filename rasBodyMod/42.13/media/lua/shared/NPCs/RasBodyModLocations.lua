-- add new body locations; prefix them to the list of body locations for correct rendering order; executed via lua event OnGameBoot; vanilla body locations and any body location from mods loaded before
-- the Body Mod are not overwritten (they will be backuped, deleted, then restored and after the new body locations from this mod have been created)  
--
--
-- by razab





local function addLocations()
    local oldGroup = BodyLocations.getGroup("Human")
    local allLocations = oldGroup:getAllLocations()
    local size = allLocations:size()
    
    local backUpLocations = {}
    local backUpExclusive = {}
    local backUpHideModel = {}
    local backUpMultiItem = {}
    local backUpAltModel = {}
        
    for i=1,size do -- backup old body locations; we also store the information about "setExclusive", "setHideModel", "setMultiItem" and "setAltModel"
        local bodyLocation = allLocations:get(i-1):getId()
        backUpLocations[i] = bodyLocation
        backUpExclusive[bodyLocation] = {}
        backUpHideModel[bodyLocation] = {}
        backUpAltModel[bodyLocation] = {}
        for j=1,size do -- remember which body locations are excluded, hidden and have AltModels
                local location = allLocations:get(j-1):getId()
                if oldGroup:isExclusive(bodyLocation, location) then
                    table.insert(backUpExclusive[bodyLocation],location)
                end
                if oldGroup:isHideModel(bodyLocation, location) then
                    table.insert(backUpHideModel[bodyLocation],location) -- ordering is important: bodyLocation (key) hides location
                end
                if oldGroup:isAltModel(bodyLocation, location) then
                    table.insert(backUpAltModel[bodyLocation], location)
                end
        end
        backUpMultiItem[bodyLocation] = false
        if oldGroup:isMultiItem(bodyLocation) then
               backUpMultiItem[bodyLocation] = true
        end
    end
       
    BodyLocations:reset() -- delete old body locations
    
    -- we re-create the body location list but with our new body locations at the top
    local group = BodyLocations.getGroup("Human")
    
    local newLocations = {RasBodyModRegistries.Skin, RasBodyModRegistries.ChestHair, RasBodyModRegistries.ArmpitHair, RasBodyModRegistries.PubicHair, RasBodyModRegistries.LegHair, 
                          RasBodyModRegistries.BeardStubble, RasBodyModRegistries.HeadStubble, RasBodyModRegistries.MalePrivatePart}
    for _,v in pairs(newLocations) do -- add new body locations
        group:getOrCreateLocation(v)
    end
    
    for i=1,size do  -- append old body locations
         group:getOrCreateLocation(backUpLocations[i])
    end
    
    for i=1,size do  -- re-define setExclusive, setHideModel, setMultiItem and setAltModel for old body locations
        local bodyLocation = backUpLocations[i]
        if backUpExclusive[bodyLocation] then
            for _,value in pairs(backUpExclusive[bodyLocation]) do
                if not group:isExclusive(bodyLocation, value) then
                    group:setExclusive(bodyLocation, value)
                end
            end
        end
        if backUpHideModel[bodyLocation] then
            for _,value in pairs(backUpHideModel[bodyLocation]) do
                group:setHideModel(bodyLocation, value) -- note: bodyLocation hides value
            end
        end
        if backUpAltModel[bodyLocation] then
            for _,value in pairs(backUpAltModel[bodyLocation]) do
                group:setAltModel(bodyLocation, value)
            end
        end
        if backUpMultiItem[bodyLocation] then
            group:setMultiItem(bodyLocation, true)
        end
    end
    
    -- some body locations should hide MalePrivatePart
    local x = RasBodyModRegistries.MalePrivatePart
    group:setHideModel(ItemBodyLocation.UNDERWEAR_BOTTOM, x)
    group:setHideModel(ItemBodyLocation.UNDERWEAR, x)
    group:setHideModel(ItemBodyLocation.TORSO1LEGS1, x)
    group:setHideModel(ItemBodyLocation.PANTS, x)
    group:setHideModel(ItemBodyLocation.PANTS_SKINNY, x)
    group:setHideModel(ItemBodyLocation.FULL_SUIT, x)
    group:setHideModel(ItemBodyLocation.FULL_SUIT_HEAD, x)
    group:setHideModel(ItemBodyLocation.BATH_ROBE, x)
    group:setHideModel(ItemBodyLocation.BOILERSUIT, x)
    group:setHideModel(ItemBodyLocation.CODPIECE, x)
    group:setHideModel(ItemBodyLocation.JACKET_HAT, x)
    group:setHideModel(ItemBodyLocation.LONG_SKIRT, x)
    group:setHideModel(ItemBodyLocation.PANTS_EXTRA, x)
    group:setHideModel(ItemBodyLocation.JACKET_DOWN, x)
    group:setHideModel(ItemBodyLocation.SHORT_PANTS, x)
    group:setHideModel(ItemBodyLocation.SHORTS_SHORT, x)
    -- other clothing items which should hide the penis are managed manually via the table "rasSharedData.ExceptionalClothing" (see this mod, RasBodyModSharedData.lua in shared)                
end



Events.OnGameBoot.Add(addLocations)







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
        
    for i=1,size do -- backup old body locations; we also store the information about "setExclusive", "setHideModel" and "setMultiItem"
        local bodyLocation = allLocations:get(i-1):getId()
        backUpLocations[i] = bodyLocation
        backUpExclusive[bodyLocation] = {}
        backUpHideModel[bodyLocation] = {}
        for j=1,size do -- remember which body locations are excluded and hidden
                local location = allLocations:get(j-1):getId()
                if oldGroup:isExclusive(bodyLocation, location) then
                      table.insert(backUpExclusive[bodyLocation],location)
                end
                if oldGroup:isHideModel(bodyLocation, location) then
                      table.insert(backUpHideModel[bodyLocation],location) -- ordering is important: bodyLocation (key) hides location
                end
        end
        backUpMultiItem[bodyLocation] = false
        if oldGroup:isMultiItem(bodyLocation) then
               backUpMultiItem[bodyLocation] = true
        end
    end
       
    BodyLocations:Reset() -- delete old body locations
    
    -- we re-create the body location list but with our new body locations at the top
    local group = BodyLocations.getGroup("Human")
    
    local newLocations = {"RasSkin", "RasChestHair", "RasArmpitHair", "RasPubicHair", "RasLegHair", "RasBeardStubble", "RasHeadStubble", "RasMalePrivatePart"}
    for _,v in pairs(newLocations) do -- add new body locations
        local bodyLocation = BodyLocation.new(group, v)
        group:getAllLocations():add(bodyLocation)
    end
    
    for i=1,size do  -- append old body locations
         local bodyLocation = BodyLocation.new(group, backUpLocations[i])
         group:getAllLocations():add(bodyLocation)
    end
    
    for i=1,size do  -- re-define setExclusive, setHideModel and setMultiItem for old body locations
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
         if backUpMultiItem[bodyLocation] then
               group:setMultiItem(bodyLocation, true)
         end
    end
    
    -- some body locations should hide MalePrivatePart (location for the penis model)
    group:setHideModel("UnderwearBottom", "RasMalePrivatePart")
    group:setHideModel("Underwear", "RasMalePrivatePart")
    group:setHideModel("Torso1Legs1", "RasMalePrivatePart")
    group:setHideModel("Pants", "RasMalePrivatePart")
    group:setHideModel("Pants_Skinny", "RasMalePrivatePart")
    group:setHideModel("FullSuit", "RasMalePrivatePart")
    group:setHideModel("FullSuitHead", "RasMalePrivatePart")
    group:setHideModel("BathRobe", "RasMalePrivatePart")
    group:setHideModel("Boilersuit", "RasMalePrivatePart")
    group:setHideModel("Codpiece", "RasMalePrivatePart")
    group:setHideModel("JacketHat", "RasMalePrivatePart")
    group:setHideModel("LongSkirt", "RasMalePrivatePart")
    group:setHideModel("PantsExtra", "RasMalePrivatePart")
    group:setHideModel("Jacket_Down", "RasMalePrivatePart")
    group:setHideModel("ShortPants", "RasMalePrivatePart")
    group:setHideModel("ShortsShort", "RasMalePrivatePart")
    -- other clothing items which should hide the penis are managed manually via the table "rasSharedData.ExceptionalClothing" (see this mod, RasBodyModSharedData.lua in shared)                
end



Events.OnGameBoot.Add(addLocations)







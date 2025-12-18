-- compatibility patch for the mod "Anthro Survivors"; make body location "Fur" hide the male private part so that no clipping issues with the "anthro"
-- costumes arise; necessary to to this in client since the anthro mod creates the body location "Fur" in client folder
--
--
-- by razab



local function anthroPatch()

    if getActivatedMods():contains("\\FurryMod") then
        local group = BodyLocations.getGroup("Human")
        if group:getLocation("Fur") then 
            group:setHideModel("Fur", "RasMalePrivatePart")
        end
    end
end


Events.OnGameBoot.Add(anthroPatch)

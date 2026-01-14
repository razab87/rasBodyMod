-- compatibility patch for the mod "Anthro Survivors"; make body location "Fur" hide the male private part so that no clipping issues with the "anthro"
-- costumes arise; necessary to to this in client since the anthro mod creates the body location "Fur" in client folder
--
--
-- by razab


local Regs = RasBodyModRegistries


local function anthroPatch()

    if getActivatedMods():contains("\\FurryMod") then
        local group = BodyLocations.getGroup("Human")
        if group:getLocation("Fur") then 
            group:setHideModel("Fur", Regs.MalePrivatePart)  -- important: not yet functional until the Anthro Survivor Mod gets updated for 42.13!!!!
        end
    end
end


Events.OnGameBoot.Add(anthroPatch)

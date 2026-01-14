-- compatibility patch for the mod "Anthro Survivors"; make body location "Fur" hide the male private part so that no clipping issues with the "anthro"
-- costumes arise; seems necessary to do this in client since the anthro mod creates the body location "Fur" in client folder
--
--
-- by razab



local function anthroPatch()

  local modInfo = getModInfoByID("FurryMod")
  if modInfo and isModActive(modInfo) then -- only if Anthro mod is active
        local group = BodyLocations.getGroup("Human")
        if group:getLocation("Fur") then 
            group:setHideModel("Fur", "RasMalePrivatePart")
        end
  end
end


Events.OnGameBoot.Add(anthroPatch)

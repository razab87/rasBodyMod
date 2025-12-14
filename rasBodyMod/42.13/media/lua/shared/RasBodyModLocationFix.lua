-- in B42, some professions get their clothes applied to the wrong body locations: Base.Vest_HighViz assigned to TorsoExtra during character creation as in B41 while in B42, it should be
-- TorsoExtraVest; we need to fix this since the wrong location will mess up our fix of a graphics glitch which is caused by those vests
--
--
-- by razab




local function containsVest(aTable)
        for _,v in pairs(aTable) do
             if v == "Base.Vest_HighViz" then
                 return true
             end
        end

        return false
end

local function removeVest(aTable)
        for i,v in pairs(aTable) do
              if v == "Base.Vest_HighViz" then
                    table.remove(aTable, i)
              end
        end
end


-- apply the fix to the vanilla clothing table
local function fixLocation()

    local vanillaDef = ClothingSelectionDefinitions -- vanilla clothing table
    local professions = { "constructionworker", "electrician", "metalworker", "engineer" }
    for _,prof in pairs(professions) do
        if vanillaDef[prof] and vanillaDef[prof]["Female"] then
            if vanillaDef[prof]["Female"]["TorsoExtra"] and vanillaDef[prof]["Female"]["TorsoExtra"]["items"] 
               and containsVest(vanillaDef[prof]["Female"]["TorsoExtra"]["items"]) then -- only if a vest is assigned to a wrong body location (may change due to vanilla updates or other mods)

                removeVest(vanillaDef[prof]["Female"]["TorsoExtra"]["items"]) -- remove vest from wrong location
                if #vanillaDef[prof]["Female"]["TorsoExtra"]["items"] == 0 then
                    vanillaDef[prof]["Female"]["TorsoExtra"] = nil -- delete TorsoExtra option if empty
                end 

                if not vanillaDef[prof]["Female"]["TorsoExtraVest"] then
                   vanillaDef[prof]["Female"]["TorsoExtraVest"] = { } -- init slot for correct location
                end

                if not vanillaDef[prof]["Female"]["TorsoExtraVest"]["items"] then
                   vanillaDef[prof]["Female"]["TorsoExtraVest"]["items"] = { } 
                end

                if not containsVest(vanillaDef[prof]["Female"]["TorsoExtraVest"]["items"]) then
                    table.insert(vanillaDef[prof]["Female"]["TorsoExtraVest"]["items"], "Base.Vest_HighViz") -- add vest and chance to correct location
                    if not vanillaDef[prof]["Female"]["TorsoExtraVest"]["chance"] then
                        vanillaDef[prof]["Female"]["TorsoExtraVest"]["chance"] = 30
                    end 
                end
            end                                     
        end
    end
end


Events.OnGameBoot.Add(fixLocation)



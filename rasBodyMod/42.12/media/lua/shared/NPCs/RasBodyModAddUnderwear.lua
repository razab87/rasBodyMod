-- add some underwear options to the vanilla default clothing table so that they are available during character creation (vanilla clothing table is defined in the vanilla folder 
-- shared/Definitions/ClohtingSelectionDefinitions)
--      
--
-- by razab






-- the clothing we want to add
local customClothingDefinitions = {}
customClothingDefinitions.default = {
           Female = {
               UnderwearTop = { items = {"Base.Bra_Straps_White", "Base.Bra_Strapless_White"}},               
               UnderwearBottom = { items = {"Base.Underpants_White"}},
           },
           Male = {
              UnderwearBottom = { items = {"Base.Briefs_White", "Base.Boxers_White"}}
           }
}



-- initialize slots in vanilla clothing table in case they aren't defined already (slot is initialised it with an empty table {})
local function initDefaultClothingSlot(gender,bodyLocation) 
         local vanillaDefs = ClothingSelectionDefinitions -- the vanilla clothing table
         if not vanillaDefs["default"] then 
                    vanillaDefs["default"] = { }
                    vanillaDefs["default"][gender] = { }
                    vanillaDefs["default"][gender][bodyLocation] = { items = { } } 
         elseif not vanillaDefs["default"][gender] then
                    vanillaDefs["default"][gender] = { }
                    vanillaDefs["default"][gender][bodyLocation] = { items = { } }
         elseif not vanillaDefs["default"][gender][bodyLocation] then
                    vanillaDefs["default"][gender][bodyLocation] = { items = { } }  

         end                
end

-- check whether table contains value
local function containsValue(myTable,value)  
         for i,v in pairs(myTable) do
               if v == value then return true end
         end
         return false
end


-- append the new clothing defined in the mod's media/lua/shared/Definitions/RasProfessionsClothing.lua to the vanilla clothing list
local function addCustomClothing()
      local newDefs = customClothingDefinitions
      local vanillaDefs = ClothingSelectionDefinitions -- the vanilla clothing table
      for _, gender in pairs{"Female", "Male"} do 
               for bodyLocation, value in pairs(newDefs["default"][gender]) do
                    if value then
                           initDefaultClothingSlot(gender,bodyLocation) -- create clothing slots
                           if value.items then  
                                for _,clothingItem in pairs(value.items) do
                                          if not containsValue(vanillaDefs["default"][gender][bodyLocation]["items"], clothingItem) then -- no double elements!
                                                       table.insert(vanillaDefs["default"][gender][bodyLocation]["items"], clothingItem)
                                          end
                                end
                           end
                    end
               end
      end
end 

       
Events.OnGameBoot.Add(addCustomClothing)










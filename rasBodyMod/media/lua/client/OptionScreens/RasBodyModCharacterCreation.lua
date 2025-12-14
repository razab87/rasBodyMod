-- this file contains the code which will make the "Character Customisation Screen" work; includes:
--
--       - choose different body hair styles; introduce appropriate combo boxes
--       - introduce "Remove All" button for clothing
--       - align skin and penis automatically with the skin color; there are also some adjustements applied to body hair depending on skin color (some skin colors get different hair items for better visuals)
--       - (un-)equip penis model according to worn clothes (must sometimes be done manually, cf. "ExceptionalClothes" in RasBodyModSharedData.lua, shared)
--
-- we need to arrange things so that new body items are not shown in the clothing section although they are technically realized as clothing items; 
--
-- some functions from the vanilla lua /media/lua/client/OptionScreens/CharacterCreationMain.lua are modified; this happens in the third part of the file; first two parts contain new
-- functions
--
--
-- by razab





local rasClientData = require("RasBodyModClientData")
local rasSharedData = require("RasBodyModSharedData")


local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

local yCoordinate -- will store the y-coordinate for the body hair section
local startYCoordinate -- will store the y-coordinate of the first line

local RasAllClothingUnlocked = false -- needed to make it work with all-clothing-unlocked









--------------------------------- FIRST PART: some util functions used in the code -------------------------------------------------




-- check whether bodyLocation is acutally a location for clothing (and not for skin/body hair/penis)
local function isClothingLocation(location)

       if rasSharedData.BodyHairLocations[location] or location == "RasMalePrivatePart" or location == "RasSkin" or location == "RasBeardStubble" or location == "RasHeadStubble" then
            return false
       end
      
       return true
end
 



-- check whether player's torso and groin area are nude so that we may apply the vestGlitchFix below
local function torsoNude(desc)

     local locations = rasSharedData.TorsoLocations
     for _,loc in pairs(locations) do
              local item = desc:getWornItem(loc)
              if item and not rasSharedData.TorsoLocationsException[item:getFullType()] then
                  return false
              end
     end 

     return true
end



-- this function fixes a graphical glitch which occurs when players wear certain type of vests (e.g. some bullet proof vests) and
-- are nude at lower torso and groin area; solution: since the glich is due to the masking parameters of the vests, we replace the vanilla
-- vest in that specific situation with a custom vest with different mask definitions (clipping should not occur since the situation does not
-- occur when cloth with 3d models are worn)
local function vestGlitchFix(desc)

      local locations = {"TorsoExtraVest"}
      for _,loc in pairs(locations) do
          local item = desc:getWornItem(loc)
          if item and rasSharedData.GlitchedItems[item:getFullType()] then
                 local visual = item:getVisual()   
                 if visual then
                         local visualType = visual:getItemType()   
                         if rasSharedData.GlitchedItems[visualType] then -- replace vanilla vest with a glitch-fix vest
                               if torsoNude(desc) then
                                    local newItem = rasSharedData.GlitchedItems[visualType]
                                    local texture = visual:getTextureChoice()
                                    
                                    visual:setItemType(newItem) 
                                    visual:setClothingItemName(newItem)
                                    if texture then
			                             visual:setTextureChoice(texture) -- also apply correct extra texture ("Type 1", "Type 2" etc)
                                    end
                               end
                         elseif rasSharedData.GlitchedItemsReverse[visualType] then -- replace glitch-fix vest with vanilla vest
                             if not torsoNude(desc) then
                                 local newItem = rasSharedData.GlitchedItemsReverse[visualType]
                                 local texture = visual:getTextureChoice()
                                    
                                 visual:setItemType(newItem) 
                                 visual:setClothingItemName(newItem)
                                 if texture then
	                                 visual:setTextureChoice(texture) -- also apply correct extra texture ("Type 1", "Type 2" etc)
                                 end
                            end
                        end
                 end
           end
     end
end






-- checks whether an exceptional clothing item is worn
local function wearsExceptionalClothing(desc)
      local myTable = rasSharedData.ExceptionalClothes

      local locationGroup = BodyLocations.getGroup("Human")
      for bodyLocation,_ in pairs(myTable) do
               if locationGroup:getLocation(bodyLocation) then
                       local item = desc:getWornItem(bodyLocation)
                       if item then
                              local itemName = item:getFullType()
                              if myTable[bodyLocation][itemName] then
                                      if myTable[bodyLocation][itemName]["hideWhileStanding"] then
                                             return true

                                      end
                              end
                       end
               end
      end 

      return false
end



-- equip male character with penis texture and align with skin color
local function manageMalePrivatePart(desc, skinColorIndex)      
      if not desc:isFemale() then
            local pubicHair = rasClientData.SelectedBodyHair.Male.RasPubicHair
            if wearsExceptionalClothing(desc) then
                desc:setWornItem("RasMalePrivatePart", nil)
            elseif rasSharedData.PenisTable[skinColorIndex] and rasSharedData.PenisTable[skinColorIndex]["default"] then
                  local itemID = rasSharedData.PenisTable[skinColorIndex]["default"]
                  local pubicHair = rasClientData.SelectedBodyHair.Male.RasPubicHair
                  if pubicHair ~= "None" then
                       itemID = itemID .. "_Hair"
                  end
                  item = InventoryItemFactory.CreateItem(itemID)
                  desc:setWornItem("RasMalePrivatePart", item)
            end
            CharacterCreationHeader.instance.avatarPanel:setSurvivorDesc(desc)
      end
end





-- equip body hair
local function equipBodyHair(desc, bodyLocation, skinColor)

     local gender = "Male"
     if desc:isFemale() then
          gender = "Female"
     end

     local hairItem = rasClientData.SelectedBodyHair[gender][bodyLocation] -- get default body hair item

     if hairItem == "None" then
         desc:setWornItem(bodyLocation, nil)
     else          
         -- some skin colors might get slightly different hair items for better visuals
         local optimizedItem = hairItem
         local optimizedTable = rasSharedData.OptimizedBodyHair[gender]
         if optimizedTable[skinColor] then
                optimizedItem = hairItem .. "_" .. optimizedTable[skinColor]
         end         

         local item = InventoryItemFactory.CreateItem(optimizedItem)
         if not item then -- if optimized version of item doesn't exist, take default version
             item = InventoryItemFactory.CreateItem(hairItem)
         end
         
         desc:setWornItem(bodyLocation, item)
     end               

     CharacterCreationHeader.instance.avatarPanel:setSurvivorDesc(desc)
end







-- equip correct skin
local function equipSkin(desc, skinColor) 
    local gender = "Male"
    if desc:isFemale() then
         gender = "Female"
    end
    desc:setWornItem("RasSkin", nil)
            
    if gender == "Male" then -- for males
          local skinID = rasSharedData.Skins.Male[skinColor]
          local skin = InventoryItemFactory.CreateItem(skinID)
          desc:setWornItem("RasSkin", skin)
    else -- for females  
          local skinID = rasSharedData.Skins.Female[skinColor]
          local skin = InventoryItemFactory.CreateItem(skinID)
          desc:setWornItem("RasSkin", skin)
    end
    
    CharacterCreationHeader.instance.avatarPanel:setSurvivorDesc(desc)
end






-- assign random body hair to characters; is called in initClothing when "random" button is pressed; 
-- we make it such that the body hair styles fit to early 90s trends, i.e. not too much shaved
local function assignRandomBodyHair(desc)
         if desc:isFemale() then -- for female
               -- assign pubic hair
               local n = ZombRand(101)
               if n <= 55 then        
                    rasClientData.SelectedBodyHair["Female"]["RasPubicHair"] = "RasBodyMod.FemalePubicNatural"
               elseif n <= 85 then
                    rasClientData.SelectedBodyHair["Female"]["RasPubicHair"] = "RasBodyMod.FemalePubicTrimmed"
               elseif n <= 95 then
                   rasClientData.SelectedBodyHair["Female"]["RasPubicHair"] = "RasBodyMod.FemalePubicStrip"
               else
                    rasClientData.SelectedBodyHair["Female"]["RasPubicHair"] = "None"
               end 
               -- armpit
               n = ZombRand(101)
               if n <= 25 then
                   rasClientData.SelectedBodyHair["Female"]["RasArmpitHair"] = "RasBodyMod.FemaleArmpit"
               else
                   rasClientData.SelectedBodyHair["Female"]["RasArmpitHair"] = "None"
               end
               -- legs
               n = ZombRand(101)
               if n <= 5 then
                   rasClientData.SelectedBodyHair["Female"]["RasLegHair"] = "RasBodyMod.FemaleLeg"
               else
                   rasClientData.SelectedBodyHair["Female"]["RasLegHair"] = "None"
               end
         else -- for male
              -- assign pubic hair
               local n = ZombRand(101)
               if n <= 85 then        
                  rasClientData.SelectedBodyHair["Male"]["RasPubicHair"] = "RasBodyMod.MalePubicNatural"
               else
                  rasClientData.SelectedBodyHair["Male"]["RasPubicHair"] = "RasBodyMod.MalePubicStrip"
               end 
               -- armpit
               n = ZombRand(101)
               if n <= 5 then
                   rasClientData.SelectedBodyHair["Male"]["RasArmpitHair"] = "None"
               else
                   rasClientData.SelectedBodyHair["Male"]["RasArmpitHair"] = "RasBodyMod.MaleArmpit"
               end
               -- legs
               n = ZombRand(101)
               if n <= 5 then
                   rasClientData.SelectedBodyHair["Male"]["RasLegHair"] = "None"
               else
                   rasClientData.SelectedBodyHair["Male"]["RasLegHair"] = "RasBodyMod.MaleLeg"
               end
               -- chest
               n = ZombRand(101)
               if n <= 90 then
                   rasClientData.SelectedBodyHair["Male"]["RasChestHair"] = "RasBodyMod.MaleChest"
               else
                   rasClientData.SelectedBodyHair["Male"]["RasChestHair"] = "None"
                   n = ZombRand(101)
                   if n <= 80 then
                        rasClientData.SelectedBodyHair["Male"]["RasPubicHair"] = "RasBodyMod.MalePubicNatural"
                   elseif n<= 95 then
                        rasClientData.SelectedBodyHair["Male"]["RasPubicHair"] = "RasBodyMod.MalePubicStrip"
                   else
                        rasClientData.SelectedBodyHair["Male"]["RasPubicHair"] = "None" -- only give style "none" when no chest hair is present (looks a bit weird otherwise XD )
                   end
               end   

               rasClientData.BeardStubble = 0 -- no beard stubble by default (as in vanilla)                  
         end

         rasClientData.HeadStubble = 0  -- no head stubble by default (as in vanilla)
end



-- equip body hair items according to the rasClientData.SelectedBodyHair
local function equipAccordingToSelectedBodyHair(desc, skinColor)
      
        if desc:isFemale() then
           for location,_ in pairs(rasSharedData.BodyHairLocations) do
                 if location ~= "RasChestHair" then -- no chest hair for women
                     equipBodyHair(desc, location, skinColor)
                 end
           end
        else
           for location,_ in pairs(rasSharedData.BodyHairLocations) do
                  equipBodyHair(desc, location, skinColor)
           end
        end               
end 






--------------------------------------------- SECOND PART: new functions managing the new UI elements (new combo boxes etc.) -----------------------------------------------


-- this function moves the position of the clothing combo boxes a bit to the right; this is to ensure that there is enough space for the body hair ui
local function adjustClothingCombos(self)
     -- change x-position of clothing combo boxes
     if self.clothingPanel then
             local adjustX = 50 -- value to adjust layout according to player's screen resolution
             if self.width <= 1280 then -- adjust values for smaller screen resolutions (note: <1280 doesn't work anymore)
                     adjustX = -50
             elseif self.width < 1920 then
                     adjustX = -50 + ( 100 * ((self.width - 1280) / (1920 -1280)) )
             end
             local allClothingStuff = self.clothingPanel:getChildren()
             local i = 1
	         for _,child in pairs(allClothingStuff) do
	               local x = child:getX()
	               if  i > 4 then -- skip first 4 items since they belong to the headline (they are treated in createClothingBtn); skip last since this is the scroll bar
	                    child:setX(x + adjustX)  -- old: x+50
	               end
	               i = i+1
	        end 
            -- also add scroll bars (vanilla scroll bars have to be removed cause they mess things up)
            self.clothingPanel:setScrollChildren(true)
            self.clothingPanel:setScrollHeight(self.yOffset)
            self.clothingPanel:addScrollBars()
            self.scrollBarSet = true
    end
end



-- this is the vanilla doClothingCombo but allows multiple clothing items with same display name in a combo box (only used when all-clothing-unlocked enabled)
local function doClothingComboAllUnlocked(self, definition, erasePrevious)
	if not self.clothingPanel then return; end
	
	-- reinit all combos
	if erasePrevious then
		if self.clothingCombo then
			for i,v in pairs(self.clothingCombo) do
				self.clothingPanel:removeChild(self.clothingColorBtn[v.bodyLocation]);
				self.clothingPanel:removeChild(self.clothingTextureCombo[v.bodyLocation]);
				self.clothingPanel:removeChild(self.clothingComboLabel[v.bodyLocation]);
				self.clothingPanel:removeChild(v);
			end
		end
		self.clothingCombo = {};
		self.clothingColorBtn = {};
		self.clothingTextureCombo = {};
		self.clothingComboLabel = {};
		self.yOffset = self.originalYOffset;
	end
	
	-- create new combo or populate existing one (for when having specific profession clothing)
	local desc = MainScreen.instance.desc;
	for bodyLocation, profTable in pairs(definition) do
		local combo = nil;
		if self.clothingCombo then
			combo = self.clothingCombo[bodyLocation]
		end
		if not combo then
			self:createClothingCombo(bodyLocation);
			combo = self.clothingCombo[bodyLocation];
			combo:addOptionWithData(getText("UI_characreation_clothing_none"), nil)
		end
		if erasePrevious then
			combo.options = {}
			combo:addOptionWithData(getText("UI_characreation_clothing_none"), nil)
		end
		
		for j,clothing in ipairs(profTable.items) do
			local item = ScriptManager.instance:FindItem(clothing)
			local displayName = item:getDisplayName()
            if not rasSharedData.GlitchedItemsReverse[clothing] then -- do not show items used for fixing the vest glitch
		       combo:addOptionWithData(displayName, clothing)
            end
		end
	end
	
	self:updateSelectedClothingCombo();
		
	self.colorPicker = ISColorPicker:new(0, 0, {h=1,s=0.6,b=0.9});
	self.colorPicker:initialise()
	self.colorPicker.keepOnScreen = true
	self.colorPicker.pickedTarget = self
	self.colorPicker.resetFocusTo = self.clothingPanel
end



-- this functions generates the list of all clothing items in case all-clothing-unlocked is enabled (I use a custom function since I wasn't able to patch vanilla code properly)
local function generateAllClothingCombos(self)
         
         -- write all clothing items to allClothingTable
         local allClothingTable = { }
         local group = BodyLocations.getGroup("Human")
	     local allLoc = group:getAllLocations();

	     for i=0, allLoc:size()-1 do
	     	local bodyLocation = allLoc:get(i):getId()           
            if isClothingLocation(bodyLocation) then -- do not show locations for body hair/skin/penis/beard stubble/head stubble
                local clothingList = getAllItemsForBodyLocation(bodyLocation)

                table.sort(clothingList, function(a,b) 
				                             local itemA = ScriptManager.instance:FindItem(a)
				                             local itemB = ScriptManager.instance:FindItem(b)
				                             return not string.sort(itemA:getDisplayName(), itemB:getDisplayName())
			                             end
                )

                allClothingTable[bodyLocation] = { items = clothingList }
            end
	     end

         doClothingComboAllUnlocked(self, allClothingTable, true) -- generate all the combo boxes         
end



-- add header for the body hair section
local function createBodyHairTypeBtn(self)
	local comboHgt = FONT_HGT_SMALL + 3 * 2
		
	local x = 600 
    if self.width <= 1280 then -- adjust values for smaller screen resolutions 
         x = 500
    elseif self.width < 1920 then
         x = 500 + ( 100 * ((self.width - 1280) / (1920 -1280)) )
    end
	local y = self.clothingLbl.y 
	
	local lbl = ISLabel:new(x, y, FONT_HGT_MEDIUM, getText("UI_rasBodyMod_BodyHair"), 1, 1, 1, 1, UIFont.Medium, true)
	lbl:initialise();                                                                                                                            
	lbl:instantiate();
	self.characterPanel:addChild(lbl);
	
	local rect = ISRect:new(x, y + FONT_HGT_MEDIUM + 5, 300, 1, 1, 0.3, 0.3, 0.3);
	rect:setAnchorRight(false);
	rect:initialise();
	rect:instantiate();
	self.characterPanel:addChild(rect);
	
	yCoordinate = y + FONT_HGT_MEDIUM + 15;
end



-- update the body hair combo boxes when something has changed
local function updateSelectedBodyHairCombo(self)
	local desc = MainScreen.instance.desc;
    local gender = "Male"
    if desc:isFemale() then
        gender = "Female"
    end
	if self.bodyHairCombo then
		for i,combo in pairs(self.bodyHairCombo) do
			combo.selected = 1;
			local currentItem = desc:getWornItem(combo.bodyLocation);
			if currentItem then
                local displayName = rasClientData.SelectedBodyHair[gender][combo.bodyLocation]
                if rasSharedData.CorrectName[displayName] then
                    displayName = rasSharedData.CorrectName[displayName]
                end
				for j,v in ipairs(combo.options) do
					if v.text == displayName then
						combo.selected = j;
						break
					end
				end
			end
		end
	end
end




-- when body hair is selected, do this:
local function onBodyHairComboSelected(self, combo, bodyLocation)
	local desc = MainScreen.instance.desc
	local gender = "Male"
	if desc:isFemale() then
	    gender = "Female"
	end
		
	-- we set bodyHair for the location to none by default
	rasClientData.SelectedBodyHair[gender][bodyLocation] = "None"
	
	local itemType = combo:getOptionData(combo.selected)
	if itemType then
		local item = InventoryItemFactory.CreateItem(itemType)
		if item then
		     rasClientData.SelectedBodyHair[gender][bodyLocation] = item:getFullType()          
	         --desc:setWornItem(bodyLocation, item)			
		end  
	end
	
    equipBodyHair(desc, bodyLocation, self.skinColor) -- equip selected body hair
	manageMalePrivatePart(desc, self.skinColor) -- equip correct penis model
    updateSelectedBodyHairCombo(self)
	CharacterCreationMain.disableBtn(self)
end





-- creates a single combo box for body hair location; almost a copy from vanilla createClothingCombo except that we add body hair ui elements to the character panel
local function createBodyHairCombo(self, label, bodyLocation)
	local comboHgt = FONT_HGT_SMALL + 3 * 2
	local x = 600 
    if self.width <= 1280 then -- adjust values for smaller screen resolutions
         x = 500
    elseif self.width < 1920 then
         x = 500 + ( 100 * ((self.width - 1280) / (1920 -1280)) )
    end		

	if not self.characterPanel then return; end
		
	local label = ISLabel:new(x + 70, self.yOffset, comboHgt, label, 1, 1, 1, 1, UIFont.Small) 
	label:initialise()
    self.characterPanel:addChild(label)

	local combo = ISComboBox:new(x + 90, self.yOffset, self.comboWid, comboHgt, self, onBodyHairComboSelected, bodyLocation)
	combo:initialise()
	combo.bodyLocation = bodyLocation;
	self.characterPanel:addChild(combo)
		
  	
	self.bodyHairCombo = self.bodyHairCombo or {}
	self.bodyHairComboLabel = self.bodyHairComboLabel or {}
	
	self.bodyHairCombo[bodyLocation] = combo
	self.bodyHairComboLabel[bodyLocation] = label;
	
	
	self.yOffset = self.yOffset + comboHgt + 4
	
	return
end






-- generates the list of body hair combo boxes; similar to vanilla doClothingCombos
local function doBodyHairCombo(self, definition)

    if not self.characterPanel then return; end
        
    -- reinit all body hair options
    if self.bodyHairCombo then
          
            -- remove body hair combo boxes
			for i,v in pairs(self.bodyHairCombo) do
			     if rasSharedData.BodyHairLocations[v.bodyLocation] then				
				   self.characterPanel:removeChild(self.bodyHairComboLabel[v.bodyLocation]);
				   self.characterPanel:removeChild(v);
	             end				
			end          
	end
    self.bodyHairCombo = {};
    self.bodyHairComboLabel = {};
	
	local xTMP = self.xOffset   -- remember positions
	local yTMP = self.yOffset
	 
	self.yOffset = yCoordinate -- positions to display ui elements for body hair
	
	-- generate the list of ui elements (aka combo boxes) for body hair and put them to the body hair section in the character panel 
	-- almost a copy from the vanilla code which does the same for clothing ui elements	
	for bodyLocation, profTable in pairs(definition) do          
	    if rasSharedData.BodyHairLocations[bodyLocation] then  
		        local combo = nil;
		        if self.bodyHairCombo then
			        combo = self.bodyHairCombo[bodyLocation]
		        end
		        if not combo then
			        createBodyHairCombo(self, getText("UI_ClothingType_" .. bodyLocation), bodyLocation);
			        combo = self.bodyHairCombo[bodyLocation];
			        combo:addOptionWithData(getText("UI_characreation_clothing_none"), nil)
		        end
		        combo.options = {}
		        combo:addOptionWithData(getText("UI_characreation_clothing_none"), nil)
		        
		        for j,clothing in ipairs(profTable.items) do -- populate combo with options coming from the dummy body hair items
			        local item = ScriptManager.instance:FindItem(clothing)
                    local displayName = item:getDisplayName()
                    if rasSharedData.CorrectName[displayName] then
                        displayName = rasSharedData.CorrectName[displayName]
                    end
			        if not combo:contains(displayName) then
				        combo:addOptionWithData(displayName, clothing)
			        end
		        end
         end        
	end
     
    self.xOffset = xTMP   -- retrieve old positions (just in case...)
    self.yOffset = yTMP
       
    updateSelectedBodyHairCombo(self) 
end



-- when "Remove All" button in the clothing section is clicked, remove all clothes the player wears:
local function onRemoveAllClothingClicked(self)
        local desc = MainScreen.instance.desc       
        local group = BodyLocations.getGroup("Human")
        local allLocations = group:getAllLocations()       
        

        -- do not remove glasses; we have to back up them because vanilla apparently deletes them when setting a location other than "Eyes" to nil (why???)
        --[[local glasses = desc:getWornItem("Eyes") 
        local wearsGlasses = false               
        if glasses then 
              local glassesType = glasses:getFullType()
              if glassesType == "RasBodyMod.Glasses_Normal" or glassesType == "RasBodyMod.Glasses_Reading" then
                   wearsGlasses = true
              end
        end]]--
        

        for i=1,allLocations:size() do -- iterate through all body locations and remove clothing
               local bodyLocation = allLocations:get(i-1):getId()
               if isClothingLocation(bodyLocation) then  -- undress everything except for body hair/skin/penis                         
                        desc:setWornItem(bodyLocation, nil)
               end	      
        end


        --[[if wearsGlasses then -- put glasses back on
               desc:setWornItem("Eyes", glasses)
        end]]--

        CharacterCreationMain.updateSelectedClothingCombo(self)
        CharacterCreationMain.disableBtn(self)
	    CharacterCreationHeader.instance.avatarPanel:setSurvivorDesc(desc)	
end







---------------------------------- THIRD PART: modified vanilla functions -----------------------------------------------------------


local vanilla_create = CharacterCreationMain.create
function CharacterCreationMain:create(...)  
         
        vanilla_create(self,...) -- execute vanilla code
	
	    createBodyHairTypeBtn(self) -- create header for the body hair section
end



-- the following function needs to be manipulated to ensure that we bypass the all-clothing-unlocked mode 
local vanilla_setVisible = CharacterCreationMain.setVisible
function CharacterCreationMain:setVisible(bVisible, joypadData, ...) 
         RasAllClothingUnlocked = getSandboxOptions():getAllClothesUnlocked()      
         getSandboxOptions():set("AllClothesUnlocked", false) -- make sure the vanilla all-clothing-unlocked option has no effect (we use our own all-clothing-unlocked code) 
         local tmp = CharacterCreationMain.debug
         CharacterCreationMain.debug = false   
     
         vanilla_setVisible(self, bVisible, joypadData, ...) -- execute vanilla code

         getSandboxOptions():set("AllClothesUnlocked", RasAllClothingUnlocked)
         CharacterCreationMain.debug = tmp
         RasAllClothingUnlocked = false
end




-- we rearrange some clothing-ui-elements and introduce the Remove-All-button
local vanilla_createClothingBtn = CharacterCreationMain.createClothingBtn
function CharacterCreationMain:createClothingBtn(...)

	 local y = self.yOffset -- remember position
	 startYCoordinate = self.yOffset

     local tmp = CharacterCreationMain.debug
     CharacterCreationMain.debug = false -- bypass the all-clothing-unlocked mode

	 vanilla_createClothingBtn(self, ...) -- execute vanilla code

	 CharacterCreationMain.debug = tmp

	 -- we move some ui elements to the right to get space for the body hair section
	 self.clothingPanel:clearChildren()
         
     -- define two variables to adjust ui elements depending on palyer's screen resolution
     local adjustX = 70   -- default values for resolution 1920x1080 and larger
     local myLength = 450
         
     if self.width <= 1280 then -- default values for resolutions smaller than 1280x?; if width is strictly smaller than 1280, the mod is probably not usable anymore...
               adjustX = 0
               myLength = 380
     elseif self.width < 1920 then -- if resolution width is between 1280 and 1920, adjust values
               adjustX = 70 * ((self.width - 1280) / (1920 -1280))
               myLength = 380 + ( 70 * ( (self.width - 1280) / (1920 -1280)) )
     end
	 
	 local x=0
	 self.clothingLbl = ISLabel:new(x + adjustX, y, FONT_HGT_MEDIUM, getText("UI_characreation_clothing"), 1, 1, 1, 1, UIFont.Medium, true)
	 self.clothingLbl:initialise();
	 self.clothingPanel:addChild(self.clothingLbl);
	
	 local rect = ISRect:new(x + adjustX, y + FONT_HGT_MEDIUM + 5, myLength, 1, 1, 0.3, 0.3, 0.3); -- old: x=x+70, 380=450
	 --rect:setAnchorRight(true);
	 rect:initialise();
	 rect:instantiate();
	 self.clothingPanel:addChild(rect);
	
     -- introduce Remove-All-button	
	 local fontHgt = getTextManager():getFontHeight(self.skinColorLbl.font) 
	 local textWidth = getTextManager():MeasureStringX(UIFont.Medium, getText("UI_rasBodyMod_RemoveAll"))
     local button = ISButton:new(x + adjustX + myLength + 7 - textWidth, y + (fontHgt - 15) / 2, 25, 25, getText("UI_rasBodyMod_RemoveAll"), self)
	 button:setOnClick(onRemoveAllClothingClicked, self)
	 button:initialise()
	 self.clothingPanel:addChild(button)
	     
	 -- dummy label to make some space between ui elements and frame
	 self.dummyLbl = ISLabel:new(x + adjustX + myLength, y, FONT_HGT_MEDIUM, "  ", 1, 1, 1, 1, UIFont.Small, true)
	 self.dummyLbl:initialise();
	 self.clothingPanel:addChild(self.dummyLbl);
	  
	 self.yOffset = y + FONT_HGT_MEDIUM + 15
	 self.originalYOffset = self.yOffset	 

end
        


-- when clothing is initialized, create combo boxes for body hair and align current body hair/penis/skin with current skin color
vanilla_initClothing = CharacterCreationMain.initClothing
function CharacterCreationMain:initClothing(...)    
      
     local desc = MainScreen.instance.desc
    
     local tmp = getSandboxOptions():getAllClothesUnlocked() -- in case all-clothing-unlocked enabled, I create the list of all clothing here since   
     getSandboxOptions():set("AllClothesUnlocked", false)    
          
     if not tmp and not RasAllClothingUnlocked then -- if we play without all-clothing unlocked
                                   
             if self.scrollBarSet then -- remove scroll bar and predefined outfits in case all-clothing-unlocked was set previously
                  local allClothingStuff = self.clothingPanel:getChildren()            
                  local lastChild = nil
                  local i = 1
	              for _,child in pairs(allClothingStuff) do -- need to iterate since I didn't find a way to get last element/scroll bars directly	          
                       lastChild = child
                       if self.RasAllClothingListCreated and i > 4 then -- remove predefined outfits; their position is i=5,6,7
                           self.clothingPanel:removeChild(child)
                           if i == 7 then
                               self.RasAllClothingListCreated = false
                           end
                       end
                       i = i+1
	              end 
                  self.clothingPanel:removeChild(lastChild) -- last child = scroll bar
             end                       

             vanilla_initClothing(self, ...) -- execute vanilla code 

             adjustClothingCombos(self) -- move clothing combo boxes to the right

     elseif self.originalYOffset then -- in case all-clothing-unlocked is enabled, generate the list of all clothing items; must check whether self.originalYOffset not nil (otherwise bug)
         if not self.RasAllClothingListCreated then        
               if self.scrollBarSet then -- remove scroll bar; otherwise will mess up the interface
                    local allClothingStuff = self.clothingPanel:getChildren()
                    local lastChild = nil
	                for _,child in pairs(allClothingStuff) do	          
                         lastChild = child
	                end
                    self.clothingPanel:removeChild(lastChild)
               end         
               
               -- create options for predefined outfits
               local comboHgt = FONT_HGT_SMALL + 3 * 2
	           local x = 0;

               local old_yOffset = self.yOffset
               self.yOffset = self.originalYOffset

	           self.outfitLbl = ISLabel:new(x + 70 + 70, self.yOffset, comboHgt, "Outfit", 1, 1, 1, 1, UIFont.Small)
	           self.outfitLbl:initialise()
	           self.clothingPanel:addChild(self.outfitLbl)

	           self.outfitCombo = ISComboBox:new(x + 90 + 70, self.yOffset, self.comboWid, comboHgt, self, CharacterCreationMain.onOutfitSelected);
	           self.outfitCombo:initialise()
	           self.clothingPanel:addChild(self.outfitCombo)

	           local fontHgt = getTextManager():getFontHeight(self.skinColorLbl.font)
	           local button = ISButton:new(self.outfitCombo:getRight() + 20, self.yOffset, 15, comboHgt, "Randomize", self)
	           button:setOnClick(CharacterCreationMain.onRandomizeOutfitClicked)
	           button:initialise()
	           self.clothingPanel:addChild(button)

               self.clothingWidgets = {}
	           table.insert(self.clothingWidgets, { self.outfitCombo, button })             

               -- populate outfit box with data
               self.outfitCombo.options = {}
			   self.outfitCombo:addOptionWithData(getText("UI_characreation_clothing_none"), nil)
			   local outfits = getAllOutfits(desc:isFemale())
			   for i=1,outfits:size() do
				  self.outfitCombo:addOptionWithData(outfits:get(i-1), outfits:get(i-1))
			   end

               local old_originalYOffset = self.originalYOffset
               self.originalYOffset = self.yOffset + comboHgt + 4;

               -- make list of all clothing items
               generateAllClothingCombos(self)
               adjustClothingCombos(self) -- move clothing combo boxes to the right 
               self.RasAllClothingListCreated = true -- when all-clothing-unlocked, we need to create the list only once since no difference for different genders/professions (better performance)              

               self.originalYOffset = old_originalYOffset -- retrieve old Positions
               self.yOffset = old_yOffset
                             
         else
               self:updateSelectedClothingCombo()
         end
     end

     getSandboxOptions():set("AllClothesUnlocked", tmp)        
     
	-- create combo boxes for body hair (also includes the color options for body hair)
	local hairTable = rasSharedData.BodyHairDefinitions
	if desc:isFemale() then
		  doBodyHairCombo(self, hairTable.Female);
	else
		  doBodyHairCombo(self, hairTable.Male);
	end				
	
    -- assign random body hair to rasClientData.SelectedBodyHair
	assignRandomBodyHair(desc)
		
	if not self.skinColor then          
	   self.skinColor = 1 + ZombRand(5)
	end	
	
	-- equip skin, body hair and penis and align with skin/hair color
	if self.skinColor then 
         rasClientData.SkinColorIndex = self.skinColor -- store skin color
         equipSkin(desc, self.skinColor) -- equip skin
         equipAccordingToSelectedBodyHair(desc, self.skinColor) -- equip body hair
	     manageMalePrivatePart(desc, self.skinColor) -- equip penis	     
	     updateSelectedBodyHairCombo(self)
         vestGlitchFix(desc)
    end	       
end


-- modify doClothingCombo by removing scroll bars
local vanilla_doClothingCombo = CharacterCreationMain.doClothingCombo
function CharacterCreationMain:doClothingCombo(definition, erasePrevious, ...)      
  
         vanilla_doClothingCombo(self, definition, erasePrevious, ...) -- execute vanilla code

         if self.clothingPanel then
                  local allClothingStuff = self.clothingPanel:getChildren()
                  local lastChild = nil
	              for _,child in pairs(allClothingStuff) do	          
                       lastChild = child
	              end
                  self.clothingPanel:removeChild(lastChild) -- remove scroll bar
         end 
end



-- we disable the tick box for vanilla chest hair since this mod introduces it's own chest hair
local vanilla_disableBtn = CharacterCreationMain.disableBtn
function CharacterCreationMain:disableBtn(...)

    vanilla_disableBtn(self, ...) -- execute vanilla code

	if self.chestHairLbl then
	   self.chestHairLbl:setVisible(false)     
	   self.chestHairTickBox:setVisible(false)
	end
end


-- apply/unapply beard stubble if player has choosen to do so
local vanilla_onBeardStubbleSelected = CharacterCreationMain.onBeardStubbleSelected
function CharacterCreationMain:onBeardStubbleSelected(index, selected, ...)

    local desc = MainScreen.instance.desc
    if not desc:isFemale() then

        local improvedHairMenuActive = false  
        local modInfo = getModInfoByID("improvedhairmenu")  
        if modInfo and isModActive(modInfo) then            
             improvedHairMenuActive = true
        end

	    if selected then
            local beard = desc:getHumanVisual():getBeardModel()
            if (not rasSharedData.FullBeards[beard]) or improvedHairMenuActive then -- only show stubble when not having a full beard (or Improved Hair Menu mod is active)
                 local stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleBeard_Light")
                 if rasClientData.SkinColorIndex == 4 or rasClientData.SkinColorIndex == 5 then
                    stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleBeard_Dark")
                 end
		         desc:setWornItem("RasBeardStubble", stubble)
            end
            rasClientData.BeardStubble = 1
	    else
		    desc:setWornItem("RasBeardStubble", nil) 
            rasClientData.BeardStubble = 0
	    end
    end

    vanilla_onBeardStubbleSelected(self, index, selected, ...) -- execute vanilla code  
end


-- when full beard, we hide beard stubble for better visuals
local vanilla_onBeardTypeSelected = CharacterCreationMain.onBeardTypeSelected
function CharacterCreationMain:onBeardTypeSelected(combo, ...)

    local improvedHairMenuActive = false      
    local modInfo = getModInfoByID("improvedhairmenu")  
    if modInfo and isModActive(modInfo) then            
             improvedHairMenuActive = true
    end

    if (not improvedHairMenuActive) then  -- simplify things when Improved Hair Menu mod is active
        local desc = MainScreen.instance.desc
	    local beard = combo:getOptionData(combo.selected)
        if rasSharedData.FullBeards[beard] then
             if rasClientData.BeardStubble == 1 then
                desc:setWornItem("RasBeardStubble", nil) -- hide stubble when having a full beard
             end 
        elseif rasClientData.BeardStubble == 1 and desc:getWornItem("RasBeardStubble") == nil then
             local stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleBeard_Light")
             if rasClientData.SkinColorIndex == 4 or rasClientData.SkinColorIndex == 5 then
                    stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleBeard_Dark")
             end
		     desc:setWornItem("RasBeardStubble", stubble) -- show stubble when no full beard
        end
    end

    vanilla_onBeardTypeSelected(self, combo, ...) -- execute vanilla code
end


-- apply/unapply stubble to head
vanilla_onShavedHairSelected = CharacterCreationMain.onShavedHairSelected
function CharacterCreationMain:onShavedHairSelected(index, selected, ...)

    local desc = MainScreen.instance.desc
    if selected then
         rasClientData.HeadStubble = 1
         if desc:isFemale() then
              local stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleHead_Light_F")
              if rasClientData.SkinColorIndex == 4 or rasClientData.SkinColorIndex == 5 then
                    stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleHead_Dark_F")
              end
		      desc:setWornItem("RasHeadStubble", stubble)
         else
              local stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleHead_Light_M")
              if rasClientData.SkinColorIndex == 4 or rasClientData.SkinColorIndex == 5 then
                    stubble = InventoryItemFactory.CreateItem("RasBodyMod.StubbleHead_Dark_M")
              end
		      desc:setWornItem("RasHeadStubble", stubble)
         end
    else
         rasClientData.HeadStubble = 0
         desc:setWornItem("RasHeadStubble", nil)
    end

    vanilla_onShavedHairSelected(self, index, selected, ...) -- execute vanilla code
end



-- if clothing is updated, we must check whether exceptional clothing is worn and (un-)equip the penis accordingly
local vanilla_updateSelectedClothingCombo = CharacterCreationMain.updateSelectedClothingCombo
function CharacterCreationMain:updateSelectedClothingCombo(...)
        
        vanilla_updateSelectedClothingCombo(self, ...) --execute vanilla code
        	
        manageMalePrivatePart(MainScreen.instance.desc, self.skinColor) -- (un-)equip penis depending on worn clothes
        local desc = MainScreen.instance.desc
        vestGlitchFix(desc)
end


-- if we change the skin color, we have to align skins/penis/body hair with skin color
local vanilla_onSkinColorPicked = CharacterCreationMain.onSkinColorPicked
function CharacterCreationMain:onSkinColorPicked(color, mouseUp, ...)
    
    vanilla_onSkinColorPicked(self, color, mouseUp, ...) -- execute vanilla code

    local desc = MainScreen.instance.desc    

    rasClientData.SkinColorIndex = self.colorPickerSkin.index  -- store the skin color index for later
    self.skinColor = self.colorPickerSkin.index
    equipSkin(desc, self.colorPickerSkin.index) -- equip correct skin

    equipAccordingToSelectedBodyHair(desc, self.skinColor) -- align body hair
	manageMalePrivatePart(desc, self.skinColor) -- align penis with choosen skin color 
    
    if rasClientData.BeardStubble == 1 then
         self:onBeardStubbleSelected(nil, true) -- align beard stubble with skin color
    end
    if rasClientData.HeadStubble == 1 then
         self:onShavedHairSelected(nil, true) -- align head stubble with skin color
    end
end





-- this fixes a bug in the vanilla game (strictly speaking not necessary for the mod)
local vanilla_headerRender = CharacterCreationHeader.render
function CharacterCreationHeader:render(...)
         vanilla_headerRender(self, ...) -- execute vanilla code
         
         CharacterCreationHeader.instance.avatarPanel:setSurvivorDesc(MainScreen.instance.desc)
end





-- we need to modify this so that the player doesn't undress the nude textures when interacting with the predefined outfits
local vanilla_onOutfitSelected = CharacterCreationMain.onOutfitSelected
function CharacterCreationMain:onOutfitSelected(combo, ...)

      vanilla_onOutfitSelected(self, combo, ...) -- execute vanilla code
      
      local desc = MainScreen.instance.desc
      equipAccordingToSelectedBodyHair(desc, self.skinColor)
      equipSkin(desc, self.skinColor) 
      manageMalePrivatePart(desc, self.skinColor) 
      updateSelectedBodyHairCombo(self)
end


--[[local vanilla_syncUIWithTorso = CharacterCreationMain.syncUIWithTorso
function CharacterCreationMain:syncUIWithTorso(...)
	
    vanilla_syncUIWithTorso(self, ...) -- execute vanilla code

    self.skinColor = rasClientData.SkinColorIndex -- TEST!!!!!!!!!!!!!
end


-- when random button is clicked, randomize the skin
local vanilla_header_onOptionMouseDown = CharacterCreationHeader.onOptionMouseDown
function CharacterCreationHeader:onOptionMouseDown(button, x, y, ...)
	
	if button.internal == "RANDOM" then
          rasClientData.SkinColorIndex = ZombRand(5) + 1 -- TEST!!!!!
    end

    vanilla_header_onOptionMouseDown(self, button, x, y, ...)

end]]--


-- we also allow the player to save their character builds with body hair; next two function realize this
local vanilla_saveBuildStep2 = CharacterCreationMain.saveBuildStep2
function CharacterCreationMain:saveBuildStep2(button, joypadData, param2, ...)       
         
         vanilla_saveBuildStep2(self,button, joypadData, param2, ...) -- execute vanilla code
                  
         if button.internal == "CANCEL" then
		    return
	     end
	 
         local savename = button.parent.entry:getText()
         if savename == '' then 
            return 
         end
          
         local desc = MainScreen.instance.desc;        
         local builds = CharacterCreationMain.readSavedOutfitFile();
         local savestring = builds[savename]
         
         -- store selected body hair
         for i,v in pairs(self.bodyHairCombo) do
		         if v:getOptionData(v.selected) ~= nil then
			        savestring = savestring ..  i .. "=" .. v:getOptionData(v.selected);
			        if self.clothingColorBtn[i] and self.clothingColorBtn[i]:isVisible() then
				        savestring = savestring .. "|" .. self.clothingColorBtn[i].backgroundColor.r .. "," .. self.clothingColorBtn[i].backgroundColor.g  .. "," 
				        .. self.clothingColorBtn[i].backgroundColor.b;
			        end
			        if self.clothingTextureCombo[i] and self.clothingTextureCombo[i]:isVisible() then
				        savestring = savestring .. "|" .. self.clothingTextureCombo[i].selected;
			        end
			        savestring = savestring .. ";";
		         end
	    end

        -- store head and beard stubble
        if rasClientData.HeadStubble == 1 then
            savestring = savestring .. "RasHeadStubble=yes;"
        else 
            savestring = savestring .. "RasHeadStubble=no;"
        end
        if not desc:isFemale() then
             if rasClientData.BeardStubble == 1 then
                  savestring = savestring .. "RasBeardStubble=yes;"
             else
                  savestring = savestring .. "RasBeardStubble=no;"
             end
        end         


        builds[savename] = savestring
             
        local options = {};
	    CharacterCreationMain.writeSaveFile(builds);
	    for key,val in pairs(builds) do
		    options[key] = 1;
	    end
	    
	    self.savedBuilds.options = {};
	    local i = 1;
	    for key,val in pairs(options) do
		    table.insert(self.savedBuilds.options, key);
		    if key == savename then
			    self.savedBuilds.selected = i;
		    end
		    i = i + 1;
	    end         
end


local vanilla_loadOutfit = CharacterCreationMain.loadOutfit
function CharacterCreationMain:loadOutfit(box,...)

       vanilla_loadOutfit(self,box,...) -- execute vanilla code
       
       CharacterCreationMain.updateSelectedClothingCombo(self)
                          
       local name = box.options[box.selected];
       if name == nil then return end;      
	
       local saved_builds = CharacterCreationMain.readSavedOutfitFile();
       local build = saved_builds[name];
       if build == nil then return end;
       
       local items = luautils.split(build, ";");
              
       -- set all body hair to "none"
       local desc = MainScreen.instance.desc;
       if desc:isFemale() then
           rasClientData.SelectedBodyHair.Female.RasArmpitHair = "None"
           rasClientData.SelectedBodyHair.Female.RasPubicHair = "None"
           rasClientData.SelectedBodyHair.Female.RasLegHair = "None"
           rasClientData.HeadStubble = 0
       else
           rasClientData.SelectedBodyHair.Male.RasChestHair = "None"
           rasClientData.SelectedBodyHair.Male.RasArmpitHair = "None"
           rasClientData.SelectedBodyHair.Male.RasPubicHair =  "None"
           rasClientData.SelectedBodyHair.Male.RasLegHair = "None"
           rasClientData.BeardStubble = 0
           rasClientData.HeadStubble = 0
       end
       
       updateSelectedBodyHairCombo(self)
       equipSkin(desc, self.skinColor)
       equipAccordingToSelectedBodyHair(desc, self.skinColor)
       rasClientData.SkinColorIndex = self.skinColor
       
       for i,v in pairs(items) do -- load body hair and beard/head stubble
               local location = luautils.split(v, "=");
	           local options = nil
	           if location[2] then
			      options = luautils.split(location[2], "|")
               end
               
               if self.bodyHairCombo[location[1]]  then
			         local bodyLocation = location[1];
	                 local itemType = options[1];
	                 self.bodyHairCombo[bodyLocation].selected = 1;
	                 self.bodyHairCombo[bodyLocation]:selectData(itemType);
	                 onBodyHairComboSelected(self, self.bodyHairCombo[bodyLocation], bodyLocation);
	                 if options[2] then
		                 local comboTexture = self.clothingTextureCombo[bodyLocation]
		                 local color = luautils.split(options[2], ",");
		                 -- is it a color or a texture choice
		                 if (#color == 3) and self.clothingColorBtn[bodyLocation] then -- it's a color
			                  local colorRGB = {};
			                  colorRGB.r = tonumber(color[1]);
			                  colorRGB.g = tonumber(color[2]);
			                  colorRGB.b = tonumber(color[3]);
			                  self:onClothingColorPicked(colorRGB, true, bodyLocation);
		                 elseif comboTexture and comboTexture.options[tonumber(color[1])] then -- texture
			                  comboTexture.selected = tonumber(color[1]);
			                  self:onClothingTextureComboSelected(comboTexture, bodyLocation);
		                 end
	                end
              elseif location[1] == "RasHeadStubble" then -- load head stubble
                   if location[2] == "yes" then
                      self.hairStubbleTickBox.selected[1] = true
                      self:onShavedHairSelected(nil, true)
                   else
                      self.hairStubbleTickBox.selected[1] = false
                      self:onShavedHairSelected(nil, false)
                   end 
		      elseif location[1] == "RasBeardStubble" then -- load beard stubble
                   if location[2] == "yes" then
                      self.beardStubbleTickBox.selected[1] = true
                      self:onBeardStubbleSelected(nil, true)
                   else
                      self.beardStubbleTickBox.selected[1] = false
                      self:onBeardStubbleSelected(nil, false)
                   end  
              end          
       end 
end




-- next two functions change colors in skin color selection menu (adjust them to skin colors introduced by the mod)
local CalledBy_createChestTypeBtn = false
local vanilla_createChestTypeBtn = CharacterCreationMain.createChestTypeBtn
function CharacterCreationMain:createChestTypeBtn(...)
	
     CalledBy_createChestTypeBtn = true
     vanilla_createChestTypeBtn(self, ...) -- execute vanilla code 

     local colors = {}
     for _,v in pairs(rasSharedData.SkinColors) do
           table.insert(colors, v)
     end
     self.skinColors = colors
end


local vanilla_ISColorPicker_setColors = ISColorPicker.setColors
function ISColorPicker:setColors(colors, columns, rows, ...)

    if CalledBy_createChestTypeBtn then
          colors = {}
          for _,v in pairs(rasSharedData.SkinColors) do
              table.insert(colors, v)
          end
          columns = #colors
          CalledBy_createChestTypeBtn = false
    end

    vanilla_ISColorPicker_setColors(self, colors, columns, rows, ...)
end


-------------------------------------------------------------------------

-- only used to generate a table of hair colors and print to console.txt; no functionality in game; TODO: delete later
--[[local myIndex = 1
local myColorTable = {}
local vanilla_onHairColorPicked = CharacterCreationMain.onHairColorPicked
function CharacterCreationMain:onHairColorPicked(color, mouseUp, ...)

     --local immutableColor = ImmutableColor.new(color.r, color.g, color.b, 1)
     local colorString = "" .. color.r .. "-" .. color.g .. "-" .. color.b
     
     print("TEST RGB : colorString)

     if not myColorTable[colorString] then
         myColorTable[colorString] = true
         myIndex = myIndex + 1
     end

     vanilla_onHairColorPicked(self, color, mouseUp, ...)
end]]--













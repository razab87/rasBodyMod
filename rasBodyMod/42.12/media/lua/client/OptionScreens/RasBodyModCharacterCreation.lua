-- this file contains the code which will make the "Character Customisation Screen" work; includes:
--
--       - choose different body hair styles; introduce appropriate combo boxes
--       - introduce "Remove All" button for clothing
--       - align skin and penis automatically with the skin color; there are also some adjustements applied to body hair depending on skin color (some skin colors get different hair items 
--         for better visuals)
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
local FONT_HGT_TITLE = getTextManager():getFontHeight(UIFont.Title)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6
local JOYPAD_TEX_SIZE = 32
     

-- custom variables:

local Y_OFFSET = 0 -- will store y positions for body hair combo boxes

local BH_RECT_LEN = 0 -- some size data for ui elements
local BH_LBL_LEN = 0
local CL_RECT_LEN = 0
local CL_LBL_LEN = 0
local CL_PANEL_HGHT = 0

-- will store some ui elements
local REMOVE_ALL -- remove all button
local BH_HEADER_LBL -- header label for body hair section
local BH_RECT -- rect for body hair section

local EXTRA_RECT_LEN = 20 -- various size data for ui elements
local EXTRA_RECT_LEN_DEFAULT = 20
local EXTRA_RECT_LEN_SMALL = 10
local EXTRA_RECT_LEN_SMALLEST = 5

local X_SPACE = 100 
local X_SPACE_DEFAULT = 100
local X_SPACE_SMALL = 30
local X_SPACE_SMALLEST = 10

local COMBO_WID = 250
local COMBO_WID_DEFAULT = 250
local COMBO_WID_SMALL = 200
local COMBO_WID_SMALLEST = 150

local SCROLL_WID = 17

local SCREEN_ADJUSTED = false
local DEBUG_SCREEN_ADJUSTED = false

local PROFESSION = nil










--------------------------------- FIRST PART: some util functions used in the code -------------------------------------------------




-- check whether bodyLocation is acutally a location for clothing (and not for skin/body hair/penis)
local function isClothingLocation(location)

       if rasSharedData.BodyHairLocations[location] or location == "RasMalePrivatePart" or location == "RasSkin" or location == "RasBeardStubble" or location == "RasHeadStubble" then
            return false
       end
      
       return true
end
 


-- check whether player's torso and groin area are nude so that we may apply the vestGlitchFix (see below)
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

      local locations = {"TorsoExtraVestBullet", "TorsoExtraVest"}
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
                              if myTable[bodyLocation][itemName] and myTable[bodyLocation][itemName]["hideWhileStanding"] then
                                       return true
                              end
                       end
               end
      end 

      return false
end



-- equip male character with penis texture and align with skin color
local function manageMalePrivatePart(self, desc, skinColor)      
     if not desc:isFemale() then
            if wearsExceptionalClothing(desc) then
                desc:setWornItem("RasMalePrivatePart", nil)
            elseif rasSharedData.PenisTable[skinColor] and rasSharedData.PenisTable[skinColor]["default"] then
                  local itemID = rasSharedData.PenisTable[skinColor]["default"]
                  local pubicHair = desc:getWornItem("RasPubicHair") 
                  if pubicHair ~= nil then
                       itemID = itemID .. "_Hair" -- choose penis texture with hair in case pubic hair is present
                  end
                  item = instanceItem(itemID)
                  desc:setWornItem("RasMalePrivatePart", item)
            end
            self.avatarPanel:setSurvivorDesc(desc)
      end
end





-- equip body hair
local function equipBodyHair(self, desc, bodyLocation, skinColor)

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

         local item = instanceItem(optimizedItem)
         if not item then -- if optimized version of item doesn't exist, take default version
             item = instanceItem(hairItem)
         end
         
         desc:setWornItem(bodyLocation, item)
     end               

     self.avatarPanel:setSurvivorDesc(desc)
end







-- equip correct skin
local function equipSkin(self, desc, skinColor) 
    local gender = "Male"
    if desc:isFemale() then
         gender = "Female"
    end
    desc:setWornItem("RasSkin", nil)
            
    if gender == "Male" then -- for males
          local skinID = rasSharedData.Skins.Male[skinColor]
          local skin = instanceItem(skinID) 
          desc:setWornItem("RasSkin", skin)
    else -- for females  
          local skinID = rasSharedData.Skins.Female[skinColor] 
          local skin = instanceItem(skinID)
          desc:setWornItem("RasSkin", skin)
    end
    
    self.avatarPanel:setSurvivorDesc(desc)
end






-- assign random body hair to characters; is called in initClothing when "random" button is pressed; 
-- we make it so that body hair styles fit to early 90s trends, i.e. not too much shaved
local function assignRandomBodyHair(desc)
         if desc:isFemale() then -- for female               
               -- armpit
               local n = ZombRand(101)
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
               -- assign pubic hair
               n = ZombRand(101)
               if n <= 55 then        
                    rasClientData.SelectedBodyHair["Female"]["RasPubicHair"] = "RasBodyMod.FemalePubicNatural"
               elseif n <= 85 then
                    rasClientData.SelectedBodyHair["Female"]["RasPubicHair"] = "RasBodyMod.FemalePubicTrimmed"
               elseif n <= 95 then
                   rasClientData.SelectedBodyHair["Female"]["RasPubicHair"] = "RasBodyMod.FemalePubicStrip"
               else
                    rasClientData.SelectedBodyHair["Female"]["RasPubicHair"] = "None" -- in this case, remove all body hair for more visual consistency
                    rasClientData.SelectedBodyHair["Female"]["RasLegHair"] = "None"
                    rasClientData.SelectedBodyHair["Female"]["RasArmpitHair"] = "None"
               end 
         else -- for male
               -- armpit
               local n = ZombRand(101)
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
               end   
               -- assign pubic hair
               n = ZombRand(101)
               if n <= 85 then        
                  rasClientData.SelectedBodyHair["Male"]["RasPubicHair"] = "RasBodyMod.MalePubicNatural"
               elseif n <= 95 then
                  rasClientData.SelectedBodyHair["Male"]["RasPubicHair"] = "RasBodyMod.MalePubicStrip"
               else
                  rasClientData.SelectedBodyHair["Male"]["RasPubicHair"] = "None"
                  rasClientData.SelectedBodyHair["Male"]["RasChestHair"] = "None" -- also remove chest hair (for more visual consistency)
               end 
 
               rasClientData.BeardStubble = 0 -- no beard stubble by default (as in vanilla)                  
         end

         rasClientData.HeadStubble = 0  -- no head stubble by default (as in vanilla)
end



-- equip body hair items according to the rasClientData.SelectedBodyHair
local function equipAccordingToSelectedBodyHair(self, desc, skinColor)
      
        if desc:isFemale() then
           for location,_ in pairs(rasSharedData.BodyHairLocations) do
                 if location ~= "RasChestHair" then -- no chest hair for women
                     equipBodyHair(self, desc, location, skinColor)
                 end
           end
        else
           for location,_ in pairs(rasSharedData.BodyHairLocations) do
                  equipBodyHair(self, desc, location, skinColor)
           end
        end               
end 






--------------------------------------------- SECOND PART: new functions managing the new UI elements (new combo boxes etc.) -----------------------------------------------

-- compute size of various UI elements
local function computeSizeData(self, xSpace, extraLen, comboWid, optionLength)

      X_SPACE = xSpace
      EXTRA_RECT_LEN = extraLen
      COMBO_WID = comboWid
      self.comboWid = COMBO_WID
      BH_RECT_LEN = BH_LBL_LEN + UI_BORDER_SPACING + self.comboWid + EXTRA_RECT_LEN
      CL_RECT_LEN = CL_LBL_LEN + UI_BORDER_SPACING + self.comboWid + UI_BORDER_SPACING + optionLength + EXTRA_RECT_LEN + SCROLL_WID
      windowWidth = UI_BORDER_SPACING + self.avatarPanel:getWidth() + (2*UI_BORDER_SPACING) + self.columnWidth + UI_BORDER_SPACING + self.comboWid + X_SPACE + BH_RECT_LEN + X_SPACE 
                    + CL_RECT_LEN + UI_BORDER_SPACING      

      return windowWidth
end



-- compute the screen width and adjust various ui elements
local function adjustScreen(self)
               
        -- remove scroll bars from clothing panel (we have to re-set them below since our size changes of the panel messes up their position)
        local scrollBarWidth = 0
        self.clothingPanel:setScrollChildren(false)
        local children = self.clothingPanel:getChildren()
	    for _,child in pairs(children) do
	              if child.Type == "ISScrollBar" then
                          scrollBarWidth = child:getWidth()
                          self.clothingPanel:removeChild(child)                                                
                  end
        end
        SCROLL_WID = scrollBarWidth + getTextManager():MeasureStringX(UIFont.Small,"ii")

        -- adjust avatar size and position
        local factor = 0.54 -- factor for resizing the avatarPanel
        local screenHeight = getCore():getScreenHeight()
        if screenHeight < 1080 then -- make avatar slightly larger when playing with lower resolution (avatar may get too small otherwise)
              if screenHeight > 1024 then
                  factor = 0.55
              elseif screenHeight > 900 then
                  factor = 0.57
              elseif screenHeight > 800 then
                  factor = 0.59
              elseif screenHeight > 720 then
                  factor = 0.61
              else
                  factor = 0.63
              end
        end

        local x1 = UI_BORDER_SPACING + 1
	    local y1 = UI_BORDER_SPACING + FONT_HGT_TITLE + x1
	    local w1 = self.width - x1 * 2
	    local h1 = self.height - y1 - BUTTON_HGT - UI_BORDER_SPACING - x1
	    local w = math.floor(h1 - UI_BORDER_SPACING - BUTTON_HGT) / 2 --floor to remove rounding errors
        w = w * factor
	    local h = h1 * factor
	    self.avatarPanel:setHeight(h)
	    self.avatarPanel:setWidth(w)
        self.avatarPanel:rescaleAvatarViewer() -- note: rescaleAvatarViewer() does not care about w; width is computed by width=h/2
	    self.avatarPanel:setY(y1)
        self.avatarPanel:setX(UI_BORDER_SPACING)

        -- change only the height of the actual avatar window (but not the width)
        local h2 = math.floor(self.avatarPanel:getHeight() - UI_BORDER_SPACING - BUTTON_HGT) * 1.2
        self.avatarPanel.avatarPanel:setHeight(h2) -- this will increase height of the actual avatar (but not of the avatar panel)
        self.avatarPanel:setHeight(h2 + UI_BORDER_SPACING + 2 + BUTTON_HGT) -- increase panel height
	    self.avatarPanel.turnLeftButton:setY(self.avatarPanel.avatarPanel:getBottom() - BUTTON_HGT) -- correct positions for buttons
	    self.avatarPanel.turnRightButton:setY(self.avatarPanel.turnLeftButton:getY())
        self.avatarPanel.animCombo:setY(self.avatarPanel.avatarPanel:getBottom() + UI_BORDER_SPACING + 2)


        -- next: compute length of some of some ui elements (rects, labels) and the width of the overall ui window
        BH_LBL_LEN = math.max(
            getTextManager():MeasureStringX(UIFont.Small,getText("UI_ClothingType_RasPubicHair")),
            getTextManager():MeasureStringX(UIFont.Small,getText("UI_ClothingType_RasArmpitHair")),
            getTextManager():MeasureStringX(UIFont.Small,getText("UI_ClothingType_RasLegHair")),
            getTextManager():MeasureStringX(UIFont.Small,getText("UI_ClothingType_RasLegHair"))
        )       

        CL_LBL_LEN = 0 
        local optionLength = 0       
        if CharacterCreationMain:shouldShowAllOutfits() then -- compute max length of the clothing labels (if all clothing unlocked enabled)
              local group = BodyLocations.getGroup("Human")
              local allLocations = group:getAllLocations()  
              for i=1,allLocations:size() do
                    local bodyLocation = allLocations:get(i-1):getId()
                    local name = getText("UI_ClothingType_" .. bodyLocation)
                    if name ~= "UI_ClothingType_" .. bodyLocation then
                       CL_LBL_LEN = math.max(CL_LBL_LEN, getTextManager():MeasureStringX(UIFont.Small, name))
                    end
              end 
              optionLength = math.max(self.randomizeOutfitBtn:getWidth(),  self.clothingTextureComboWidth, BUTTON_HGT)    
        else -- compute max length for the clothing labels (if all clothing unlocked not enabled)
             local default = ClothingSelectionDefinitions.default
             for bodyLocation, _ in pairs(default.Female) do
                  CL_LBL_LEN = math.max(CL_LBL_LEN, getTextManager():MeasureStringX(UIFont.Small, getText("UI_ClothingType_" .. bodyLocation)))
             end
             local desc = MainScreen.instance.desc
             local profession = desc:getProfession()
             if ClothingSelectionDefinitions[profession] then
                local profTable = ClothingSelectionDefinitions[profession]
                for bodyLocation, _ in pairs(profTable.Female) do
                     CL_LBL_LEN = math.max(CL_LBL_LEN, getTextManager():MeasureStringX(UIFont.Small, getText("UI_ClothingType_" .. bodyLocation)))
                end
             end
             optionLength = math.max(self.clothingTextureComboWidth, BUTTON_HGT)
        end
       
        -- compute windowWidth
        local windowWidth = computeSizeData(self, X_SPACE_DEFAULT, EXTRA_RECT_LEN_DEFAULT, COMBO_WID_DEFAULT, optionLength)
        if windowWidth > getCore():getScreenWidth() then -- in case players have too small screen resolution, try to reduce size 
                windowWidth = computeSizeData(self, X_SPACE_SMALL, EXTRA_RECT_LEN_SMALL, COMBO_WID_DEFAULT, optionLength)
                if windowWidth > getCore():getScreenWidth() then
                      windowWidth = computeSizeData(self, X_SPACE_SMALL, EXTRA_RECT_LEN_SMALL, COMBO_WID_SMALL, optionLength)
                      if windowWidth > getCore():getScreenWidth() then
                            windowWidth = computeSizeData(self, X_SPACE_SMALLEST, EXTRA_RECT_LEN_SMALLEST, COMBO_WID_SMALL, optionLength)
                            if windowWidth > getCore():getScreenWidth() then
                                 windowWidth = computeSizeData(self, X_SPACE_SMALLEST, EXTRA_RECT_LEN_SMALLEST, COMBO_WID_SMALLEST, optionLength)
                            end
                      end
                 end
        end
 
        -- adjust screen width
        local oldWidth = self.width
        self.width = windowWidth 
        self:setWidth(self.width) -- set screen width
        local movX = (self.width - oldWidth) / 2
        self.x = self.x - movX   
        self:setX(self.x) -- center the ui

        -- adjust position of characterPanel
        local characterX = (2*UI_BORDER_SPACING) + self.avatarPanel:getRight() - self.characterPanel:getWidth() + self.columnWidth + UI_BORDER_SPACING + self.comboWid
        self.characterPanel:setX(characterX)

         -- adjut size and position of body hair panel        
        local bodyHairX = UI_BORDER_SPACING + self.avatarPanel:getWidth() + (2*UI_BORDER_SPACING) + self.columnWidth + UI_BORDER_SPACING + self.comboWid + X_SPACE
        self.bodyHairPanel:setWidth(BH_RECT_LEN) 
        BH_RECT:setWidth(BH_RECT_LEN)
        self.bodyHairPanel:setX(bodyHairX)        

        -- adjust size and postion of clothing panel              
        local clothX = bodyHairX + BH_RECT_LEN + X_SPACE
        local clothY = UI_BORDER_SPACING*2 + FONT_HGT_TITLE + 1
        self.clothingPanel:setWidth(CL_RECT_LEN)
        self.clothingPanel:setX(clothX)
        self.clothingPanel:setY(clothY + FONT_HGT_MEDIUM + 5 +  UI_BORDER_SPACING)
        self.clothingPanel:setHeight(CL_PANEL_HGHT - (FONT_HGT_MEDIUM + 5 + UI_BORDER_SPACING))          
        self.clothingLbl:setX(clothX)
        self.clothingRect:setX(clothX)
        self.clothingRect:setWidth(CL_RECT_LEN)

        local btnPadding = JOYPAD_TEX_SIZE + UI_BORDER_SPACING*2
        local btnWidth = btnPadding/4 + getTextManager():MeasureStringX(UIFont.Medium, getText("UI_rasBodyMod_RemoveAll"))
        REMOVE_ALL:setX(clothX + CL_RECT_LEN - btnWidth)

        -- add scroll bars to clothingPanel
        self.clothingPanel:setScrollChildren(true)
        self.clothingPanel:setScrollHeight(self.yOffset)
        self.clothingPanel:addScrollBars() 
                           	         
        -- adjust position of bottom buttons (back, play, random etc.)
        local btnPadding = JOYPAD_TEX_SIZE + UI_BORDER_SPACING*2
        local btnWidth = btnPadding + getTextManager():MeasureStringX(UIFont.Small, getText("UI_btn_back"))

        self.backButton:setAnchorLeft(true)
        self.backButton:setAnchorRight(false)
        self.backButton:setAnchorTop(false)
        self.backButton:setAnchorBottom(true)
        self.backButton:setX(UI_BORDER_SPACING + 1)

        self.presetPanel:setAnchorLeft(true)
        self.presetPanel:setAnchorRight(false)
        self.presetPanel:setAnchorTop(false)
        self.presetPanel:setAnchorBottom(true) 
        self.presetPanel:setX(self.backButton:getRight() + UI_BORDER_SPACING)
        self.presetPanel:setWidth(self.deleteBuildButton:getRight())

        self.playButton:setAnchorLeft(true)
        self.playButton:setAnchorRight(false)
        self.playButton:setAnchorTop(false)
        self.playButton:setAnchorBottom(true) 
        self.playButton:setX(self.width - btnWidth - UI_BORDER_SPACING - 1) 

        self.randomButton:setAnchorLeft(true)
        self.randomButton:setAnchorRight(false)
        self.randomButton:setAnchorTop(false)
        self.randomButton:setAnchorBottom(true)
        self.randomButton:setX(self.playButton.x - UI_BORDER_SPACING - self.randomButton:getWidth())   
end



-- util function: set buttons behind comboBox and make comboBox smaller if necessary
local function setButtons(self, combo, button1, button2)

    local y = combo:getY()

    if (not button1) and button2 then
        button2:setX(combo:getRight() + UI_BORDER_SPACING)
        button2:setY(y)
    elseif button1 and button2 then
        local width = button1:getWidth()
        combo:setWidth(self.comboWid - width - UI_BORDER_SPACING)
        button1:setX(combo:getRight() + UI_BORDER_SPACING)
        button1:setY(y)
        button2:setX(button1:getRight() + UI_BORDER_SPACING)
        button2:setY(y)    
    end
end


-- util function: adjust positions of type, color and decal buttons
local function adjustExtraButtons(self, bodyLocation)

    if self.clothingPanel and self.clothingCombo and self.clothingCombo[bodyLocation] then

        local combo = self.clothingCombo[bodyLocation]
        local colorBtn = self.clothingColorBtn[bodyLocation]
        local textureBtn = self.clothingTextureCombo[bodyLocation]
        local decal = self.clothingDecalCombo

        local y = combo:getY()

        if decal and decal[bodyLocation] and decal[bodyLocation]:isVisible() then
            local decalBtn = self.clothingDecalCombo[bodyLocation]
            local decalWidth = UI_BORDER_SPACING*4 + getTextManager():MeasureStringX(UIFont.Small, getText("UI_characreation_Type") .. " " .. (9))
            decalBtn:setWidth(decalWidth)
            if colorBtn and colorBtn:isVisible() and textureBtn and textureBtn:isVisible() then
                textureBtn:setVisible(false) -- only show decal and color button in this case (to safe space)
                setButtons(self, combo, colorBtn, decalBtn)
            elseif colorBtn and colorBtn:isVisible() then
                setButtons(self, combo, colorBtn, decalBtn)          
            elseif textureBtn and textureBtn:isVisible() then
                setButtons(self, combo, decalBtn, textureBtn)         
            else
                setButtons(self, combo, nil, decalBtn)
            end
        else
            if colorBtn and colorBtn:isVisible() and textureBtn and textureBtn:isVisible() then
                setButtons(self, combo, colorBtn, textureBtn)
            elseif colorBtn and colorBtn:isVisible() then
                setButtons(self, combo, nil, colorBtn)
            elseif textureBtn and textureBtn:isVisible() then
                setButtons(self, combo, nil, textureBtn)
            end
        end
    end
end



-- adjust size and position of combos on clothingPanel 
local function adjustClothingCombos(self)

    if self.clothingPanel and self.clothingCombo then
         
        self.comboWid = COMBO_WID

        local uiWidth = CL_LBL_LEN + UI_BORDER_SPACING + self.comboWid + UI_BORDER_SPACING + self.clothingTextureComboWidth
        local comboXPos = (CL_RECT_LEN - SCROLL_WID)/2 - uiWidth/2 + CL_LBL_LEN + UI_BORDER_SPACING
        local buttonXPos = comboXPos + self.comboWid + UI_BORDER_SPACING

        local y = 0
        if self.outfitLbl then
            self.outfitLbl:setX(comboXPos - UI_BORDER_SPACING - self.outfitLbl:getWidth())
            self.outfitLbl:setY(y)
            self.outfitCombo:setX(comboXPos)
            self.outfitCombo:setY(y)
            self.outfitCombo:setWidth(self.comboWid)
            self.randomizeOutfitBtn:setX(buttonXPos)
            self.randomizeOutfitBtn:setY(y)
            y = y + BUTTON_HGT + UI_BORDER_SPACING
        end

        for bodyLocation,combo in pairs(self.clothingCombo) do
            local label = self.clothingComboLabel[bodyLocation]
            combo:setX(comboXPos)
            combo:setY(y)
            combo:setWidth(self.comboWid)
            label:setX(comboXPos - UI_BORDER_SPACING - label:getWidth())
            label:setY(y)
            adjustExtraButtons(self, bodyLocation)
            
            y = y + BUTTON_HGT + UI_BORDER_SPACING
        end      
    end
end

-- adjust size and position of combos on bodyHairPanel
local function adjustBodyHairCombos(self)

   if self.bodyHairPanel and self.bodyHairCombo then
         
         self.comboWid = COMBO_WID

         local uiWidth = BH_LBL_LEN + UI_BORDER_SPACING + self.comboWid
         local comboXPos = (BH_RECT_LEN/2) - (uiWidth/2) + BH_LBL_LEN + UI_BORDER_SPACING       

         for bodyLocation,combo in pairs(self.bodyHairCombo) do
              local label = self.bodyHairComboLabel[bodyLocation]
              combo:setWidth(self.comboWid)
              combo:setX(comboXPos)
              label:setX(comboXPos - UI_BORDER_SPACING - label:getWidth())
         end
   end
end


-- adjust size and position of combos on characterPanel
local function adjustCharacterCombos(self)

      if self.characterPanel then
            
           local oldRight = self.genderCombo:getX() + self.genderCombo:getWidth()

           self.comboWid = COMBO_WID

           -- adjust size of comboBoxes and rects           
           local diff = nil
           local xOffset = self.characterPanel.width - self.columnWidth - self.comboWid - UI_BORDER_SPACING
           local children = self.characterPanel:getChildren()
	       for _,child in pairs(children) do
                 if child.Type == "ISTextEntryBox" or child.Type == "ISComboBox" then
                          child:setWidth(self.comboWid) 
                          if not diff then
                              diff = oldRight - (child:getX() + self.comboWid)
                          end                                               
                 elseif child.Type == "ISRect" then
                       child:setWidth(self.characterPanel.width - xOffset)
                 end 
           end

           -- adjust size of voice buttons          
           self.voiceDemoButton:setWidth(self.comboWid)
           self.voicePitchSlider:setWidth(self.comboWid)

           -- adjust Position of all ui elements
           local newChildren = self.characterPanel:getChildren()
           for _,child in pairs(newChildren) do
                if child.Type ~= "ISScrollBar" then
                    child:setX(child:getX() + diff)
                end
           end  

           -- compatibility patch for Spongie's Character Creation (maybe add later)
           --[[if self.customisationButton then
                 self.customisationButton:setX(self.skinColorButton:getX() + self.skinColorButton:getWidth() + UI_BORDER_SPACING)
           end]]--              
      end
end



-- next lines of code create the panel for body hair

local BodyHairPanel = ISPanelJoypad:derive("CharacterCreationBodyHairPanel")

function BodyHairPanel:prerender()
	self:doRightJoystickScrolling(20, 20)
	ISPanelJoypad.prerender(self)
	self:setStencilRect(0, 0, self.width, self.height)
end

function BodyHairPanel:render()
	ISPanelJoypad.render(self)
	self:clearStencilRect()
	if self.joyfocus then
		self:drawRectBorder(0, -self:getYScroll(), self:getWidth(), self:getHeight(), 0.4, 0.2, 1.0, 1.0);
		self:drawRectBorder(1, 1-self:getYScroll(), self:getWidth()-2, self:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
	end
end

function BodyHairPanel:tryRemoveChild(child)
	if not child then return end
	self:removeChild(child)
end

function BodyHairPanel:onMouseWheel(del)
	self:setYScroll(self:getYScroll() - del * 40)
end

function BodyHairPanel:onGainJoypadFocus(joypadData)
	ISPanelJoypad.onGainJoypadFocus(self, joypadData)
	self.joypadButtonsY = {}
	for _,table1 in ipairs(self.parent.clothingWidgets) do
		self:insertNewLineOfButtons(table1[1], table1[2], table1[3], table1[4])
	end
	self.joypadIndex = 1
	if self.prevJoypadIndexY ~= -1 then
		self.joypadIndexY = self.prevJoypadIndexY
	else
		self.joypadIndexY = 1
	end
	self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
	self.joypadButtons[self.joypadIndex]:setJoypadFocused(true)
end

function BodyHairPanel:onLoseJoypadFocus(joypadData)
	self.prevJoypadIndexY = self.joypadIndexY
	self:clearJoypadFocus(joypadData)
	ISPanelJoypad.onLoseJoypadFocus(self, joypadData)
end

function BodyHairPanel:onJoypadDown(button, joypadData)
	if button == Joypad.BButton and not self:isFocusOnControl() then
		joypadData.focus = self.parent
		updateJoypadFocus(joypadData)
	else
		ISPanelJoypad.onJoypadDown(self, button, joypadData)
	end
end

function BodyHairPanel:onJoypadDirLeft(joypadData)
	if self.joypadIndex == 1 then
		joypadData.focus = self.parent.characterPanel
		updateJoypadFocus(joypadData)
	else
		ISPanelJoypad.onJoypadDirLeft(self, joypadData)
	end
end

function BodyHairPanel:onJoypadDirRight(joypadData)
	ISPanelJoypad.onJoypadDirRight(self, joypadData)
end

function BodyHairPanel:new(x, y, width, height)
	local o = ISPanelJoypad:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	self.prevJoypadIndexY = -1
	return o
end




-- add header for the body hair section
local function createBodyHairTypeBtn(self)
   
    BH_LBL_LEN = math.max(
            getTextManager():MeasureStringX(UIFont.Small,getText("UI_ClothingType_RasPubicHair")),
            getTextManager():MeasureStringX(UIFont.Small,getText("UI_ClothingType_RasArmpitHair")),
            getTextManager():MeasureStringX(UIFont.Small,getText("UI_ClothingType_RasLegHair")),
            getTextManager():MeasureStringX(UIFont.Small,getText("UI_ClothingType_RasLegHair"))
        )
    BH_RECT_LEN = BH_LBL_LEN + UI_BORDER_SPACING + self.comboWid + EXTRA_RECT_LEN 

    local x = (self:getWidth()/2) - (BH_RECT_LEN/2) -- correct positions will be set later (in adjustScreen())
    local y = UI_BORDER_SPACING*2 + FONT_HGT_TITLE + 1
    self.bodyHairPanel = BodyHairPanel:new(x, y, BH_RECT_LEN, self.height - UI_BORDER_SPACING*4 - BUTTON_HGT- FONT_HGT_TITLE - 2)
	self.bodyHairPanel:initialise()
	self.bodyHairPanel.background = false
    self.bodyHairPanel:setAnchorLeft(false)
	self.bodyHairPanel:setAnchorRight(true)
	self.bodyHairPanel:setAnchorTop(true)
    self.bodyHairPanel:setAnchorBottom(false)
	self:addChild(self.bodyHairPanel)
   
    local lbl = ISLabel:new(0, 0, FONT_HGT_MEDIUM, getText("UI_rasBodyMod_BodyHair"), 1, 1, 1, 1, UIFont.Medium, true)
	lbl:initialise()                                                                                                                            
	lbl:instantiate()
    self.bodyHairPanel:addChild(lbl)
	
	local rect = ISRect:new(0, FONT_HGT_MEDIUM + 5, BH_RECT_LEN, 1, 1, 0.3, 0.3, 0.3)
	rect:setAnchorRight(false)
	rect:initialise()
	rect:instantiate()
    self.bodyHairPanel:addChild(rect)

    BH_RECT = rect -- store for later usage
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
		local item = instanceItem(itemType)
		if item then
		     rasClientData.SelectedBodyHair[gender][bodyLocation] = item:getFullType()          
	         --desc:setWornItem(bodyLocation, item)			
		end  
	end
	
    equipBodyHair(self, desc, bodyLocation, self.skinColor) -- equip selected body hair
	manageMalePrivatePart(self, desc, self.skinColor) -- equip correct penis model
    updateSelectedBodyHairCombo(self)
end





-- creates a single combo box for body hair location; almost a copy from vanilla createClothingCombo except that we add body hair ui elements to the character panel
local function createBodyHairCombo(self, labelTxt, bodyLocation)
	local comboHgt = FONT_HGT_SMALL + 3 * 2	

	if not self.clothingPanel then return; end
		 
    local uiLength = self.comboWid + UI_BORDER_SPACING + BH_LBL_LEN   
    local xPos = (BH_RECT_LEN/2) - (uiLength/2) + UI_BORDER_SPACING + BH_LBL_LEN 

    local label = ISLabel:new(xPos - UI_BORDER_SPACING, Y_OFFSET, comboHgt, labelTxt, 1, 1, 1, 1, UIFont.Small)
	label:initialise()
    self.bodyHairPanel:addChild(label)

    local gender = "Male"
    local desc = MainScreen.instance.desc
    if desc:isFemale() then
         gender = "Female"
    end
    local optimizedTable = rasSharedData.OptimizedBodyHair[gender] -- required for making the preview work

    local combo = ISComboBox:new(xPos, Y_OFFSET, self.comboWid, comboHgt, self, onBodyHairComboSelected, bodyLocation)
	combo:initialise()
    combo.pointOnItem = function(_self, _index) -- preview for the body hair item
		self.avatarPanel:setFacePreview(false)
		if _self.lastIndex ~= _index then
			desc:setWornItem(bodyLocation, nil)
			local itemType = combo:getOptionData(_index)
			if itemType then
                local optimizedItem = itemType                
                if optimizedTable[self.skinColor] then
                    optimizedItem = itemType .. "_" .. optimizedTable[self.skinColor] -- some skin colors come with optimized hair items for better visuals
                end         
                local item = instanceItem(optimizedItem)
                if not item then -- if optimized version of item doesn't exist, take default version
                      item = instanceItem(itemType)
                end
				if item then
					desc:setWornItem(bodyLocation, item)
				end
			end
            updateSelectedBodyHairCombo(self)
            manageMalePrivatePart(self, desc, self.skinColor)
			self.avatarPanel:setSurvivorDesc(desc)
			_self.lastIndex = _index
		end
	end
	combo.bodyLocation = bodyLocation;
	self.bodyHairPanel:addChild(combo)
		  	
	self.bodyHairCombo = self.bodyHairCombo or {}
	self.bodyHairComboLabel = self.bodyHairComboLabel or {}
	
	self.bodyHairCombo[bodyLocation] = combo
	self.bodyHairComboLabel[bodyLocation] = label;
	
    Y_OFFSET = Y_OFFSET + BUTTON_HGT + UI_BORDER_SPACING

	return
end






-- generates the list of body hair combo boxes; similar to vanilla doClothingCombos
local function doBodyHairCombo(self, definition)

    Y_OFFSET = FONT_HGT_MEDIUM + 5 + UI_BORDER_SPACING

    if not self.characterPanel then return; end
        
    -- reinit all body hair options
    if self.bodyHairCombo then
          
            -- remove body hair combo boxes
			for i,v in pairs(self.bodyHairCombo) do
			     if rasSharedData.BodyHairLocations[v.bodyLocation] then				
				   self.bodyHairPanel:removeChild(self.bodyHairComboLabel[v.bodyLocation]);
				   self.bodyHairPanel:removeChild(v);
	             end				
			end          
	end
    self.bodyHairCombo = {};
    self.bodyHairComboLabel = {};
		
	-- generate the list of ui elements (aka combo boxes) for body hair and put them to the body hair section in the character panel 
	-- almost a copy from the vanilla code which does the same for clothing ui elements	
	for bodyLocation, profTable in pairs(definition) do          
	    if rasSharedData.BodyHairLocations[bodyLocation] then  
		        local combo = nil
		        if self.bodyHairCombo then
			        combo = self.bodyHairCombo[bodyLocation]
		        end
		        if not combo then
			        createBodyHairCombo(self, getText("UI_ClothingType_" .. bodyLocation), bodyLocation);
			        combo = self.bodyHairCombo[bodyLocation];
			        --combo:addOptionWithData(getText("UI_characreation_clothing_none"), nil)
		        end
		        combo.options = {}
		        combo:addOptionWithData(getText("UI_characreation_clothing_none"), nil)
		        
		        for j,clothing in ipairs(profTable.items) do -- populate combo with options coming from the body hair items
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

        if self.outfitCombo then 
              self.outfitCombo.selected = 1 -- show "outfit none" when in all-clothing-unlocked mode
        end

        self:updateSelectedClothingCombo()
        self:disableBtn() -- necessary to update clothing combos in all-clothing-unlocked
	    self.avatarPanel:setSurvivorDesc(desc)	
        self:arrangeClothingUI()
end



---------------------------------- THIRD PART: modified vanilla functions -----------------------------------------------------------

local vanilla_create = CharacterCreationMain.create
function CharacterCreationMain:create(...)
 
    vanilla_create(self, ...) -- execute vanilla code
 
    createBodyHairTypeBtn(self) -- create header and panel for body hair elements 

    -- remove and re-add the avatar so that it is rendered above the clothingPanel
    self:removeChild(self.avatarPanel)
	self:addChild(self.avatarPanel)
end


-- need to modify this function to make sure our custom comboWid size is used
local vanilla_createNameAndGender = CharacterCreationMain.createNameAndGender
function CharacterCreationMain:createNameAndGender(...)

        self.comboWid = COMBO_WID
        self.xOffset = self.characterPanel.width - self.columnWidth - self.comboWid - UI_BORDER_SPACING
        vanilla_createNameAndGender(self, ...) -- execute vanilla code
end

-- vanilla chest hair button is not used anymore, so we can save its ui space
local vanilla_createBodyTypeBtn = CharacterCreationMain.createBodyTypeBtn
function CharacterCreationMain:createBodyTypeBtn(...)

       vanilla_createBodyTypeBtn(self, ...) -- execute vanilla code

       self.yOffset = self.yOffset - UI_BORDER_SPACING - BUTTON_HGT -- remove space for tick box
end

-- we rearrange some clothing-ui-elements and introduce the Remove-All-button
local vanilla_createClothingBtn = CharacterCreationMain.createClothingBtn
function CharacterCreationMain:createClothingBtn(...)

	 vanilla_createClothingBtn(self, ...) -- execute vanilla code

     CL_PANEL_HGHT = self.clothingPanel:getHeight() -- store panel height for later usage

     -- put some ui elements to the self for better scrollBar behavior
     local clothY = UI_BORDER_SPACING*2 + FONT_HGT_TITLE + 1

     self.clothingPanel:removeChild(self.clothingLbl)
     self:addChild(self.clothingLbl) -- no scroll for the section title
     self.clothingLbl:setY(clothY)

     self.clothingPanel:removeChild(self.clothingRect)
     self:addChild(self.clothingRect) -- no scroll for the title underline
     self.clothingRect:setY(clothY + FONT_HGT_MEDIUM + 5)

     -- introduce Remove-All-button	
     local fontHgt = getTextManager():getFontHeight(self.skinColorLbl.font) 
     local btnPadding = JOYPAD_TEX_SIZE + UI_BORDER_SPACING*2
     local btnWidth = btnPadding/4 + getTextManager():MeasureStringX(UIFont.Medium, getText("UI_rasBodyMod_RemoveAll"))
     local button = ISButton:new(CL_RECT_LEN - btnWidth, self.clothingLbl:getY(), btnWidth, BUTTON_HGT, getText("UI_rasBodyMod_RemoveAll"), self)
     button:setOnClick(onRemoveAllClothingClicked, self)
     button:initialise()
     self:addChild(button)	 

     REMOVE_ALL = button
end



-- exclude some weird clothing combinations when random button  is pressed (e.g. no CropTop + TankTops); combinations can still be choosen 
-- manually by the player
local vanilla_dressWithDefinitions = CharacterCreationMain.dressWithDefinitions
function CharacterCreationMain:dressWithDefinitions(definition, resetWornItems, ...)

    vanilla_dressWithDefinitions(self, definition, resetWornItems, ...) -- execute vanilla code 
    
    local desc = MainScreen.instance.desc
    if desc:isFemale() then
        local item = desc:getWornItem("Tshirt")
        if item then
            local itemType = item:getFullType()
            if itemType == "Base.Shirt_CropTopTINT" or itemType == "Base.Shirt_CropTopNoArmTINT" then
                desc:setWornItem("TankTop", nil)
                self:updateSelectedClothingCombo() 
                self.avatarPanel:setSurvivorDesc(desc)
            elseif itemType == "Base.BoobTube" or itemType == "Base.BoobTubeSmall" then 
                desc:setWornItem("TankTop", nil)
                desc:setWornItem("UnderwearTop", nil)
                local bra = instanceItem("Base.Bra_Strapless_White")
                desc:setWornItem("UnderwearTop", bra)
                self:updateSelectedClothingCombo() 
                self.avatarPanel:setSurvivorDesc(desc)
            end
        end
    end
end


        
-- when onResolutionChange is called, we have to manually adjust the screen again to properly display
-- the new ui elements
local vanilla_onResolutionChange = CharacterCreationMain.onResolutionChange
function CharacterCreationMain:onResolutionChange(oldw, oldh, neww, newh, ...)
        
       local oldX_Cloth = self.clothingPanel:getX() -- backup data
       local oldWidth_Cloth = self.clothingPanel:getWidth()
       local oldHeight_Cloth = self.clothingPanel:getHeight()

       vanilla_onResolutionChange(self, oldw, oldh, neww, newh, ...) -- execute vanilla code

       self.clothingPanel:setX(oldX_Cloth) -- restore data
       self.clothingPanel:setWidth(oldWidth_Cloth)
       self.clothingPanel:setHeight(oldHeight_Cloth)

       self.comboWid = COMBO_WID
       adjustScreen(self)
       adjustClothingCombos(self)
       adjustBodyHairCombos(self)
       adjustCharacterCombos(self)
end




-- vanilla arrangeClothingUI() may change self.comboWid, so we have to re-set it to our value
local vanilla_arrangeClothingUI = CharacterCreationMain.arrangeClothingUI
function CharacterCreationMain:arrangeClothingUI(...)

       vanilla_arrangeClothingUI(self, ...) -- execute vanilla code

       self.comboWid = COMBO_WID
       self.clothingRect:setWidth(CL_RECT_LEN)
       adjustClothingCombos(self) 
end


-- back up our ui data and restore since the vanilla function messes things up for us
local vanilla_arrangeClothingRightSideElements = CharacterCreationMain.arrangeClothingRightSideElements
function CharacterCreationMain:arrangeClothingRightSideElements(bodyLocation, ...)

    local combo = nil
    local comboX = nil
    if self.labelRight then 
        self.comboWid = COMBO_WID
        combo = self.clothingCombo[bodyLocation]
        comboX = combo:getX()
    end

    vanilla_arrangeClothingRightSideElements(self, bodyLocation, ...) -- execute vanilla

    if combo then
        self.comboWid = COMBO_WID -- restore data   
        combo:setWidth(COMBO_WID)
        combo:setX(comboX)

        local label = self.clothingComboLabel[bodyLocation]
        label:setX(comboX - UI_BORDER_SPACING - label:getWidth())
     
        adjustExtraButtons(self, bodyLocation) 
    end   
end


-- when clothing is initialized, create combo boxes for body hair and align current body hair/penis/skin with current skin color
vanilla_initClothing = CharacterCreationMain.initClothing
function CharacterCreationMain:initClothing(...)    
      
    self.comboWid = COMBO_WID

    vanilla_initClothing(self, ...) -- execute vanilla code

    local desc = MainScreen.instance.desc
                
	-- create combo boxes for body hair
	local hairTable = rasSharedData.BodyHairDefinitions
	if desc:isFemale() then
		  doBodyHairCombo(self, hairTable.Female);
	else
		  doBodyHairCombo(self, hairTable.Male);
	end				
	    
	assignRandomBodyHair(desc) -- assign random body hair to rasClientData.SelectedBodyHair			
    self.skinColor = desc:getHumanVisual():getSkinTextureIndex() + 1 -- store skin color

	-- equip skin, body hair and penis and align with skin/hair color
	if self.skinColor then 
         rasClientData.SkinColorIndex = self.skinColor -- store skin color
         equipSkin(self, desc, self.skinColor) -- equip skin
         equipAccordingToSelectedBodyHair(self, desc, self.skinColor) -- equip body hair
	     manageMalePrivatePart(self, desc, self.skinColor) -- equip penis	
         vestGlitchFix(desc)     
	     updateSelectedBodyHairCombo(self)
    end	   

    if desc:getProfession() ~= PROFESSION then
          PROFESSION = desc:getProfession()
          SCREEN_ADJUSTED = false -- if player switches profession, we have to re-set size/positions of some ui elements 
    end                           -- since this may result in different clothing options available

    if self.clothingPanel and not SCREEN_ADJUSTED then
           adjustScreen(self)
           adjustBodyHairCombos(self)
           --adjustCharacterCombos(self)
           SCREEN_ADJUSTED = true
           DEBUG_SCREEN_ADJUSTED = false
     end
     adjustClothingCombos(self)    
end



-- next two functions make the mod compatible with the all-clothing-unlocked mode

-- when creating list of clothing items, do not include body hair items
local vanilla_createClothingComboDebug = CharacterCreationMain.createClothingComboDebug
function CharacterCreationMain:createClothingComboDebug(bodyLocation, ...)

      if isClothingLocation(bodyLocation) then -- clothing items only
           vanilla_createClothingComboDebug(self, bodyLocation, ...)
      end
end


-- same as initClothing() but here for the debug mode
local vanilla_initClothingDebug = CharacterCreationMain.initClothingDebug 
function CharacterCreationMain:initClothingDebug(...)
         
         self.comboWid = COMBO_WID

         vanilla_initClothingDebug(self, ...) 
                           
         local desc = MainScreen.instance.desc

         -- create combo boxes for body hair (also includes the color options for body hair)
	     local hairTable = rasSharedData.BodyHairDefinitions
	     if desc:isFemale() then
		    doBodyHairCombo(self, hairTable.Female);
	     else
		    doBodyHairCombo(self, hairTable.Male);
	     end				
	
         -- assign random body hair to rasClientData.SelectedBodyHair
	     assignRandomBodyHair(desc)
			
         self.skinColor = desc:getHumanVisual():getSkinTextureIndex() + 1

	     -- equip skin, body hair and penis and align with skin/hair color
	     if self.skinColor then 
            rasClientData.SkinColorIndex = self.skinColor -- store skin color
            equipSkin(self, desc, self.skinColor) -- equip skin
            equipAccordingToSelectedBodyHair(self, desc, self.skinColor) -- equip body hair
	        manageMalePrivatePart(self, desc, self.skinColor) -- equip penis	 
            vestGlitchFix(desc)    
	        updateSelectedBodyHairCombo(self)
         end	


         if self.clothingPanel and not DEBUG_SCREEN_ADJUSTED then
             adjustScreen(self)
             adjustBodyHairCombos(self)
             --adjustCharacterCombos(self)
             SCREEN_ADJUSTED = false
             DEBUG_SCREEN_ADJUSTED = true
         end

         self:updateSelectedClothingCombo()
         adjustClothingCombos(self) 
end




-- we disable the tick box for vanilla chest hair since this mod introduces it's own chest hair; also don't let
-- disablebtn() populate the combo boxes in all-clothing-unlocked mod since this is a huge performance hit (it is done several
-- times when random button is pressed -> why??) 
local vanilla_disableBtn = CharacterCreationMain.disableBtn
function CharacterCreationMain:disableBtn(...)
        
        vanilla_disableBtn(self, ...) -- execute vanilla code

        adjustCharacterCombos(self) -- vanilla changes size and position of characterPanel elements, so we have to modify

        -- remove chest hair tick box
        if self.chestHairLbl then 
           self.chestHairLbl:setVisible(false)     
           self.chestHairTickBox:setVisible(false)
        end

        -- remove gltich-fix vests from the combo options so that they aren't double entries (only happens in all-clothing-unlocked, vanilla
        -- populates the clothing combo boxes in disableBtn() thn :( )
        if self:shouldShowAllOutfits() and self.clothingCombo then
            local locations = {"TorsoExtraVestBullet", "TorsoExtraVest"}
            for _,bodyLocation in pairs(locations) do
                 if self.clothingCombo[bodyLocation] then
                         local combo = self.clothingCombo[bodyLocation]
			             combo.options = {}
			             combo:addOptionWithData(getText("UI_characreation_clothing_none"), nil)
			             local items = getAllItemsForBodyLocation(bodyLocation)
			             table.sort(items, function(a,b)
				            local itemA = ScriptManager.instance:FindItem(a)
				            local itemB = ScriptManager.instance:FindItem(b)
				            return not string.sort(itemA:getDisplayName(), itemB:getDisplayName())
			             end)
			             for _,fullType in ipairs(items) do
				             local item = ScriptManager.instance:FindItem(fullType)
                             if not rasSharedData.GlitchedItemsReverse[fullType] then
				                local displayName = item:getDisplayName()
				                combo:addOptionWithData(displayName, fullType)
                             end
			             end
                 end
            end
      end
end



-- apply/unapply beard stubble if player has choosen to do so
local vanilla_onBeardStubbleSelected = CharacterCreationMain.onBeardStubbleSelected
function CharacterCreationMain:onBeardStubbleSelected(index, selected, ...)

    local desc = MainScreen.instance.desc
    if not desc:isFemale() then
	    if selected then
            local beard = desc:getHumanVisual():getBeardModel()
            if not rasSharedData.FullBeards[beard] then -- only show stubble when not having a full beard
                 local stubble = instanceItem("RasBodyMod.StubbleBeard_Light")
                 if rasClientData.SkinColorIndex == 4 or rasClientData.SkinColorIndex == 5 then -- darker skin colors get different stubble texture for better visuals
                    stubble = instanceItem("RasBodyMod.StubbleBeard_Dark")
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

-- make beard stubble behave correctly under the preview feature
local vanilla_createBeardTypeBtn = CharacterCreationMain.createBeardTypeBtn
function CharacterCreationMain:createBeardTypeBtn(...)
 
         vanilla_createBeardTypeBtn(self, ...) -- execute vanilla code

         local desc = MainScreen.instance.desc
         self.beardTypeCombo.pointOnItem = function(_self, _index)
		          self.avatarPanel:setFacePreview(true)
		          if _self.lastIndex ~= _index then
                       local beard = _self:getOptionData(_index)                       
                       if rasClientData.BeardStubble == 1 then
                           if not rasSharedData.FullBeards[beard] then
			                   local stubble = instanceItem("RasBodyMod.StubbleBeard_Light")
                               if rasClientData.SkinColorIndex == 4 or rasClientData.SkinColorIndex == 5 then
                                  stubble = instanceItem("RasBodyMod.StubbleBeard_Dark")
                               end
		                       desc:setWornItem("RasBeardStubble", stubble)
                           else
                               desc:setWornItem("RasBeardStubble", nil)
                           end
                       end
                       desc:getHumanVisual():setBeardModel(beard)
			           self.avatarPanel:setSurvivorDesc(desc)
			           _self.lastIndex = _index
		          end
	     end
end


-- when full beard, we hide beard stubble for better visuals
local vanilla_onBeardTypeSelected = CharacterCreationMain.onBeardTypeSelected
function CharacterCreationMain:onBeardTypeSelected(combo, ...)

    local desc = MainScreen.instance.desc
	local beard = combo:getOptionData(combo.selected)
    if rasSharedData.FullBeards[beard] then
         if rasClientData.BeardStubble == 1 then
            desc:setWornItem("RasBeardStubble", nil) -- hide stubble when having a full beard
         end 
    elseif rasClientData.BeardStubble == 1 and desc:getWornItem("RasBeardStubble") == nil then
         local stubble = instanceItem("RasBodyMod.StubbleBeard_Light")
         if rasClientData.SkinColorIndex == 4 or rasClientData.SkinColorIndex == 5 then
                stubble = instanceItem("RasBodyMod.StubbleBeard_Dark")
         end
		 desc:setWornItem("RasBeardStubble", stubble) -- show stubble when no full beard
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
              local stubble = instanceItem("RasBodyMod.StubbleHead_Light_F")
              if rasClientData.SkinColorIndex == 4 or rasClientData.SkinColorIndex == 5 then
                    stubble = instanceItem("RasBodyMod.StubbleHead_Dark_F")
              end
		      desc:setWornItem("RasHeadStubble", stubble)
         else
              local stubble = instanceItem("RasBodyMod.StubbleHead_Light_M")
              if rasClientData.SkinColorIndex == 4 or rasClientData.SkinColorIndex == 5 then
                    stubble = instanceItem("RasBodyMod.StubbleHead_Dark_M")
              end
		      desc:setWornItem("RasHeadStubble", stubble)
         end
    else
         rasClientData.HeadStubble = 0
         desc:setWornItem("RasHeadStubble", nil)
    end

    vanilla_onShavedHairSelected(self, index, selected, ...) -- execute vanilla code
end


-- some items have decals+color+texture choice; we make sure player always equips the white texture so that the color choice has an effect (this is a problem with a vanilla game);
-- our mod always hides the texture choice button in this case, so our interface is consistent
local vanilla_onClothingComboSelected = CharacterCreationMain.onClothingComboSelected
function CharacterCreationMain:onClothingComboSelected(combo, bodyLocation, ...)

    vanilla_onClothingComboSelected(self, combo, bodyLocation, ...) -- execute vanilla game
	
	local itemType = combo:getOptionData(combo.selected)
	if itemType == "Base.Tshirt_HipHop" or itemType == "Base.Tshirt_EMD" then -- only those 2 shirts affected??      
		local item = instanceItem(itemType)
		if item then
            local visual = item:getVisual()			
            local clothingItem = visual:getClothingItem()
            if clothingItem and not clothingItem:hasModel() then
                local textureChoices = clothingItem:getBaseTextures()
                if textureChoices:size() >= 2 then -- in case vanilla game (or other mods) change smth about the clothing's xml
                    visual:setBaseTexture(1) -- in both cases, this is the white shirt texture
                    local desc = MainScreen.instance.desc
                    desc:setWornItem(bodyLocation, nil)
                    desc:setWornItem(bodyLocation, item)
                    self:updateSelectedClothingCombo();
	                self.avatarPanel:setSurvivorDesc(desc)
	                self:disableBtn()
	                self:arrangeClothingUI()
                end
            end
		end
    end
end


-- if clothing is updated, we must check whether exceptional clothing is worn and (un-)equip the penis accordingly
local vanilla_updateSelectedClothingCombo = CharacterCreationMain.updateSelectedClothingCombo
function CharacterCreationMain:updateSelectedClothingCombo(...)
                 
        local desc = MainScreen.instance.desc

        vanilla_updateSelectedClothingCombo(self, ...) --execute vanilla code
               	
        manageMalePrivatePart(self, desc, self.skinColor) -- (un-)equip penis depending on worn clothes
        vestGlitchFix(desc) -- apply vest glitch fix
end


-- if we change the skin color, we have to align skins/penis/body hair with skin color
local vanilla_onSkinColorPicked = CharacterCreationMain.onSkinColorPicked
function CharacterCreationMain:onSkinColorPicked(color, mouseUp, ...)
    
    vanilla_onSkinColorPicked(self, color, mouseUp, ...) -- execute vanilla code

    local desc = MainScreen.instance.desc    

    rasClientData.SkinColorIndex = self.colorPickerSkin.index  -- store the skin color index for later
    self.skinColor = self.colorPickerSkin.index
    equipSkin(self, desc, self.colorPickerSkin.index) -- equip correct skin

    equipAccordingToSelectedBodyHair(self, desc, self.skinColor) -- align body hair
	manageMalePrivatePart(self, desc, self.skinColor) -- align penis with choosen skin color 
    
    if rasClientData.BeardStubble == 1 then
         self:onBeardStubbleSelected(nil, true) -- align beard stubble with skin color
    end
    if rasClientData.HeadStubble == 1 then
         self:onShavedHairSelected(nil, true) -- align head stubble with skin color
    end
end








-- we need to modify this so that the player doesn't undress the nude textures when interacting with the predefined outfits
local vanilla_onOutfitSelected = CharacterCreationMain.onOutfitSelected
function CharacterCreationMain:onOutfitSelected(combo, ...)

      vanilla_onOutfitSelected(self, combo, ...) -- execute vanilla code
      
      local desc = MainScreen.instance.desc
      equipAccordingToSelectedBodyHair(self, desc, self.skinColor)
      equipSkin(self, desc, self.skinColor) 
      manageMalePrivatePart(self, desc, self.skinColor)
      vestGlitchFix(desc) 
      updateSelectedBodyHairCombo(self)
      self:updateSelectedClothingCombo()
end



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
       equipSkin(self, desc, self.skinColor)
       equipAccordingToSelectedBodyHair(self, desc, self.skinColor)
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





-- next function has to be modified to display the char creation screen correctly when player chooses
-- "Continue with new character" after character death
local vanilla_onRespawn = ISPostDeathUI.onRespawn
function ISPostDeathUI:onRespawn(...)

    vanilla_onRespawn(self, ...) --execute vanilla

    if not MainScreen.instance:isReallyVisible() then
        PROFESSION = nil
        SCREEN_ADJUSTED = false
        DEBUG_SCREEN_ADJUSTED = false
    end
end






local charCreation = {}

-- update some local variables (in case player changes screen resolution); called in RasBodyModUpdateLocals.lua
function charCreation.updateLocals()

  FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
  FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
  FONT_HGT_TITLE = getTextManager():getFontHeight(UIFont.Title)

  BUTTON_HGT = FONT_HGT_SMALL + 6
end


return charCreation



-- next two functions change colors in skin color selection menu (adjust them to skin colors introduced by the mod)
--[[local CalledBy_createChestTypeBtn = false
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
end]]--


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










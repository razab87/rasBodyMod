-- manipulate the in-game character info screen and introduce a new option of shaving body hair; also manipulate functionality for shaving beard stubbles; at the end, we modify the updateAvatar() function so that the avatar 
-- from the info screen always shows the default version of the penis model although another one might be actually equipped
--
--
-- by razab



require "ISUI/ISPanelJoypad" -- as in vanilla ISCharacterScreen.lua, client (not sure if necessary)
require "ISUI/ISUI3DModel"





local rasSharedData = require("RasBodyModSharedData")
local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG")


local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6
local AVATAR_BORDER = 2 





-- undresses the body part of player before shaving; uses the "undress tables" from RasBodyModSharedData.lua in shared folder
local function undress(player, bodyPartToShave)
       local clothes = player:getWornItems()
       for i=1,clothes:size() do
             local item = clothes:get(i-1):getItem()
             local bodyLocation = item:getBodyLocation()
             local name = item:getFullType()
             if (rasSharedData.UndressLocation[bodyPartToShave][bodyLocation] and not rasSharedData.UndressLocation[bodyPartToShave][bodyLocation]["exceptions"][name])
                or rasSharedData.UndressSpecificItems[bodyPartToShave][name] then
                    ISTimedActionQueue.add(ISUnequipAction:new(player, item, 50))
             end 
       end

end




local function predicateUsableRazor(item)
	return (not item:isBroken()) and item:getCurrentUses() >=1
end

local function predicateUsableScissors(item)
	return (not item:isBroken())
end


-- search player inventory for a razor
local function searchRazor(player)

    local playerInv = player:getInventory()
	local razor = playerInv:getFirstTypeEval("Base.Razor", predicateUsableRazor)
    if razor == nil then
        razor = playerInv:getFirstTypeEval("Base.StraightRazor", predicateUsableRazor)
        if razor == nil then
            local itemA = player:getWornItem(ItemBodyLocation.BACK)
            local itemB = player:getWornItem(ItemBodyLocation.FANNY_PACK_FRONT)
            local itemC = player:getWornItem(ItemBodyLocation.FANNY_PACK_BACK)
            local itemD = player:getPrimaryHandItem()
            local itemE = player:getSecondaryHandItem()
            local containerList = {itemA, itemB, itemC, itemD, itemE}
            for _,v in pairs(containerList) do
                      if v and instanceof(v, "InventoryContainer") then
                             razor = v:getInventory():getFirstTypeEval("Base.Razor", predicateUsableRazor)
                             if razor == nil then
                                razor = v:getInventory():getFirstTypeEval("Base.StraightRazor", predicateUsableRazor)
                             end
                             if razor then
                                  break;
                             end         
                      end
            end
        end
    end

    return razor
end


-- search player inventory for scissors
local function searchScissors(player)

    local playerInv = player:getInventory()
	local scissors = playerInv:getFirstTypeEval("Base.Scissors", predicateUsableScissors)
    if scissors == nil then
        local itemA = player:getWornItem(ItemBodyLocation.BACK)
        local itemB = player:getWornItem(ItemBodyLocation.FANNY_PACK_FRONT)
        local itemC = player:getWornItem(ItemBodyLocation.FANNY_PACK_BACK)
        local itemD = player:getPrimaryHandItem()
        local itemE = player:getSecondaryHandItem()
        local containerList = {itemA, itemB, itemC, itemD, itemE}
        for _,v in pairs(containerList) do
                  if v and instanceof(v, "InventoryContainer") then
                         scissors = v:getInventory():getFirstTypeEval("Base.Scissors", predicateUsableScissors)
                         if scissors then
                              break;
                         end         
                  end
        end
    end

    return scissors
end




-- do this when shaving body hair is clicked
local function onShaveBodyHair(player, choice, bodyLocation)	
		
	local razor = searchRazor(player)
    if razor then
	        ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), razor, true) -- equip razor
	        
            locationID = bodyLocation:toString()
	        if locationID == "rasbomo:leghair" then
	               undress(player, "Legs")
	        elseif locationID == "rasbomo:armpithair" or locationID == "rasbomo:chesthair" then
                   if locationID == "rasbomo:chesthair" then -- in case we shave chest, drop equipped backpacks to ground (to avoid extreme over-encumberance)
                        local backpack = player:getWornItem(ItemBodyLocation.BACK)
                        if backpack then  
                           local playerNum = player:getPlayerNum()
                           ISInventoryPaneContextMenu.dropItem(backpack, playerNum)
                        end                    
                   end
	               undress(player, "Chest")
            elseif locationID == "rasbomo:pubichair" then
                   undress(player, "Pubic")	       	
	        end
	        
	        ISTimedActionQueue.add(RasBodyModShaveBodyHairAction:new(player, choice, locationID, razor))	-- execute shave action
    end				
end




local UIText = {} -- the ui text for the new body hair location (we use those old UI_Clothing_Type strings to keep it compatible with user contributed translations)
UIText["rasbomo:pubichair"] = "UI_ClothingType_RasPubicHair"
UIText["rasbomo:chesthair"] = "UI_ClothingType_RasChestHair"
UIText["rasbomo:armpithair"] = "UI_ClothingType_RasArmpitHair"
UIText["rasbomo:leghair"] = "UI_ClothingType_RasLegHair"


-- create the options for different body hair types
local function bodyHairMenu(self, button)
	local player = self.char;
	local context = ISContextMenu.get(self.char:getPlayerNum(), button:getAbsoluteX(), button:getAbsoluteY() + button:getHeight());
	local playerInv = player:getInventory()
	local bodyHairMenu = context
	local gender = "Male"
	if player:isFemale() then
	   gender = "Female"
	end
	local modData = player:getModData()
    local data = modData.RasBodyMod
	
    -- check whether players has razor in inventory or a bag they are carrying (vanilla allows hair cutting only in those cases, so we do it too)
    local hasRazor = false 
    if searchRazor(player) then
          hasRazor = true 
    end
	
	local option
   
    local locID = rasSharedData.ModLocationID

    if gender == "Female" then -- options for women
         local shaveTable = rasSharedData["ShaveTable"][gender]
         for location,_ in pairs(rasSharedData.BodyHairLocations) do
               if location:toString() ~= "rasbomo:chesthair" then
                   local currentStyle = data[locID[location]]
                   if currentStyle ~= "None" then 
                        if shaveTable[currentStyle] then -- generate options for shaving to a special style
                             for _,v in pairs(shaveTable[currentStyle]) do
                                  option = bodyHairMenu:addOption(getText(UIText[location:toString()]) .. ": " .. v.optionText , player, onShaveBodyHair, v.canBeShavedTo, location);
	                              if not hasRazor then   
		                               self:addTooltip(option, getText("UI_rasBodyMod_RequireRazor"));
                                  end   
                             end
                        end
                        local shaveAllText = "UI_rasBodyMod_Shave"
                        if locID[location] == "RasPubicHair" then
                           shaveAllText = "UI_rasBodyMod_PubicShaveComp"
                        end
                        option = bodyHairMenu:addOption(getText(UIText[location:toString()]) .. ": " .. getText(shaveAllText), player, onShaveBodyHair, "None", location); -- can always be shaved to none
	                    if not hasRazor then   
		                       self:addTooltip(option, getText("UI_rasBodyMod_RequireRazor"));
                        end 
                   end
               end        
         end
    else -- options for men
         local shaveTable = rasSharedData["ShaveTable"][gender]
         for location,_ in pairs(rasSharedData.BodyHairLocations) do
               local currentStyle = data[locID[location]]
               if currentStyle ~= "None" then 
                    if shaveTable[currentStyle] then
                         for _,v in pairs(shaveTable[currentStyle]) do
                              option = bodyHairMenu:addOption(getText(UIText[location:toString()]) .. ": " .. v.optionText , player, onShaveBodyHair, v.canBeShavedTo, location);
                              if not hasRazor then   
	                               self:addTooltip(option, getText("UI_rasBodyMod_RequireRazor"));
                              end   
                         end
                    end
                    local shaveAllText = "UI_rasBodyMod_Shave"
                    if locID[location] == "RasPubicHair" then
                       shaveAllText = "UI_rasBodyMod_PubicShaveComp"
                    end
                    option = bodyHairMenu:addOption(getText(UIText[location:toString()]) .. ": " .. getText(shaveAllText), player, onShaveBodyHair, "None", location);
                    if not hasRazor then   
	                       self:addTooltip(option, getText("UI_rasBodyMod_RequireRazor"));
                    end 
               end      
         end
    end

	

	if JoypadState.players[self.playerNum+1] and context.numOptions > 0 then
		context.origin = self
		context.mouseOver = 1
		setJoypadFocus(self.playerNum, context)
	end
end





-- check how much body hair a character has and return "none", "some" or "full" accordingly
local function getBodyHairSummary(self)
 
    local gender = "Male"
    local player = self.char
    if self.char:isFemale() then
        gender = "Female"
    end
    local modData = player:getModData()
    local data = modData.RasBodyMod

    if data then -- in MP, modData may not be present during the first few ticks (when mod is added to an existing MP game)
        if gender == "Female" then
            if data["RasPubicHair"] == "None" and data["RasArmpitHair"] == "None" and data["RasLegHair"] == "None" then
                return getText("UI_rasBodyMod_None")
            elseif data["RasPubicHair"] == "RasBodyMod.FemalePubicNatural" and data["RasArmpitHair"] == "RasBodyMod.FemaleArmpit" and data["RasLegHair"] == "RasBodyMod.FemaleLeg" then
                return getText("UI_rasBodyMod_Full")
            else
                return getText("UI_rasBodyMod_Some")
            end
        else
            if data["RasPubicHair"] == "None" and data["RasArmpitHair"] == "None" and data["RasLegHair"] == "None" and data["RasChestHair"] == "None" then
                return getText("UI_rasBodyMod_None")
            elseif data["RasPubicHair"] == "RasBodyMod.MalePubicNatural" and data["RasArmpitHair"] == "RasBodyMod.MaleArmpit" and data["RasLegHair"] == "RasBodyMod.MaleLeg" 
               and data["RasChestHair"] == "RasBodyMod.MaleChest" then
                return getText("UI_rasBodyMod_Full")
            else
                return getText("UI_rasBodyMod_Some")
            end
        end
    else
        return ""
    end
end



----- next we modify some vanilla functions from vanilla client/XpSystem/ISUI/ISCharacterScreen.lua

-- re-create the avatar and make it slightly larger than in vanilla (will result in much better
-- visuals for male characters when nude)
local vanilla_create = ISCharacterScreen.create
function ISCharacterScreen:create(...)

       vanilla_create(self, ...) -- execute vanilla code
       
       self:removeChild(self.avatarPanel) -- remove vanilla avatar

       self.avatarX = UI_BORDER_SPACING+1+AVATAR_BORDER 
	   self.avatarY = UI_BORDER_SPACING+1+AVATAR_BORDER
	   self.avatarWidth = 128 * 1.2 -- larger size
	   self.avatarHeight = 256 * 1.2
	   self.avatarPanel = ISCharacterScreenAvatar:new(self.avatarX, self.avatarY, self.avatarWidth, self.avatarHeight) -- re-create avatar
	   self.avatarPanel:setVisible(true)
	   self:addChild(self.avatarPanel)
	   self.avatarPanel:setOutfitName("Foreman", false, false)
	   self.avatarPanel:setState("idle")
	   self.avatarPanel:setDirection(IsoDirections.S)
	   self.avatarPanel:setIsometric(false)
end



-- this function is modified so that the UI shows "stubbles" in the beard section in case player has stubbles but no other beard (vanilla would show "none" which doesn't fit to the mod's content)
local vanilla_loadBeardAndHairStyle = ISCharacterScreen.loadBeardAndHairStyle
function ISCharacterScreen.loadBeardAndHairStyle(self, ...)

    vanilla_loadBeardAndHairStyle(self, ...)
     
    if not self.char:isFemale() then
        local currentBeard = getBeardStylesInstance():FindStyle(self.char:getHumanVisual():getBeardModel())
        local data = self.char:getModData().RasBodyMod
        if data and data.BeardStubble == 1 and (currentBeard == nil or currentBeard:getLevel() <= 0) then
             self.beardStyle = getText("UI_Stubble") -- display that character has stubble in case stubble but no beards are present
        end
    end
end


-- change positions of vanilla UI elements and add the section for shaving body hair (didn't find a place other than the render function unfortunately); also show the the "change beard" option in case
-- player has beard stubbles
local calledByRender = false
local windowHeight = nil
local vanilla_render = ISCharacterScreen.render
function ISCharacterScreen.render(self, ...)     
      
    calledByRender = true
    vanilla_render(self, ...) -- execute vanilla code           
    calledByRender = false          
             
    -- adjust the x-position for vanilla hair and beard ui elements
    local hairWidth = getTextManager():MeasureStringX(UIFont.Small, self.hairStyle)
	local beardWidth = (self.char:isFemale() and 0) or getTextManager():MeasureStringX(UIFont.Small, self.beardStyle)
	local summary = getBodyHairSummary(self)
	local bodyHairWidth = getTextManager():MeasureStringX(UIFont.Small, summary)
	local textWid = 0
	textWid = math.max(hairWidth, textWid)
	textWid = math.max(beardWidth, textWid)
	textWid = math.max(bodyHairWidth, textWid)
	local buttonsX = self.xOffset + 10 + textWid + 10
	
	self.hairButton:setX(buttonsX) 
	self.beardButton:setX(buttonsX)
    
    local yPos = self.hairButton:getY() + BUTTON_HGT + UI_BORDER_SPACING
    if not self.char:isFemale() then
             yPos = self.beardButton:getY() + BUTTON_HGT + UI_BORDER_SPACING
    end

	-- draw ui elements for body hair shaving	
	self:drawTextRight(getText("UI_rasBodyMod_BodyHair"), self.xOffset, yPos, 1,1,1,1, UIFont.Small);
    self:drawText(summary, self.xOffset + 10, yPos, 1,1,1,0.5, UIFont.Small);
	self.bodyHairButton:setVisible(true);
	self.bodyHairButton:setX(buttonsX);
	self.bodyHairButton:setY(yPos);
	self.bodyHairButton.enable = true;
	self.bodyHairButton.tooltip = nil;
	if summary == getText("UI_rasBodyMod_None") then
	   self.bodyHairButton.enable = false;
	   self.bodyHairButton.tooltip = getText("UI_rasBodyMod_NoBodyHair");
	end
	
	yPos = yPos + BUTTON_HGT + UI_BORDER_SPACING
		
	self.literatureButton:setY(yPos - ((BUTTON_HGT - FONT_HGT_SMALL)/ 2)) -- change position of "literature" button a bit so that we have enough space for the body-hair-shaving option


    -- next lines of code make the "change beard" option available if player has stubbles but no other beard
    if (not self.char:isFemale()) then
        local currentBeard = getBeardStylesInstance():FindStyle(self.char:getHumanVisual():getBeardModel())
        local data = self.char:getModData().RasBodyMod
        if data and data.BeardStubble == 1 and (currentBeard == nil or currentBeard:getLevel() <= 0) then
              self.beardButton.enable = true
              self.beardButton.tooltip = nil
        end
    end

    if windowHeight then
       self:setHeightAndParentHeight(windowHeight + BUTTON_HGT + UI_BORDER_SPACING)
    end
end

-- in case the "drawText" functions are called by the render() function from above, we manipulate the positions of the text a bit to ensure
-- we have enough space for the shave-body-hair ui
local vanilla_drawText = ISUIElement.drawText
function ISUIElement:drawText(str, x, y, r, g, b, a, font, ...)

      if calledByRender then
           if str == self.favouriteWeapon or (self.char and (str == self.char:getZombieKills() .. "" or str == self.char:getTimeSurvived()) ) then
                 y = y + BUTTON_HGT + UI_BORDER_SPACING
                 windowHeight = y
           end
      end  
 
      vanilla_drawText(self, str, x, y, r, g, b, a, font, ...)
end

vanilla_drawTextRight = ISUIElement.drawTextRight
function ISUIElement:drawTextRight(str, x, y, r, g, b, a, font, ...)

       if calledByRender then
             if str == getText("IGUI_char_Favourite_Weapon") or str == getText("IGUI_char_Zombies_Killed") or str == getText("IGUI_char_Survived_For") then
                  y = y + BUTTON_HGT + UI_BORDER_SPACING
                  windowHeight = y
             end
       end 

       vanilla_drawTextRight(self, str, x, y, r, g, b, a, font, ...)
end


-- define the "Change" button for body hair
local vanilla_create = ISCharacterScreen.create
function ISCharacterScreen:create(...)
        
    vanilla_create(self,...) -- execute vanilla code
		
	-- define ui elements for body hair shaving
	local btnWid = 70
	local btnHgt = FONT_HGT_SMALL
    self.bodyHairButton = ISButton:new(0,0, btnWid, btnHgt, getText("IGUI_PlayerStats_Change"), self, bodyHairMenu);
	self.bodyHairButton:initialise();
	self.bodyHairButton:instantiate();
	self.bodyHairButton.borderColor = {r=1, g=1, b=1, a=0.1};
	self.bodyHairButton:setVisible(false);
	self:addChild(self.bodyHairButton);
	
	-- move the avatar a bit to the left for more space	
	self.avatarPanel:setX(20)
	self.avatarX = 20	 
	
	-- adjust the xOffset position to the new body hair text element
	local textWid = 0
	textWid = self:maxTextWidth(UIFont.Small, getText("IGUI_char_Age"), textWid)
	textWid = self:maxTextWidth(UIFont.Small, getText("IGUI_char_Sex"), textWid)
	textWid = self:maxTextWidth(UIFont.Small, getText("IGUI_char_Weight"), textWid)
	textWid = self:maxTextWidth(UIFont.Small, getText("IGUI_char_Traits"), textWid)
	textWid = self:maxTextWidth(UIFont.Small, getText("IGUI_char_HairStyle"), textWid)
	textWid = self:maxTextWidth(UIFont.Small, getText("IGUI_char_BeardStyle"), textWid)
	textWid = self:maxTextWidth(UIFont.Small, getText("UI_rasBodyMod_BodyHair"), textWid)
	self.xOffset = self.avatarX + self.avatarWidth + 25 + textWid	

end



------- next functions modify beard shaving options; player can choose between scissors and razor; razor will also remove stubble; scissors will not remove stubble


-- custom "onTrimBeard" function; we bypass the vanilla function since it does not allow us to choose between razor and scissors
local function onTrimBeard(player, beardStyle, tool)
      ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), tool, true)
	  ISTimedActionQueue.add(ISTrimBeard:new(player, beardStyle, tool, 300))
end

-- when player chooses to shave stubble
local function onShaveStubble(player, razor)
      ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), razor, true)
      ISTimedActionQueue.add(RasBodyModShaveStubbleAction:new(player, razor))
end


local CALLED_BY_BEARD_MENU = false
local BEARD_MENU_SELF = nil

-- modifies a function from vanilla client/ISUI/ISContextMenu.lua
local vanilla_addOption = ISContextMenu.addOption
function ISContextMenu.addOption(self, name, target, onSelect, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, ...)

     if CALLED_BY_BEARD_MENU then -- only true when addOption() is called by ISCharacterScreen.beardMenu() (see below)
            local player = target
            local scissors = searchScissors(player) 
            local razor = searchRazor(player)

            if BEARD_MENU_SELF then -- create option for shaving stubbles
                    local data = player:getModData().RasBodyMod
                    local currentBeard = getBeardStylesInstance():FindStyle(player:getHumanVisual():getBeardModel())
                    local beardID = nil
                    if currentBeard then
                          beardID = currentBeard:getName()
                    end
                    if data.BeardStubble == 1 and (not rasSharedData.FullBeards[beardID]) then
                        local stubbleOption = vanilla_addOption(self, getText("UI_rasBodyMod_ShaveStubble"), player, onShaveStubble, razor) -- add option for shaving stubbles
                        if razor == nil then
                            BEARD_MENU_SELF:addTooltip(stubbleOption, getText("UI_rasBodyMod_RequireRazor"))
                        end
                    end
                    BEARD_MENU_SELF = nil
            end
            
            if scissors and razor then -- create option for choosing between razor or scissors when shaving beard
                   local option = vanilla_addOption(self, name, target, nil, param1)
                   local subMenu = self:getNew(self)
                   self:addSubMenu(option, subMenu)                    
                   vanilla_addOption(subMenu, getText("UI_rasBodyMod_UseScissors"), player, onTrimBeard, param1, scissors)
                   vanilla_addOption(subMenu, getText("UI_rasBodyMod_UseRazor"), player, onTrimBeard, param1, razor)
                   return option 
            end
     end
     
     return vanilla_addOption(self, name, target, onSelect, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, ...) -- execute vanilla code       
end


local vanilla_beardMenu = ISCharacterScreen.beardMenu
function ISCharacterScreen.beardMenu(self, button, ...)

     BEARD_MENU_SELF = self
     CALLED_BY_BEARD_MENU = true

     vanilla_beardMenu(self, button, ...) -- execute vanilla code

     CALLED_BY_BEARD_MENU = false
     
     local currentBeard = getBeardStylesInstance():FindStyle(self.char:getHumanVisual():getBeardModel())
     if (not isDebugEnabled()) and (currentBeard == nil or currentBeard:getLevel() <= 0) then -- in this case, shaving options are not created by beardMenu() so we create them here
          local data = self.char:getModData().RasBodyMod          
          if data.BeardStubble == 1 then 
                local context = ISContextMenu.get(self.char:getPlayerNum(), button:getAbsoluteX(), button:getAbsoluteY() + button:getHeight())
                local razor = searchRazor(self.char)
                local option = context:addOption(getText("UI_rasBodyMod_ShaveStubble"), self.char, onShaveStubble, razor)
                if razor == nil then
                      self:addTooltip(option, getText("UI_rasBodyMod_RequireRazor"))
                end
          end
     end
end






-- this is used to make sure the avatar in character screen always shows the default male-private-model (and not e.g. the sitting model which would result in
-- glitchy visuals); to do this, we briefly equip the default model before the update and revert to the actual model afterwards
local vanilla_updateAvatar = ISCharacterScreen.updateAvatar
function ISCharacterScreen:updateAvatar(...) 

	local player = self.char
	local data = player:getModData().RasBodyMod
    if isClient() then -- in MP, we need a specical logic since in specific cases, we can only properly equip items on server
        if data then -- in MP, modData may not yet have been written to player when game starts (can only happen during the first few ticks)

            if player:getInventoryWeight() >= player:getInventory():getCapacity() then -- in this case, we need to equip the default model on server to catch a problem related to inventory weight limit

	            local myCondition = self.refreshNeeded and (not player:isFemale()) and data.PlayerMode ~= "default"		        
                local mode_BackUp = data.PlayerMode
                if myCondition then

                    local function onHackAvatar(mod, command, args)
                        if mod == "rasBodyMod" and command == "hackAvatar" then

                            Events.OnServerCommand.Remove(onHackAvatar) -- remove event

                            vanilla_updateAvatar(self) -- execute vanilla code (and thereby update the avatar with the default male private model)

                            data.PlayerMode = mode_BackUp
                            local queue = { 
                                {functionName = "ManageMalePrivatePart", args = {}}, 
                                {functionName = "TransferDirtToSkin", args = {}} -- vanilla game sometimes removes dirt visuals from body when clothing items are (un-)equipped (??); this command fixes it
                            }
                            manageBody.executeQueue(player, queue, false) -- re-equip the actual model (on server)
                        end    
                    end

                    Events.OnServerCommand.Add(onHackAvatar) -- add the vanilla update function to the event so we can trigger it after server has equipped the default model

                    data.PlayerMode = "default"
                    local queue = { 
                        {functionName = "ManageMalePrivatePart", args = {}}, 
                        {functionName = "TransferDirtToSkin", args = {}} -- vanilla game sometimes removes dirt visuals from body when clothing items are (un-)equipped (??); this command fixes it
                    }
                    manageBody.executeQueueAndHackAvatar(player, queue) -- equip default model (on server)
                else
                    vanilla_updateAvatar(self, ...) -- execute vanilla code
                end
            else -- this case is simpler: we just equip on client which is sufficient since we are only tweaking the client-side UI

                local myCondition = self.refreshNeeded and (not player:isFemale()) and data.PlayerMode ~= "default"		        
                local mode_BackUp = data.PlayerMode
                if myCondition then    
                    data.PlayerMode = "default"
                    local queue = { {functionName = "ManageMalePrivatePart", args = {}} } 
                    manageBody.executeQueueOnClient(player, queue) -- equip default model (but on client)

                    vanilla_updateAvatar(self,...) -- execute vanilla code (and thereby update the avatar with the default model) 

                    data.PlayerMode = mode_BackUp
                    local queue = { {functionName = "ManageMalePrivatePart", args = {}} } 
                    manageBody.executeQueueOnClient(player, queue) -- re-equip actual model (on client)      
                else
                    vanilla_updateAvatar(self,...) -- execute vanilla code
                end
            end
        else
            vanilla_updateAvatar(self, ...) -- execute vanilla code
        end
    else -- simplified logic when in SP
        local myCondition = self.refreshNeeded and (not player:isFemale()) and data.PlayerMode ~= "default"		        
        local mode_BackUp = data.PlayerMode

        if myCondition then
            data.PlayerMode = "default"
            local queue = { {functionName = "ManageMalePrivatePart", args = {}} } 
            manageBody.executeQueue(player, queue, false) -- equip default model

            vanilla_updateAvatar(self,...) -- execute vanilla code (and thereby update the avatar with the default model)
        
            data.PlayerMode = mode_BackUp
            local queue = { {functionName = "ManageMalePrivatePart", args = {}} } 
            manageBody.executeQueue(player, queue, false) -- re-equip old model
        else
            vanilla_updateAvatar(self,...) -- execute vanilla code
        end
    end	
end





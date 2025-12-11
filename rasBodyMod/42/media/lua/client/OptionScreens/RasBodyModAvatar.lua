-- make the 3d character model in the character customisation screen appear a bit larger
--
--
-- by razab


local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_TITLE = getTextManager():getFontHeight(UIFont.Title)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6


local vanilla_setFacePreview =  CharacterCreationAvatar.setFacePreview
function CharacterCreationAvatar:setFacePreview(val, ...)
	
    vanilla_setFacePreview(self, val, ...)

    if not val then
       self.avatarPanel:setZoom(-0.8) -- 42.5 value=1, 42.6 value=-3
       self.avatarPanel:setYOffset(0)
	end
end






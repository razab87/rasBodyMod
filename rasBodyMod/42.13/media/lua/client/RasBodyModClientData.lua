-- some data used by client code; it will store all infos about the skin/body hair which the player chooses during character creation (see this mod OptionScreens folder); data will be written in player's modData
-- when game starts (cf. RasBodyModCreatePlayer.lua
--
--
-- by razab



local rasClientData = {} -- can be accessed via "require(RasBodyModClientData)" by other client files
local Regs = RasBodyModRegistries


-- the next table tells us what body hair/skin/stubble the character has from character customisation
rasClientData.SelectedBodyHair = {
                   Male = { [Regs.ChestHair] = "None",
                            [Regs.ArmpitHair] = "None",
                            [Regs.PubicHair] =  "None",
                            [Regs.LegHair] = "None",
                   },
                   Female = { [Regs.ArmpitHair] = "None",
                              [Regs.PubicHair] = "None",
                              [Regs.LegHair] = "None",
                   },
}

rasClientData.SkinColorIndex = 1 -- store the skin color index: 1 = lightest, 5 = darkest

rasClientData.BeardStubble = 0 -- store whether character has beard stubble (0=no beard, 1=beard)
rasClientData.HeadStubble = 0  -- stores whether character has stubbles on head



return rasClientData
















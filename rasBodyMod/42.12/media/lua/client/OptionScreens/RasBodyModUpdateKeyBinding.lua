-- here we make sure that some of the local variables in RasBodyModManageSneaking.lua and RasBodyModManageTurnAround.lua have their correct values in case player changes key bindings during game; modifies a function from 
-- vanilla client/OptionScreens/MainOptions.lua
--
--
-- by razab




local manageTurnAround = require("ManageBodyClient/RasBodyModManageTurnAround")


local vanilla_onOptionMouseDown = MainOptions.onOptionMouseDown
function MainOptions.onOptionMouseDown(self, button, x, y, ...)

          vanilla_onOptionMouseDown(self, button, x, y, ...) -- execute vanilla code

          if button.internal == "ACCEPT" or button.internal == "SAVE" then -- if those buttons have been pressed, key bindings might have changed
                  manageTurnAround.UpdateLocals()          
          end 
end

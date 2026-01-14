-- here we set up the razor so that it can be used 20 times only
--
--
-- by razab




local function changeRazors()

  local name = "Base.Razor"
  local item = ScriptManager.instance:getItem(name)

  if item then
     item:DoParam("Type = Drainable")
     item:DoParam("UseDelta = 0.05")
     item:DoParam("UseWhileEquipped = FALSE")
     item:DoParam("cantBeConsolided = TRUE")
  end
end


	

Events.OnGameBoot.Add(changeRazors)
	
	

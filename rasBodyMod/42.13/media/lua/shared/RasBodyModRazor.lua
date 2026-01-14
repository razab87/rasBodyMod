-- here we set up the razor so that it can be used 20 times only
--
--
-- by razab




local function changeRazors()

  local item = ScriptManager.instance:getItem("Base.Razor")
  if item then
     item:DoParam("ItemType = base:drainable")
     item:DoParam("UseDelta = 0.05")
     item:DoParam("UseWhileEquipped = FALSE")
     item:DoParam("cantBeConsolided = TRUE")
  end

  item = ScriptManager.instance:getItem("Base.StraightRazor") 
  if item then
     item:DoParam("ItemType = base:drainable")
     item:DoParam("UseDelta = 0.03125")
     item:DoParam("UseWhileEquipped = FALSE")
     item:DoParam("cantBeConsolided = TRUE")
  end

end


	

Events.OnGameBoot.Add(changeRazors)
	
	

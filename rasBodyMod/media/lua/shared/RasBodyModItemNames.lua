-- make sure the glitch-fix clothing items have the same display name as the corresponding vanilla items (also applies to translations)
--
--
-- by razab




local item = ScriptManager.instance:getItem("RasBodyMod.Vest_BulletArmy_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_BulletArmy"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_BulletCivilian_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_BulletCivilian"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_BulletPolice_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_BulletPolice"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_HighViz_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_HighViz"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Hunting_Grey_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Hunting_Grey"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Hunting_Orange_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Hunting_Orange"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Hunting_Camo_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Hunting_Camo"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Hunting_CamoGreen_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Hunting_CamoGreen"))
end













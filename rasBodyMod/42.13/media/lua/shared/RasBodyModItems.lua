-- make sure the glitch-fix clothing items have the same display name as the corresponding vanilla items (also applies to translations);also change bodyLocations of bandeaus and crop tops to Tshirt so that they can be worn -- 
-- together with underwear top and tank top items (vanilla has them under UnderwearTop but lists them under Tshirt in character creation leading to inconsistencies)
--
--
-- by razab



-- names for the glitch-fix vests (in the recent mod version, not sure if necessary to give them names here but it won't matter either)
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

item = ScriptManager.instance:getItem("RasBodyMod.Vest_BulletSWAT_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_BulletSWAT"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_BulletDesert_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_BulletDesert"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_BulletDesertNew_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_BulletDesertNew"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_BulletOliveDrab_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_BulletOliveDrab"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_HighViz_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_HighViz"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Hunting_Grey_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Hunting_Grey"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Trucker_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Trucker"))
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

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Hunting_Khaki_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Hunting_Khaki"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Leather_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Leather"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Leather_Biker_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Leather_Biker"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Leather_Veteran_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Leather_Veteran"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Leather_BarrelDogs_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Leather_BarrelDogs"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Leather_IronRodents_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Leather_IronRodents"))
end

item = ScriptManager.instance:getItem("RasBodyMod.Vest_Leather_WildRaccoons_RasBM")
if item then
  item:setDisplayName(getItemNameFromFullType("Base.Vest_Leather_WildRaccoons"))
end


-- new body locations for some vanilla clothing
item = ScriptManager.instance:getItem("Base.BoobTube")
if item then
    item:DoParam("BodyLocation = base:tshirt")
end

item = ScriptManager.instance:getItem("Base.BoobTubeSmall")
if item then
    item:DoParam("BodyLocation = base:tshirt")
end

item = ScriptManager.instance:getItem("Base.Shirt_CropTopTINT")
if item then
    item:DoParam("BodyLocation = base:tshirt")
end

item = ScriptManager.instance:getItem("Base.Shirt_CropTopNoArmTINT")
if item then
    item:DoParam("BodyLocation = base:tshirt")
end







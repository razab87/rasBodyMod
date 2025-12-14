-- this file contains several data used by the mod
--
--
-- by razab



local rasSharedData = {}  -- can be accessed via require("RasBodyModSharedData") in other .lua files



-- body hair locations
rasSharedData.BodyHairLocations = {}
rasSharedData.BodyHairLocations["RasChestHair"] = true
rasSharedData.BodyHairLocations["RasArmpitHair"] = true 
rasSharedData.BodyHairLocations["RasPubicHair"] = true 
rasSharedData.BodyHairLocations["RasLegHair"] = true 

-- note: RasSkin, RasMalePrivatePart, RasBeardStubble, RasHeadStubble are also new body locations introduced by the mod which should not be treated as if they were locations
-- for clothing items



-- character skins; ordered according to skin color index
rasSharedData.Skins = {}
rasSharedData.Skins.Female = {"RasBodyMod.SkinFemale01", "RasBodyMod.SkinFemale02", "RasBodyMod.SkinFemale03", "RasBodyMod.SkinFemale04", "RasBodyMod.SkinFemale05"}
rasSharedData.Skins.Male = {"RasBodyMod.SkinMale01", "RasBodyMod.SkinMale02", "RasBodyMod.SkinMale03", "RasBodyMod.SkinMale04", "RasBodyMod.SkinMale05"}


-- skin colors as shown in the skin selection menu during character customization; ordering according to rasSharedData.Skins table
rasSharedData.SkinColors = {{r=1.0,g=0.84,b=0.76}, {r=0.86,g=0.71,b=0.57}, {r=0.72,g=0.57,b=0.43}, {r=0.54,g=0.38,b=0.25}, {r=0.36,g=0.25,b=0.14}}




-- stores the different penis types for each skin
rasSharedData.PenisTable = {}
rasSharedData.PenisTable[1] = { default = "RasBodyMod.PenisDefault01", sit = "RasBodyMod.PenisSitting01", situps =  "RasBodyMod.PenisSitting01", 
                                                   turn =  "RasBodyMod.PenisTurnAround01", cover = "RasBodyMod.PenisCover01", coverWalk = "RasBodyMod.PenisCoverWalk01"}

rasSharedData.PenisTable[2] = { default = "RasBodyMod.PenisDefault02", sit = "RasBodyMod.PenisSitting02", situps =  "RasBodyMod.PenisSitting02", 
                                                   turn =  "RasBodyMod.PenisTurnAround02", cover = "RasBodyMod.PenisCover02", coverWalk = "RasBodyMod.PenisCoverWalk02"}

rasSharedData.PenisTable[3] = { default = "RasBodyMod.PenisDefault03", sit = "RasBodyMod.PenisSitting03", situps =  "RasBodyMod.PenisSitting03", 
                                                   turn =  "RasBodyMod.PenisTurnAround03", cover = "RasBodyMod.PenisCover03", coverWalk = "RasBodyMod.PenisCoverWalk03"}

rasSharedData.PenisTable[4] = { default = "RasBodyMod.PenisDefault04", sit = "RasBodyMod.PenisSitting04", situps =  "RasBodyMod.PenisSitting04", 
                                                   turn =  "RasBodyMod.PenisTurnAround04", cover = "RasBodyMod.PenisCover04", coverWalk = "RasBodyMod.PenisCoverWalk04"}

rasSharedData.PenisTable[5] = { default = "RasBodyMod.PenisDefault05", sit = "RasBodyMod.PenisSitting05", situps =  "RasBodyMod.PenisSitting05", 
                                                   turn =  "RasBodyMod.PenisTurnAround05", cover = "RasBodyMod.PenisCover05", coverWalk = "RasBodyMod.PenisCoverWalk05"}






 -- here we store correct display names for body hair styles; they shouldn't be shown in player's inventory and we therefore don't give them a displayName in the scripts
rasSharedData.CorrectName = {} 
rasSharedData.CorrectName["RasBodyMod.MaleChest"] = getText("UI_rasBodyMod_Natural")
rasSharedData.CorrectName["RasBodyMod.MaleArmpit"] = getText("UI_rasBodyMod_Natural")
rasSharedData.CorrectName["RasBodyMod.MalePubicNatural"] = getText("UI_rasBodyMod_Natural")
rasSharedData.CorrectName["RasBodyMod.MalePubicStrip"] = getText("UI_rasBodyMod_Strip")
rasSharedData.CorrectName["RasBodyMod.MalePubicTrimmed"] = getText("UI_rasBodyMod_Trimmed")
rasSharedData.CorrectName["RasBodyMod.MaleLeg"] = getText("UI_rasBodyMod_Natural")

rasSharedData.CorrectName["RasBodyMod.FemaleArmpit"] = getText("UI_rasBodyMod_Natural")
rasSharedData.CorrectName["RasBodyMod.FemalePubicNatural"] = getText("UI_rasBodyMod_Natural")
rasSharedData.CorrectName["RasBodyMod.FemalePubicStrip"] = getText("UI_rasBodyMod_Strip")
rasSharedData.CorrectName["RasBodyMod.FemalePubicTrimmed"] = getText("UI_rasBodyMod_Trimmed")
rasSharedData.CorrectName["RasBodyMod.FemaleLeg"] = getText("UI_rasBodyMod_Natural")

rasSharedData.CorrectName["RasBodyMod.FemaleArmpit_Int"] = "armpit_Int"
rasSharedData.CorrectName["RasBodyMod.FemalePubicNatural_Int"] = "pubic_Int"
rasSharedData.CorrectName["RasBodyMod.FemaleLeg_Int"] = "leg_Int"

rasSharedData.CorrectName["RasBodyMod.MaleArmpit_Int"] = "armpit_Int"
rasSharedData.CorrectName["RasBodyMod.MalePubicNatural_Int"] = "pubic_Int"
rasSharedData.CorrectName["RasBodyMod.MaleLeg_Int"] = "leg_Int"
rasSharedData.CorrectName["RasBodyMod.MaleChest_Int"] = "chest_Int"



-- some skin colors receive a slightly different hair item for better visuals; [4]=skin color index, "Black2" = postfix for item name optimized for the skin color
rasSharedData.OptimizedBodyHair = { Female = { [4] = "Black2", [5] = "Black2" },
                                    Male = {}
                                  }


-- table for body hair definitions; are used to popupalte the body hair comboboxes in Character Creation Screen
rasSharedData.BodyHairDefinitions = {

	Female = {		
		RasArmpitHair = {
		       items = {"RasBodyMod.FemaleArmpit"},
		},
		RasPubicHair = { 
		       items = {"RasBodyMod.FemalePubicStrip", "RasBodyMod.FemalePubicTrimmed", "RasBodyMod.FemalePubicNatural"},
		},
		RasLegHair = {
		       items = {"RasBodyMod.FemaleLeg"},
		},
	},
	
	Male = {
		RasChestHair = {
		       items = {"RasBodyMod.MaleChest"},
		},
		RasArmpitHair = {
		       items = {"RasBodyMod.MaleArmpit"},
		},
		RasPubicHair = { 
		       items = {"RasBodyMod.MalePubicStrip", "RasBodyMod.MalePubicNatural"},
		},
		RasLegHair = {
		       items = {"RasBodyMod.MaleLeg"},
		},            		
	}
}




-- shaving options for body hair types; shaving to "none" is always present by default and must not be included here
rasSharedData.ShaveTable = {}

rasSharedData.ShaveTable.Female = {}
rasSharedData["ShaveTable"]["Female"]["RasBodyMod.FemalePubicNatural"] = { {canBeShavedTo = "RasBodyMod.FemalePubicTrimmed", optionText= getText("UI_rasBodyMod_PubicTrim")},
                                                                        {canBeShavedTo = "RasBodyMod.FemalePubicStrip", optionText = getText("UI_rasBodyMod_PubicShaveStrip")} }

rasSharedData["ShaveTable"]["Female"]["RasBodyMod.FemalePubicNatural_Int"] = { {canBeShavedTo = "RasBodyMod.FemalePubicTrimmed", optionText = getText("UI_rasBodyMod_PubicTrim")},
                                                                            {canBeShavedTo = "RasBodyMod.FemalePubicStrip", optionText = getText("UI_rasBodyMod_PubicShaveStrip")} }

rasSharedData["ShaveTable"]["Female"]["RasBodyMod.FemalePubicTrimmed"] = { {canBeShavedTo = "RasBodyMod.FemalePubicStrip", optionText = getText("UI_rasBodyMod_PubicShaveStrip")} }


rasSharedData.ShaveTable.Male = {}
rasSharedData["ShaveTable"]["Male"]["RasBodyMod.MalePubicNatural"] = { {canBeShavedTo = "RasBodyMod.MalePubicStrip", optionText = getText("UI_rasBodyMod_PubicShaveStrip")} }

rasSharedData["ShaveTable"]["Male"]["RasBodyMod.MalePubicNatural_Int"] = { {canBeShavedTo = "RasBodyMod.MalePubicStrip", optionText = getText("UI_rasBodyMod_PubicShaveStrip")} }
rasSharedData["ShaveTable"]["Male"]["RasBodyMod.MalePubicStrip_Int"] = { {canBeShavedTo = "RasBodyMod.MalePubicStrip", optionText = getText("UI_rasBodyMod_PubicShaveStrip")} }





-- some data required to fix a graphic glich related to bullet proof vests and similar clothing items; those items will cause a graphic glitch related to the body hair items when the groin area is
-- visible; in this case, we exchange the (visual of the) vest with an identically looking vest having a different configuration which makes the glitch disappear
rasSharedData.TorsoLocations = {"Pants", "UnderwearBottom", "Skirt", "Torso1", "Torso1Legs1", "TankTop", "Tshirt", "ShortSleeveShirt", "Shirt", "Dress", "Sweater", "SweaterHat", "Jacket", "Jacket_Down", 
                                "Jacket_Bulky", "JacketHat", "JacketHat_Bulky", "JacketSuit", "Boilersuit", "FullSuitHead"
                               }

rasSharedData.TorsoLocationsException = {}
rasSharedData.TorsoLocationsException["Base.BoobTube"] = true 
rasSharedData.TorsoLocationsException["Base.BoobTubeSmall"] = true
rasSharedData.TorsoLocationsException["Base.Shirt_CropTopTINT"] = true 
rasSharedData.TorsoLocationsException["Base.Shirt_CropTopNoArmTINT"] = true

rasSharedData.GlitchedItems = {}
rasSharedData.GlitchedItems["Base.Vest_BulletArmy"] = "RasBodyMod.Vest_BulletArmy_RasBM"
rasSharedData.GlitchedItems["Base.Vest_BulletCivilian"] = "RasBodyMod.Vest_BulletCivilian_RasBM"
rasSharedData.GlitchedItems["Base.Vest_BulletPolice"] = "RasBodyMod.Vest_BulletPolice_RasBM"
rasSharedData.GlitchedItems["Base.Vest_HighViz"] = "RasBodyMod.Vest_HighViz_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Hunting_Grey"] = "RasBodyMod.Vest_Hunting_Grey_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Hunting_Orange"] = "RasBodyMod.Vest_Hunting_Orange_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Hunting_Camo"] = "RasBodyMod.Vest_Hunting_Camo_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Hunting_CamoGreen"] = "RasBodyMod.Vest_Hunting_CamoGreen_RasBM"

rasSharedData.GlitchedItemsReverse = {}
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_BulletArmy_RasBM"] = "Base.Vest_BulletArmy"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_BulletCivilian_RasBM"] = "Base.Vest_BulletCivilian"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_BulletPolice_RasBM"] = "Base.Vest_BulletPolice"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_HighViz_RasBM"] = "Base.Vest_HighViz"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Hunting_Grey_RasBM"] = "Base.Vest_Hunting_Grey"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Hunting_Orange_RasBM"] = "Base.Vest_Hunting_Orange"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Hunting_Camo_RasBM"] = "Base.Vest_Hunting_Camo"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Hunting_CamoGreen_RasBM"] = "Base.Vest_Hunting_CamoGreen"








-- store all full beards; used for managing beard stubble for male characters
rasSharedData.FullBeards = {}
rasSharedData.FullBeards["Full"] = true
rasSharedData.FullBeards["Long"] = true
rasSharedData.FullBeards["LongScruffy"] = true

     




-- next table ExceptionalClothes will contain "exceptional clothes": these are clothing items which must be treated manually to hide the penis model when equipped; they cannot be managed via the vanilla "setHideModel" 
-- function since they belong to a body location where some clothing items should hide the penis while others should not

rasSharedData.ExceptionalClothes = {}

rasSharedData.ExceptionalClothes["UnderwearExtra1"] = {}  -- UnderwearExtra1 location
rasSharedData.ExceptionalClothes["UnderwearExtra1"]["Base.TightsBlack"] = { hideWhileStanding = true, hideWhileSitting = true }   
rasSharedData.ExceptionalClothes["UnderwearExtra1"]["Base.TightsBlackTrans"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["UnderwearExtra1"]["Base.TightsBlackSemiTrans"] = { hideWhileStanding = true, hideWhileSitting = true } 

rasSharedData.ExceptionalClothes["Skirt"] = {}  -- Skirt location
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Knees"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Mini"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Long"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Normal"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Short"] = { hideWhileStanding = true, hideWhileSitting = false } 

rasSharedData.ExceptionalClothes["Dress"] = {} -- Dress location 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_Knees"] = { hideWhileStanding = true, hideWhileSitting = false }   
rasSharedData.ExceptionalClothes["Dress"]["Base.DressKnees_Straps"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SmallBlackStrapless"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SmallBlackStraps"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SmallStrapless"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SmallStraps"] = { hideWhileStanding = true, hideWhileSitting = false }  
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SatinNegligee"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_Long"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_long_Straps"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_Normal"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_Straps"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_Short"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.HospitalGown"] = { hideWhileStanding = true, hideWhileSitting = false } 

rasSharedData.ExceptionalClothes["Jacket"] = {} -- Jacket location
rasSharedData.ExceptionalClothes["Jacket"]["Base.JacketLong_SantaGreen"] = { hideWhileStanding = true, hideWhileSitting = true }   
rasSharedData.ExceptionalClothes["Jacket"]["Base.JacketLong_Random"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["Jacket"]["Base.JacketLong_Doctor"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["Jacket"]["Base.PonchoGreenDOWN"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["Jacket"]["Base.PonchoYellowDOWN"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["Jacket"]["Base.JacketLong_Santa"] = { hideWhileStanding = true, hideWhileSitting = true } 

rasSharedData.ExceptionalClothes["JacketHat"] = {} -- JacketHat location
rasSharedData.ExceptionalClothes["JacketHat"]["Base.PonchoGreen"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["JacketHat"]["Base.PonchoYellow"] = { hideWhileStanding = true, hideWhileSitting = true } 

rasSharedData.ExceptionalClothes["FullTop"] = {} -- FullTop location
rasSharedData.ExceptionalClothes["FullTop"]["Base.Ghillie_Top"] = { hideWhileStanding = true, hideWhileSitting = false }  

rasSharedData.ExceptionalClothes["TorsoExtra"] = {} -- TorsoExtra location
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_Black"] = { hideWhileStanding = true, hideWhileSitting = false }  
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_White"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_IceCream"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_Jay"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_PileOCrepe"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_PizzaWhirled"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_Spiffos"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_WhiteTEXTURE"] = { hideWhileStanding = true, hideWhileSitting = false } 






-- next table contains body locations which the player should automatically undress when shaving body hair; example structre:
--
--   UndressTable.Pubic = { {bodyLocation1 = {exceptions = myTable}}, {bodyLocation2 = {exceptions = {} }}, ... }
--
-- this tells the game that when shaving pubic hair, the body location "bodyLocation1" should be fully undressed except when clothing item belongs to the set table "myTable" (i.e. "myTable["RasBodyMod.Item"]=true"); also undress
-- everything from body location "BodyLocation2" without exceptions and so on (exception = {} means there are no exception -> undress everything)

rasSharedData.UndressLocation = {}
rasSharedData.UndressLocation.Pubic = {}
rasSharedData.UndressLocation.Chest = {}
rasSharedData.UndressLocation.Legs = {}


local function makeUndressLocation(bodyPartToShave, bodyLocation, exceptionItems)
             
             rasSharedData.UndressLocation[bodyPartToShave][bodyLocation] = {} 
             rasSharedData.UndressLocation[bodyPartToShave][bodyLocation]["exceptions"] = {}
             for _,item in pairs(exceptionItems) do
                 rasSharedData.UndressLocation[bodyPartToShave][bodyLocation]["exceptions"][item] = true
             end
end

-- write the "undress locations" in the above tables:

-- when shaving pubic hair
makeUndressLocation("Pubic", "TorsoExtra", {}) -- table at the end is a list of possible exceptions (empty means undress everything without exception from the location)
makeUndressLocation("Pubic", "Jacket", {})
makeUndressLocation("Pubic", "JacketHat", {})
makeUndressLocation("Pubic", "JacketSuit", {})
makeUndressLocation("Pubic", "Jacket_Down", {})
makeUndressLocation("Pubic", "Jacket_Bulky", {})
makeUndressLocation("Pubic", "JacketHat_Bulky", {})
makeUndressLocation("Pubic", "Sweater", {})
makeUndressLocation("Pubic", "SweaterHat", {})
makeUndressLocation("Pubic", "FullSuit", {})
makeUndressLocation("Pubic", "FullSuitHead", {})
makeUndressLocation("Pubic", "FullTop", {})
makeUndressLocation("Pubic", "BathRobe", {})
makeUndressLocation("Pubic", "FannyPackFront", {})
makeUndressLocation("Pubic", "Shirt", {})
makeUndressLocation("Pubic", "ShortSleeveShirt", {})
makeUndressLocation("Pubic", "Tshirt", {"Base.BoobTube","Base.BoobTubeSmall", "Base.Shirt_CropTopTINT", "Base.Shirt_CropTopNoArmTINT"})
makeUndressLocation("Pubic", "Dress", {})
makeUndressLocation("Pubic", "TankTop", {})
makeUndressLocation("Pubic", "Skirt", {})
makeUndressLocation("Pubic", "Pants", {})
makeUndressLocation("Pubic", "Torso1Legs1", {})
makeUndressLocation("Pubic", "Legs1", {})
makeUndressLocation("Pubic", "Underwear", {})
makeUndressLocation("Pubic", "UnderwearExtra1", {"Base.StockingsBlack", "Base.StockingsBlackTrans", "Base.StockingsBlackSemiTrans", "Base.StockingsWhite"})
makeUndressLocation("Pubic", "UnderwearBottom", {})


-- when shaving chest and armpits
makeUndressLocation("Chest", "AmmoStrap", {})                 -- chest also used for armpits, TODO: maybe make a separate one for armpits??
makeUndressLocation("Chest", "Scarf", {})                     -- note: backpacks are dropped to ground when shaving chest, so don't include them here
makeUndressLocation("Chest", "TorsoExtra", {})
makeUndressLocation("Chest", "TorsoExtraVest", {})
makeUndressLocation("Chest", "Jacket", {})
makeUndressLocation("Chest", "JacketHat", {})
makeUndressLocation("Chest", "JacketSuit", {})
makeUndressLocation("Chest", "Jacket_Bulky", {})
makeUndressLocation("Chest", "JacketHat_Bulky", {})
makeUndressLocation("Chest", "Jacket_Down", {})
makeUndressLocation("Chest", "Sweater", {})
makeUndressLocation("Chest", "SweaterHat", {})
makeUndressLocation("Chest", "FullSuit", {})
makeUndressLocation("Chest", "FullSuitHead", {})
makeUndressLocation("Chest", "FullTop", {})
makeUndressLocation("Chest", "BathRobe", {})
makeUndressLocation("Chest", "FannyPackFront", {})
makeUndressLocation("Chest", "FannyPackBack", {})
makeUndressLocation("Chest", "Shirt", {})
makeUndressLocation("Chest", "ShortSleeveShirt", {})
makeUndressLocation("Chest", "Tshirt", {})
makeUndressLocation("Chest", "Dress", {})
makeUndressLocation("Chest", "TankTop", {})
makeUndressLocation("Chest", "Torso1Legs1", {})
makeUndressLocation("Chest", "Underwear", {"Base.SwimTrunks_Blue", "Base.SwimTrunks_Green", "Base.SwimTrunks_Red", "Base.SwimTrunks_Yellow"})
makeUndressLocation("Chest", "UnderwearTop", {})
              

-- when shaving legs
makeUndressLocation("Legs", "TorsoExtra", {"Base.Vest_Waistcoat", "Base.Vest_WaistcoatTINT", "Base.Vest_Waistcoat_GigaMart"})
makeUndressLocation("Legs", "Shoes", {})
makeUndressLocation("Legs", "BathRobe", {})
makeUndressLocation("Legs", "FullSuit", {})
makeUndressLocation("Legs", "FullSuitHead", {})
makeUndressLocation("Legs", "Dress", {})
makeUndressLocation("Legs", "Skirt", {})
makeUndressLocation("Legs", "Pants", {})
makeUndressLocation("Legs", "Torso1Legs1", {})
makeUndressLocation("Legs", "Legs1", {})
makeUndressLocation("Legs", "Socks", {})
makeUndressLocation("Legs", "UnderwearExtra1", {})
makeUndressLocation("Legs", "Jacket_Down", {})
makeUndressLocation("Legs", "JacketHat", {})
              



-- next tables are alternatives for undressing clothes when shaving; they contain single items which should be undressed and belong to a body location not treated above

rasSharedData.UndressSpecificItems = {}
rasSharedData.UndressSpecificItems.Pubic = {}  -- currently empty, only used for patching compatibility with other mods
rasSharedData.UndressSpecificItems.Chest = {}
rasSharedData.UndressSpecificItems.Legs = {} 





return rasSharedData







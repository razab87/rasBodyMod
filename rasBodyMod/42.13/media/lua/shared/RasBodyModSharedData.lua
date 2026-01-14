-- this file contains several data used by the mod
--
--
-- by razab



local rasSharedData = {}  -- can be accessed via require("RasBodyModSharedData") in other .lua files


local Regs = RasBodyModRegistries


-- body hair locations
rasSharedData.BodyHairLocations = {}
rasSharedData.BodyHairLocations[Regs.ChestHair] = true
rasSharedData.BodyHairLocations[Regs.ArmpitHair] = true 
rasSharedData.BodyHairLocations[Regs.PubicHair] = true 
rasSharedData.BodyHairLocations[Regs.LegHair] = true 

-- note: RasSkin, RasMalePrivatePart, RasBeardStubble, RasHeadStubble are also new body locations introduced by the mod which should not be treated as if they were locations
-- for clothing items



-- character skins; ordered according to skin color index
rasSharedData.Skins = {}
rasSharedData.Skins.Female = {"RasBodyMod.SkinFemale01", "RasBodyMod.SkinFemale02", "RasBodyMod.SkinFemale03", "RasBodyMod.SkinFemale04", "RasBodyMod.SkinFemale05"}
rasSharedData.Skins.Male = {"RasBodyMod.SkinMale01", "RasBodyMod.SkinMale02", "RasBodyMod.SkinMale03", "RasBodyMod.SkinMale04", "RasBodyMod.SkinMale05"}


-- skin colors as shown in the skin selection menu during character customization; ordering according to rasSharedData.Skins table, note: currently not in use
rasSharedData.SkinColors = {{r=1.0,g=0.84,b=0.76}, {r=0.86,g=0.71,b=0.57}, {r=0.72,g=0.57,b=0.43}, {r=0.54,g=0.38,b=0.25}, {r=0.36,g=0.25,b=0.14}}




rasSharedData.ModLocationID = {} -- internal IDs we use for body hair locations in the moddata
rasSharedData.ModLocationID[Regs.PubicHair] = "RasPubicHair"
rasSharedData.ModLocationID[Regs.ChestHair] = "RasChestHair"
rasSharedData.ModLocationID[Regs.ArmpitHair] = "RasArmpitHair"
rasSharedData.ModLocationID[Regs.LegHair] = "RasLegHair"




-- stores the different penis types for each skin, index int ist the skin color index
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
		[Regs.ArmpitHair] = {
		       items = {"RasBodyMod.FemaleArmpit"},
		},
		[Regs.PubicHair] = { 
		       items = {"RasBodyMod.FemalePubicStrip", "RasBodyMod.FemalePubicTrimmed", "RasBodyMod.FemalePubicNatural"},
		},
	    [Regs.LegHair] = {
		       items = {"RasBodyMod.FemaleLeg"},
		},
	},
	
	Male = {
		[Regs.ChestHair] = {
		       items = {"RasBodyMod.MaleChest"},
		},
		[Regs.ArmpitHair] = {
		       items = {"RasBodyMod.MaleArmpit"},
		},
		[Regs.PubicHair] = { 
		       items = {"RasBodyMod.MalePubicStrip", "RasBodyMod.MalePubicNatural"},
		},
		[Regs.LegHair] = {
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




-- store all full beards; used for managing beard stubble for male characters
rasSharedData.FullBeards = {}
rasSharedData.FullBeards["Full"] = true
rasSharedData.FullBeards["Long"] = true
rasSharedData.FullBeards["LongScruffy"] = true

     

-- some data required to fix a graphic glich related to bullet proof vests and similar clothing items; those items will cause a graphic glitch related to the body hair items when the groin area is
-- visible; in this case, we exchange the (visual of the) vest with an identically looking vest having a different configuration which makes the glitch disappear

-- body locations which hides the lower part of torso
rasSharedData.TorsoLocations = {"Pants", "UnderwearBottom", "ShortsShort", "ShortPants", "Skirt", "LongSkirt", "Torso1", "Torso1Legs1", "TankTop", "Tshirt", "ShortSleeveShirt", "Shirt", "Dress", 
                                "LongDress", "Jersey", "Sweater", "SweaterHat", "Jacket", "Jacket_Down", "Jacket_Bulky", "JacketHat", "JacketHat_Bulky", "JacketSuit", "Boilersuit", "FullSuitHead", 
                                "FullSuitHeadSCBA"
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
rasSharedData.GlitchedItems["Base.Vest_BulletSWAT"] = "RasBodyMod.Vest_BulletSWAT_RasBM"
rasSharedData.GlitchedItems["Base.Vest_BulletDesert"] = "RasBodyMod.Vest_BulletDesert_RasBM"
rasSharedData.GlitchedItems["Base.Vest_BulletDesertNew"] = "RasBodyMod.Vest_BulletDesertNew_RasBM"
rasSharedData.GlitchedItems["Base.Vest_BulletOliveDrab"] = "RasBodyMod.Vest_BulletOliveDrab_RasBM"
rasSharedData.GlitchedItems["Base.Vest_HighViz"] = "RasBodyMod.Vest_HighViz_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Hunting_Grey"] = "RasBodyMod.Vest_Hunting_Grey_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Trucker"] = "RasBodyMod.Vest_Trucker_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Hunting_Orange"] = "RasBodyMod.Vest_Hunting_Orange_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Hunting_Camo"] = "RasBodyMod.Vest_Hunting_Camo_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Hunting_CamoGreen"] = "RasBodyMod.Vest_Hunting_CamoGreen_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Hunting_Khaki"] = "RasBodyMod.Vest_Hunting_Khaki_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Leather"] = "RasBodyMod.Vest_Leather_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Leather_Biker"] = "RasBodyMod.Vest_Leather_Biker_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Leather_Veteran"] = "RasBodyMod.Vest_Leather_Veteran_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Leather_BarrelDogs"] = "RasBodyMod.Vest_Leather_BarrelDogs_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Leather_IronRodents"] = "RasBodyMod.Vest_Leather_IronRodents_RasBM"
rasSharedData.GlitchedItems["Base.Vest_Leather_WildRaccoons"] = "RasBodyMod.Vest_Leather_WildRaccoons_RasBM"

rasSharedData.GlitchedItemsReverse = {}
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_BulletArmy_RasBM"] = "Base.Vest_BulletArmy"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_BulletCivilian_RasBM"] = "Base.Vest_BulletCivilian"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_BulletPolice_RasBM"] = "Base.Vest_BulletPolice"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_BulletSWAT_RasBM"] = "Base.Vest_BulletSWAT"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_BulletDesert_RasBM"] = "Base.Vest_BulletDesert"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_BulletDesertNew_RasBM"] = "Base.Vest_BulletDesertNew"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_BulletOliveDrab_RasBM"] = "Base.Vest_BulletOliveDrab"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_HighViz_RasBM"] = "Base.Vest_HighViz"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Hunting_Grey_RasBM"] = "Base.Vest_Hunting_Grey"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Trucker_RasBM"] = "Base.Vest_Trucker"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Hunting_Orange_RasBM"] = "Base.Vest_Hunting_Orange"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Hunting_Camo_RasBM"] = "Base.Vest_Hunting_Camo"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Hunting_CamoGreen_RasBM"] = "Base.Vest_Hunting_CamoGreen"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Hunting_Khaki_RasBM"] = "Base.Vest_Hunting_Khaki"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Leather_RasBM"] = "Base.Vest_Leather"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Leather_Biker_RasBM"] = "Base.Vest_Leather_Biker"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Leather_Veteran_RasBM"] = "Base.Vest_Leather_Veteran"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Leather_BarrelDogs_RasBM"] = "Base.Vest_Leather_BarrelDogs"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Leather_IronRodents_RasBM"] = "Base.Vest_Leather_IronRodents"
rasSharedData.GlitchedItemsReverse["RasBodyMod.Vest_Leather_WildRaccoons_RasBM"] = "Base.Vest_Leather_WildRaccoons"





-- next table ExceptionalClothes will contain "exceptional clothes": these are clothing items which must be treated manually to hide the penis model when equipped; they cannot be managed via the 
-- vanilla "setHideModel" function since they belong to a body location where some clothing items should hide the penis while others should not

rasSharedData.ExceptionalClothes = {}

rasSharedData.ExceptionalClothes["UnderwearExtra1"] = {}  
rasSharedData.ExceptionalClothes["UnderwearExtra1"]["Base.TightsBlack"] = { hideWhileStanding = true, hideWhileSitting = true }   
rasSharedData.ExceptionalClothes["UnderwearExtra1"]["Base.TightsBlackTrans"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["UnderwearExtra1"]["Base.TightsBlackSemiTrans"] = { hideWhileStanding = true, hideWhileSitting = true } 

rasSharedData.ExceptionalClothes["Dress"] = {} 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_Knees"] = { hideWhileStanding = true, hideWhileSitting = false }   
rasSharedData.ExceptionalClothes["Dress"]["Base.DressKnees_Straps"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SmallBlackStrapless"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SmallBlackStraps"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SmallStrapless"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SmallStraps"] = { hideWhileStanding = true, hideWhileSitting = false }  
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SatinNegligee"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_Short"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_Knees_Crafted_Burlap"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_Knees_Crafted_Cotton"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_Knees_Crafted_Denim"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_Knees_Crafted_DenimBlack"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_Knees_Crafted_DenimLight"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SmallDeerHideStrapless"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SmallGarbageStrapless"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SmallHideStrapless"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Dress"]["Base.Dress_SmallTarpStrapless"] = { hideWhileStanding = true, hideWhileSitting = false } 

rasSharedData.ExceptionalClothes["Legs1"] = {} -- Legs1 location (displayname "Legs")
rasSharedData.ExceptionalClothes["Legs1"]["Base.LongJohns_Bottoms"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["Legs1"]["Base.LongJohns_Bottoms_Crafted_Burlap"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["Legs1"]["Base.LongJohns_Bottoms_Crafted_Cotton"] = { hideWhileStanding = true, hideWhileSitting = true } 
 
rasSharedData.ExceptionalClothes["LongDress"] = {} 
rasSharedData.ExceptionalClothes["LongDress"]["Base.Dress_Long"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["LongDress"]["Base.Dress_long_Straps"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["LongDress"]["Base.Dress_Normal"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["LongDress"]["Base.Dress_Straps"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["LongDress"]["Base.HospitalGown"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["LongDress"]["Base.Dress_Long_Crafted_Burlap"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["LongDress"]["Base.Dress_Long_Crafted_Cotton"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["LongDress"]["Base.Dress_Long_Crafted_Denim"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["LongDress"]["Base.Dress_Long_Crafted_DenimBlack"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["LongDress"]["Base.Dress_Long_Crafted_DenimLight"] = { hideWhileStanding = true, hideWhileSitting = true }

rasSharedData.ExceptionalClothes["Skirt"] = {}
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Knees_Crafted_Burlap"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Knees_Crafted_Cotton"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Knees_Crafted_Denim"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Knees_Crafted_DenimBlack"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Knees_Crafted_DenimLight"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Knees_Hide"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Knees"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Mini"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Short"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Knees_Garbage"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Short_Garbage"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Knees_DeerHide"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Short_FaunHide"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Short_Hide"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Knees_Tarp"] = { hideWhileStanding = true, hideWhileSitting = false }
rasSharedData.ExceptionalClothes["Skirt"]["Base.Skirt_Short_Tarp"] = { hideWhileStanding = true, hideWhileSitting = false }

rasSharedData.ExceptionalClothes["JacketSuit"] = {} -- display name "Suit Jacket"
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_SantaGreen"] = { hideWhileStanding = true, hideWhileSitting = true }  
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_Santa"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_Random"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_Black"] = { hideWhileStanding = true, hideWhileSitting = true } 
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_Doctor"] = { hideWhileStanding = true, hideWhileSitting = true }  
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_Hide"] = { hideWhileStanding = true, hideWhileSitting = true }  
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_AngusCalfHide"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_HolsteinCalfHide"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_SimmentalCalfHide"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_CowHide"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_AngusHide"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_HolsteinHide"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_SimmentalHide"] = { hideWhileStanding = true, hideWhileSitting = true }
rasSharedData.ExceptionalClothes["JacketSuit"]["Base.JacketLong_SheepSkin"] = { hideWhileStanding = true, hideWhileSitting = true }

rasSharedData.ExceptionalClothes["FullTop"] = {} -- FullTop location
rasSharedData.ExceptionalClothes["FullTop"]["Base.Ghillie_Top"] = { hideWhileStanding = true, hideWhileSitting = false }  

rasSharedData.ExceptionalClothes["TorsoExtra"] = {} -- TorsoExtra location (Aprons)
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_Black"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_BBQ"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_IceCream"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_Jay"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_PileOCrepe"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_PizzaWhirled"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_Spiffos"] = { hideWhileStanding = true, hideWhileSitting = false } 
rasSharedData.ExceptionalClothes["TorsoExtra"]["Base.Apron_White"] = { hideWhileStanding = true, hideWhileSitting = false } 
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
             
             local loc = ItemBodyLocation.get(ResourceLocation.of(bodyLocation))
             rasSharedData.UndressLocation[bodyPartToShave][loc] = {} 
             rasSharedData.UndressLocation[bodyPartToShave][loc]["exceptions"] = {}
             for _,item in pairs(exceptionItems) do
                 rasSharedData.UndressLocation[bodyPartToShave][loc]["exceptions"][item] = true
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
makeUndressLocation("Pubic", "ShortPants", {})
makeUndressLocation("Pubic", "ShortsShort", {})
makeUndressLocation("Pubic", "Codpiece", {})
makeUndressLocation("Pubic", "LongSkirt", {})
makeUndressLocation("Pubic", "PantsExtra", {})



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
makeUndressLocation("Legs", "ShortPants", {})
makeUndressLocation("Legs", "ShortsShort", {})
makeUndressLocation("Legs", "LongSkirt", {})
makeUndressLocation("Legs", "PantsExtra", {})
              



-- next tables are alternatives for undressing clothes when shaving; they contain single items which should be undressed and belong to a body location not treated above

rasSharedData.UndressSpecificItems = {}
rasSharedData.UndressSpecificItems.Pubic = {}  -- currently empty, only used for patching compatibility with other mods
rasSharedData.UndressSpecificItems.Chest = {}
rasSharedData.UndressSpecificItems.Legs = {} 





return rasSharedData







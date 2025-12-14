


-------------------- FOR PLAYERS/GENERAL AUDIENCE ---------------------


This mod introduces realistic character textures featuring female and male nudity. To increase anatomical realism, male characters come with a new extra 3d-object attached between their legs. The mod also introduces new options for your character's body hair.

For a detailed description of the mod's content, see the mod's page in the steam workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=2832911317&searchtext=

IMPORTANT: This mod includes some nudity and is therefore intended for mature audience only. However, no sexually explicit elements are contained in the mod.


------------------------- UPDATE NOTES ---------------------------- 


- 1.0: release version

- 1.0.1: fixed problems when loading a game; made it possibile to add the mod to an existing multiplayer game

- 1.1: added Italian translation (thanks to various steam users for contributing translations!)

- 1.2: fixed coverall clothing items not properly hiding the male 3d object when character wears no underpants; fixed translations for "Remove All"; made the mod compatible with the all-clothing-unlocked option from sandbox

- 1.2.1: fixed bandages and wounds sometimes not displayed correctly

- 1.2.2: added Vietnamese translation (thanks to various steam users for contributing translations!); changed some code to make translation easier in futue 

- 1.2.3: increased compatibility with the mod "Clothes Box Redux" (no glitch-through-effects anymore); some smaller changes to the code to increase performance

- 1.3: added compatibility for all screen resolutions at least 1280x720; increased compatibility with the mod "Brita's Armor Pack"

- 1.3.1: fixed some clothing items not available in all-clothing-unlocked mode due to display names duplicates

- 1.3.2: introduced alphabetical ordering of clothing items during character creation when in all-clothing-unlocked mode; added Japanese translation and a corrected version of Italian translation (thanks to various steam users for contributing translations!)

- 1.3.3: added translation for Portuguese-Brazilian (thanks to various steam users for contributing translations!)

- 1.3.4: added Polish and Spanish translation (thanks to various steam users for contributing translations!)

- 1.3.5: fixed question mark icons sometimes appearing on ground when player presses "transfer all" button (only occured in very specific situations)

- 1.4: various changes to the code (including elemintating all global variables and making it easier to add compatibility for clothing mods); some changes to the mesh for male 3d object (triangulated, better UV map); fixed clipping issue with ponchos; fixed some clothing not undressing when shaving body hair; fixed glitch occuring when player presses "Sit on ground" and very quickly WASD afterwards for male characters; similar glitch for situps has been fixed; fixed glitch which could occur if players surpass the max inventory limit (i.e. question mark icons occuring on ground); enhanced visuals for male sitting and situp animations when playing with much lower or much higher fps than 60; enhanced visuals for male characters when running around nude; re-introduced stubble option for male beards and integrated them into the beard growth circle; re-introduced stubble for head hair; updated compatibility for Brita's Armor Pack and Clothes Box Redux; added compatibility for Take A Bath 

- 1.4.1: fixed visual enhancement for male characters when moving around nude introduced in 1.4 sometimes didn't apply (that happened when the mod has been enabled via the main menu and/or a game was loaded the first time after opening PZ); added compatibility for the mod "Anthro Survivors (the "Furry" mod)"

- 1.4.2: added Russian translation (thanks to various steam users for contributing translations!)

- 1.4.3: increased compatibility with the mod "Better Satchel"; increased compatibility with the mod "Improved Hair Menu" (when playing with Improved Hair Menu, the male beard stubble growth mechanics is now disabled to avoid problems; shaving beard stubble is also not possible anymore when playing with Improved Hair Menu -> summary: beard stubble should now behave exactly as in the vanilla game when Improved Hair Menu is enabled); increased compatibility for a certain clothing item from the mod "The Last of Us: Factions & Gear"; added compatibility for the mod "Lifestyle" (the bathing options from this mod should now also clean the new skins introduced by my mod) 

- 1.5: updated mod to build 42; simplified texture management: now, there are base character textures and every body hair element comes as a single texture; the body hair elements get then pasted on the base textures (such a simple system wasn't possible in pre-41.6 versions since this caused some weird graphical glitches; those glitches aren't present in more recent game versions); number of textures has thereby been reduced from 900+ to ca 60; the new texture management is present in the b41 as well as in the b42 version of the mod; some textures might look slightly different than in previous mod version but I tried to keep the overall look as good as possible 

- 1.5.1: fixed a new vanilla clothing which caused clipping for male characters; made the avatar during character customisation slighty larger than it was in 1.5

- 1.5.2: removed some experimental code which improves performance a bit when in Customise Character screen with all-clothing-unlocked enabled; performance issues are not related to my mod and were already present for me in the vanilla game; removing the code may lead to better compatibility with other mods and future game updates 

- 1.5.3: only applies to B42: increased avatar size during character customisation a bit; turned down split normals of male 3d object to make it look less glowing when in certain lighting situations; added possibility that the new b42 item Base.StraightRazor can be used for shaving body hair; increased body hair grow time (now 4-5 days till the next growth state, before 3-4); fixed some clothing items not getting undressed when shaving body hair covered by the clothing; fixed some progress bars during shaving don't disappear when player manually aborted the action; simplified UI when shaving/cutting beard 

- 1.5.4: fixed some clothing items not hiding the male extra 3d object (some suite jacktes, pants and skirts); fixed comboBox briefly changing size during character creation menu; all problems have been introduced by a recent
B42 update

- 1.5.5: added Turkish translation (thanks to various steam users for contributing translations!)

- 1.5.5-Hotfix: fixed Turkish translation

- 1.5.6: only applies to B42: fixed a small issue about wrong bodyLocations during character creation; added incompatible mods to the mod.info file; fixed some crafted dresses not hiding the male private area properly; fixed buggy ui during character customisation occuring when player chooses "continue with new character" after character death; made color, texture and decal buttons properly visible during character creation; re-introduced compatibility patches for some other mods (bathing feature from lifestyle mods, several clothes from clothes box redux, anthro survivors, yaki's barber shop); changed body location of bandeaus so that they can be worn with UnderwearTop items, changed body location of crop tops so that they can be worn together with tank tops (vanilla game has some inconsistency between the item's real body location and their menu slot during character customisation) 

- 1.5.7: adjusted the B42 version of the mod to the new body location system introduced in 42.12.0 (this fixes game-breaking bugs introduced in the recent 42.12.0 vanilla update)

- 1.5.8: fixed body hair items sometimes shown as clothing items in player inventory (only affected B42)

- 1.5.9 (current): added compatibility for singleplayer with the most recent game update to 42.13; multiplayer is not yet supported and requires some more work from my side

 


------------------------- TECHNICAL/FOR MODDERS/MISC -------------------------


There are quite a few mods in the steam workshop introducing new character textures and nudity. Examples are "YYM331`s Nude Texture", "Simple Character Retextures (male and female + makeup)" or several mods by TED BEER. The differences between those mods and this one (to my best knowledge): this mod introduces more body hair options, body hair growth and a new 3d model for a human penis.

The newly introduced character textures, body hair elements and the penis model are realized as clothing items. The game is then manipulated in a way so that the players should not notice that these things are in fact clothing items (e.g. not undressable, not shown in inventory...).

The mod introduces 8 new body locations: rasbomo:skin, rasbomo:pubichair, rasbomo:chesthair, rasbomo:leghair, rasbomo:armpithair, rasbomo:maleprivatepart, rasbomo:beardstubble, rasbomo:headstubble. They are prefixed to the vanilla list of body locations (or to any list of body locations introduced by any mod which is loaded before this one).

Vanilla functions are not overwritten. In several cases, vanilla functions are modified using constructions like

local old_vanillaFunction = vanillaFunction
function vanillaFunction(...)

         --[[ my new code ]]--

         old_vanillaFunction(...) -- execute the vanilla function
         
         --[[ my new code ]]--
end

The mod touches a lot of different game systems (clothing, washing, shaving, sitting and fitness animations, various interface elements, ...). This has been necessary to make it fit my vision. Despite of this, I tested it with several other mods from more popular collections in the steam workshop and it seems to be surprisingly compatible. There are still some mods which definitely cause problems. More info on compatibility can be found on the mod's steam workshop page. 
    

    
---------------------- LANGUAGE AND TRANSLATION ---------------------------------


This mod is available in English, German, Italian, Vietnamese, Japanese, Portuguese-Brazilian, Polish, Spanish, Russian, Turkish (thanks to steam various steam users who contributed). In case you like to add a translation, have a look at the files in the mod's folder media/lua/shared/Translate to see how it works. Feel free to ask about translations in the comment or discussion section of the mod's steam page.


----------------------- LICENSE -------------------------------


Project Zomboid is owned by The Indie Stone. Except for any restrictions imposed by The Indie Stone's modding policy or any third-party content contained in my mods, I consider all my mods to be open source in the sense that as long as you do not publish a plain copy of them on Steam, you are free to use any element of them, modify to your liking and share the results with the public. Note that some of my mods may contain third-party assets. These are either CC0, CC-BY or owned by The Indie Stone. In the latter case, they can only be used in accordance with The Indie Stone's property rights. In case of CC-BY, my mods contain a file listing the sources. Make sure to comply 
with the CC-BY license in case you want to re-use them.


---------------------------------------------------------------


by razab, Dec 14, 2025







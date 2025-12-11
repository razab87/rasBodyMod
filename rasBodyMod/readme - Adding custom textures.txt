

It is easy to replace textures from ra's Body Mod with your own custom textures. If you would like to, you can also publish your new textures as a mod in the steam workshop. Here is a step-by-step guide:

1. Set my mod in your mod's requirement.
2. In your mod, give your new textures the same name as the original textures from my mod you'd like to replace. In my mod, the textures are contained in the following folders:
   
   for the B41 of my mod: rasBodyMod/media/textures/RasBodyModTextures
   for B42: rasBodyMod/common/media/textures/RasBodyModTextures

3. In your mod, mimique the folder structure of my mod and put your new textures exactly at same the locations where the to-be-replaced textures from my mod are located. In case you want to apply your new textures to both, 
   the B41 and the B42 version, you have to apply this to the rasBodyMod/media/textures folder (for B41) as well as to the rasBodyMod/common/media/textures folder (for B42). 
   
Example: Assume you would like to replace my mod's texture "SkinFemale02.png". Make a .png called "SkinFemale02.png". To use your new texture in B41, put it in your mod's folder rasBodyMod/media/textures/RasBodyModTextures/Skins. 
To use it in B42, put it to rasBodyMod/common/media/textures/RasBodyModTextures/Skin. (Best idea is to always apply this to both versions.) Done.

Additional info:
- In case you replace male character textures, you may also have to replace the textures for the male 3D object to properly align with your new skin color. Those textures can be found in my mod's folder textures/
  RasBodyModTextures/MalePrivate.
- for female characters, some body hair items come in two versions where the second version is called "something_Black2". The Black2 versions differ a bit from the normal version (they are a bit darker and thicker). They are 
  applied to the two darkest skin colors for better visuals. You may keep this in mind in case you'd like to replace body hair textures. In this case, you might also want to replace the "something_Black2" textures accordingly.
- You can find several body hair textures called "something_int". Those are the intermediate grow states of the body hair (the one which is displayed bewteen "none" and "natural" for a few days while the body hair grows in game). 
  When you change body hair textures, you may want to change the int-versions too for more consistent visuals.

Important: After you enabled or disabled your mod, you have to restart the game for the changes to take place. Your mod should therefore be enabled/disabled via the mod menu in the game's main menu. (This is not necessary for the original Body Mod alone btw).


The above procedure can also be applied to make my mod compatible with mods introducing other character textures or 3D character models. Essentially, you just have to replace my textures with textures from the other mod (or any textures optimized for a different 3D model). In the case of 3D models, this should work without any problem for female characters models. For male characters, it may depend on the model's exact design since this will determine how good the male extra 3D object fits to the new model. 


If you take the new textures from another mod which you didn't create by yourself, you should at least set the respective mod as an additional requirement for your mod (better: also ask the mod creator for permission).

-- here we make sure that the player wears correct skin and other body items when in the CDDA challenge (vanilla game removes it)
--
--
-- by razab



local manageBody = require("ManageBodyShared/RasBodyModManageBodyIG")

local Regs = RasBodyModRegistries


local vanilla_AddPlayer = CDDA.AddPlayer
function CDDA.AddPlayer(playerNum, playerObj, ...)

    vanilla_AddPlayer(playerNum, playerObj, ...) -- execute vanilla code
         
    local queue = {
        {functionName = "EquipSkin", args = {}},
        {functionName = "EquipBodyHair", args = {bodyLocation = Regs.PubicHair}},
        {functionName = "EquipBodyHair", args = {bodyLocation = Regs.LegHair}},
        {functionName = "EquipBodyHair", args = {bodyLocation = Regs.ArmpitHair}},
        {functionName = "EquipHeadStubble", args = {}}
    }

    if not playerObj:isFemale() then -- additional items for male characters
        table.insert(queue, {functionName = "EquipBodyHair", args = {bodyLocation = Regs.ChestHair}})
        table.insert(queue, {functionName = "ManageMalePrivatePart", args = {checkForExceptionalClothes = true}}) -- make sure correct penis is equipped
        table.insert(queue, {functionName = "EquipBeardStubble", args = {}})      
    end

    table.insert(queue, {functionName = "VestGlitchFixNewGame", args = {}}) -- apply the glitch fix for vests
    table.insert(queue, {functionName = "VestGlitchFix", args = {}}) 
    table.insert(queue, {functionName = "TransferDirtToSkin", args = {}}) 

    local beardStubble = playerObj:getWornItem(Regs.BeardStubble)
    playerObj:getInventory():Remove(beardStubble)        

    local data = playerObj:getModData().RasBodyMod

    if not playerObj:isFemale() then 
        data.WearsExceptionalClothesDefault = manageBody.WearsExceptionalClothing(playerObj, "hideWhileStanding") -- check whether we wear exceptional clothes which should hide the groin area
        data.WearsExceptionalClothesSitting = manageBody.WearsExceptionalClothing(playerObj, "hideWhileSitting")
        data.GroinNudeDefault = manageBody.GroinNude(playerObj, "hideWhileStanding")
        data.GroinNudeSitting = manageBody.GroinNude(playerObj, "hideWhileSitting")
    end
  
    manageBody.executeQueue(playerObj, queue, true) -- parameter true tells the function to update the in-game avatar screen after equipping        
end
        










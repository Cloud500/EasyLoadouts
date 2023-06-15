local EasyLoadoutItemUtils = require("utils/EasyLoadoutItemUtils")

---@class EasyLoadoutActionHotbar : ISBaseTimedAction
---@field private player number
---@field private loadout EasyLoadoutDataLoadout
---@field private container ItemContainer
---@field private itemData EasyLoadoutDataEquipment
---@field private character IsoPlayer
local EasyLoadoutActionHotbar = ISBaseTimedAction:derive("EasyLoadoutEquipHotbar")

---@param player number
---@param itemData EasyLoadoutDataEquipment
---@param loadout EasyLoadoutDataLoadout
---@param container ItemContainer
function EasyLoadoutActionHotbar:new(player, itemData, loadout, container)
    ---@type EasyLoadoutActionHotbar
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.player = player
    o.character = getSpecificPlayer(player)
    o.loadout = loadout
    o.container = container
    o.itemData = itemData
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = 1
    return o
end

---@private
function EasyLoadoutActionHotbar:isValid()
    return true
end

---@private
function EasyLoadoutActionHotbar:perform()
    local item = EasyLoadoutItemUtils.getItem(self.itemData, self.loadout, self.container)
    local equipData = EasyLoadoutItemUtils.getAttachedSlotData(self.character, item, self.itemData)
    equipData.hotbar:attachItem(equipData.item, equipData.attachment, equipData.index, equipData.slotDef, false)

    ISBaseTimedAction.perform(self)
end

return EasyLoadoutActionHotbar
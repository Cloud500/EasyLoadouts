local EasyLoadoutItemUtils = require("utils/EasyLoadoutItemUtils")
local EasyLoadoutActionHotbar = require("actions/EasyLoadoutActionHotbar")

---@class EasyLoadoutActionUnequip : ISBaseTimedAction
---@field private player number
---@field private character IsoPlayer
---@field private loadout EasyLoadoutDataLoadout
---@field private srcContainer ItemContainer
---@field private destContainer ItemContainer
---@field private unequip boolean
---@field private equip boolean
---@field private stopOnWalk boolean
---@field private stopOnRun boolean
---@field private maxTime number
local EasyLoadoutActionTransfer = ISBaseTimedAction:derive("EasyLoadoutActionUnequip")

---@param player number
---@param loadout EasyLoadoutDataLoadout
---@param srcContainer ItemContainer
---@param destContainer ItemContainer
---@param unequip boolean
---@param equip boolean
---@param undress boolean
---@return EasyLoadoutActionUnequip
function EasyLoadoutActionTransfer:new(player, loadout, srcContainer, destContainer, unequip, equip, undress)
    ---@type EasyLoadoutActionUnequip
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.character = getSpecificPlayer(player)
    o.loadout = loadout
    o.srcContainer = srcContainer
    o.destContainer = destContainer
    o.unequip = unequip
    o.equip = equip
    o.undress = undress
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = 1

    if undress then
        o.unequip = true
        o.equip = false
    end

    return o
end

---@private
---@return boolean
function EasyLoadoutActionTransfer:isValid()
    return true
end

---@private
---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
---@return InventoryItem[]
function EasyLoadoutActionTransfer:loadLoadoutItems(container, loadout)
    local items = {}

    for _, itemData in ipairs(loadout.equipment) do
        local item = EasyLoadoutItemUtils.getItem(itemData, loadout, container)
        if item then
            table.insert(items, item)
        end
    end

    for _, itemData in ipairs(loadout.apparel) do
        local item = EasyLoadoutItemUtils.getItem(itemData, loadout, container)
        if item then
            table.insert(items, item)
        end
    end
    local item_ids = {}
    for _, itemData in ipairs(loadout.items) do
        local item = EasyLoadoutItemUtils.getItem(itemData, loadout, container, true, item_ids)
        if item then
            table.insert(item_ids, item:getID())
            table.insert(items, item)
        end
    end
    return items
end

---@private
---@param character IsoPlayer
---@return InventoryItem[]
function EasyLoadoutActionTransfer:loadUndressItems(character)
    local items = {}
    for i = 0, character:getWornItems():size() - 1 do
        local item = character:getWornItems():getItemByIndex(i)
        if (item:getDisplayCategory() ~= "Bandage")
                and (item:getDisplayCategory() ~= "ZedDmg")
                and (item:getDisplayCategory() ~= "Wound") then
            table.insert(items, item)
        end
    end
    return items
end

---@private
---@param item InventoryItem
function EasyLoadoutActionTransfer:unequipItem(item)
    if self.unequip and (self.character:isEquipped(item) or self.character:isAttachedItem(item)) then
        ISTimedActionQueue.add(ISUnequipAction:new(self.character, item, 50))
    end
end

---@private
---@param item InventoryItem
function EasyLoadoutActionTransfer:transferItem(item)
    if self.srcContainer ~= self.destContainer then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(self.character, item, self.srcContainer,
                                                             self.destContainer, 50))
    end
end

---@private
---@param item InventoryItem
function EasyLoadoutActionTransfer:equipItem(item)
    if self.equip and EasyLoadoutItemUtils.getItemType(item) == "apparel" then
        ISTimedActionQueue.add(ISWearClothing:new(self.character, item, 50))
    end
end

---@private
function EasyLoadoutActionTransfer:equipHotbar()
    for _, itemData in ipairs(self.loadout.equipment) do
        ISTimedActionQueue.add(EasyLoadoutActionHotbar:new(self.player, itemData, self.loadout, self.destContainer))
    end
end

---@private
function EasyLoadoutActionTransfer:perform()
    local items = {}
    if self.undress then
        items = self:loadUndressItems(self.character)
    else
        items = self:loadLoadoutItems(self.srcContainer, self.loadout)
    end

    for _, item in ipairs(items) do
        self:unequipItem(item)
        self:transferItem(item)
        self:equipItem(item)
    end

    if self.equip then
        self:equipHotbar()
    end

    ISBaseTimedAction.perform(self)
end

return EasyLoadoutActionTransfer


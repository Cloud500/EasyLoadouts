local EasyLoadoutItemUtils = require("utils/EasyLoadoutItemUtils")

---@class EasyLoadoutPatch1
local EasyLoadoutPatch1 = {}
EasyLoadoutPatch1.__index = EasyLoadoutPatch1

---@param loadout EasyLoadoutDataLoadout
---@param container ItemContainer
---@return EasyLoadoutPatch1
function EasyLoadoutPatch1:patch(loadout, container)
    ---@type EasyLoadoutPatch1
    local o = {}
    setmetatable(o, self)

    ---@type EasyLoadoutDataLoadout
    o.loadout = loadout

    ---@type ItemContainer
    o.container = container

    o:run()
    return 0
end

---@private
---@param item InventoryItem
function EasyLoadoutPatch1:updateApparel(item)
    ---@param itemData EasyLoadoutDataApparel
    for _, itemData in pairs(self.loadout.apparel) do
        if EasyLoadoutItemUtils.getItemIdOrName(item, self.loadout) == itemData.item then
            itemData.fullType = item:getFullType()
        end
    end
end

---@private
---@param item InventoryItem
function EasyLoadoutPatch1:updateEquipment(item)
    ---@param itemData EasyLoadoutDataEquipment
    for _, itemData in pairs(self.loadout.equipment) do
        if EasyLoadoutItemUtils.getItemIdOrName(item, self.loadout) == itemData.item then
            itemData.fullType = item:getFullType()
        end
    end
end

---@private
---@param item InventoryItem
function EasyLoadoutPatch1:updateItem(item)
    ---@param itemData EasyLoadoutDataItems
    for _, itemData in pairs(self.loadout.items) do
        if EasyLoadoutItemUtils.getItemIdOrName(item, self.loadout) == itemData.item then
            itemData.fullType = item:getFullType()
        end
    end
end

---@private
function EasyLoadoutPatch1:updateFromContainerItems()
    for i = 0, self.container:getItems():size() - 1 do
        ---@type InventoryItem
        local item = self.container:getItems():get(i)
        local itemType = EasyLoadoutItemUtils.getItemType(item)
        if itemType == "apparel" then
            self:updateApparel(item)
        elseif itemType == "equipment" then
            self:updateEquipment(item)
        elseif itemType == "item" then
            self:updateItem(item)
        end
    end
end

---@private
function EasyLoadoutPatch1:mergeItems()
    local newItemList = {}

    ---@param itemData EasyLoadoutDataItems
    for _, itemData in pairs(self.loadout.items) do
        if newItemList.items[itemData.item] ~= nil then
            newItemList.items[itemData.item].count = newItemList.items[itemData.item].count + 1
        else
            newItemList.items[itemData.item] = {
                item     = itemData.item,
                fullType = itemData.fullType,
                count    = 1
            }
        end
    end

    self.loadout.items = newItemList
end

---@private
function EasyLoadoutPatch1:run()
    self:updateFromContainerItems()
    self:mergeItems()
end

return EasyLoadoutPatch1
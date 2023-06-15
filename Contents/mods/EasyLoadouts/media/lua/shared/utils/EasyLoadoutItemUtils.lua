local EasyLoadoutUtils     = require("utils/EasyLoadoutUtils")
local EasyLoadoutItemUtils = {}

---@param loadout EasyLoadoutDataLoadout
---@param item InventoryItem
---@return string
function EasyLoadoutItemUtils.getItemIdOrName(item, loadout)
    if loadout.config.type == "name" then
        return item:getName()
    else
        return item:getID()
    end
end

---@param loadout EasyLoadoutDataLoadout
---@param item InventoryItem
---@return boolean
function EasyLoadoutItemUtils.checkIfAlreadyRegistered(item, loadout)

    ---@param itemData EasyLoadoutDataApparel
    for _, itemData in ipairs(loadout.apparel) do
        if EasyLoadoutItemUtils.getItemIdOrName(item, loadout) == itemData.item then
            return true
        end
    end

    ---@param itemData EasyLoadoutDataEquipment
    for _, itemData in ipairs(loadout.equipment) do
        if EasyLoadoutItemUtils.getItemIdOrName(item, loadout) == itemData.item then
            return true
        end
    end

    ---@param itemData EasyLoadoutDataItems
    for _, itemData in ipairs(loadout.items) do
        if EasyLoadoutItemUtils.getItemIdOrName(item, loadout) == itemData.item then
            return true
        end
    end
    return false
end

---@param character IsoPlayer
---@param item InventoryItem
---@return string
function EasyLoadoutItemUtils.getAttachedSlot(character, item)
    if item:getAttachedSlot() > 0 then
        local hotbar = getPlayerHotbar(character:getPlayerNum())
        --hotbar:refresh()
        local slot   = hotbar.availableSlot[item:getAttachedSlot()]
        return slot.slotType
    else
        return ""
    end
end

---@param character IsoPlayer
---@param item InventoryItem
---@param itemData EasyLoadoutDataEquipment
---@return {hotbar: ISHotbar, item: InventoryItem, attachment: string, index: number, slotDef: table}
function EasyLoadoutItemUtils.getAttachedSlotData(character, item, itemData)
    local doIt = false
    local hotbar = getPlayerHotbar(character:getPlayerNum())
    local slots = hotbar.availableSlot
    for index, slot in ipairs(slots) do
        if slot.slotType == itemData.slotType then
            local slotDef = slot.def
            for name, attachment in pairs(slotDef.attachments) do
                if item:getAttachmentType() == name then
                    doIt = true
                    if hotbar.replacements and hotbar.replacements[item:getAttachmentType()] then
                        slot = hotbar.replacements[item:getAttachmentType()]
                        if slot == "null" then
                            doIt = false
                        end
                    end

                    if doIt then
                        return {hotbar = hotbar, item = item, attachment = attachment, index = index, slotDef = slotDef}
                    end
                end
            end
        end
    end
end


---@param item string
---@return boolean
function EasyLoadoutItemUtils.excludedAttachmentTypes(item)
    local attachmentType = item:getAttachmentType()
    if attachmentType == nil then
        return false
    end
    if attachmentType == 'Mag' then
        return false
    end

    if attachmentType == 'Gear' then
        return false
    end
    return true
end

---@param item string
---@return string
function EasyLoadoutItemUtils.getItemType(item)
    if item:IsClothing() or (instanceof(item, "InventoryContainer") and item:canBeEquipped() ~= "") then
        return "apparel"
    elseif item:IsWeapon() or EasyLoadoutItemUtils.excludedAttachmentTypes(item) then
        return "equipment"
    else
        return "item"
    end
end

---@param itemData EasyLoadoutDataApparel | EasyLoadoutDataEquipment | EasyLoadoutDataItems
---@param loadout EasyLoadoutDataLoadout
---@param container ItemContainer
---@param overwriteForItem boolean
---@param itemsAlreadyTaken string[]
---@return InventoryItem
function EasyLoadoutItemUtils.getItem(itemData, loadout, container, overwriteForItem, itemsAlreadyTaken)
    if overwriteForItem then
        for i = 0, container:getItems():size() - 1 do
            local item         = container:getItems():get(i)
            local alreadyTaken = EasyLoadoutUtils.tableContains(itemsAlreadyTaken, item:getID())
            if item:getName() == itemData.item and alreadyTaken == nil then
                return item
            end
        end

    elseif loadout.config.type == "name" then
        for i = 0, container:getItems():size() - 1 do
            local item = container:getItems():get(i)
            if item:getName() == itemData.item then
                return item
            end
        end
    else
        return container:getItemWithIDRecursiv(itemData.item)
    end
end

return EasyLoadoutItemUtils
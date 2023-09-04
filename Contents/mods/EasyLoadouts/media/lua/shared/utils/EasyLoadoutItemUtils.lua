local EasyLoadoutUtils = require("utils/EasyLoadoutUtils")
local EasyLoadoutItemUtils = {}

EasyLoadoutItemUtils.colorKnown = {0, 1, 0}
EasyLoadoutItemUtils.colorUnknown = {0.4, 0.4, 0.4}
EasyLoadoutItemUtils.space = 25

---@param loadout EasyLoadoutDataLoadout
---@param item InventoryItem
---@param typeOverride string optional
---@return string
function EasyLoadoutItemUtils.getItemIdOrName(item, loadout, typeOverride)
    local type = loadout.config.type

    if typeOverride ~= nil then
        type = typeOverride
    end

    if type == "name" then
        return item:getName()
    else
        return item:getID()
    end
end

---@param loadout EasyLoadoutDataLoadout
---@param item InventoryItem
---@param typeOverride string optional
---@return boolean
function EasyLoadoutItemUtils.checkIfAlreadyRegistered(item, loadout, typeOverride)

    ---@param itemData EasyLoadoutDataApparel
    for _, itemData in pairs(loadout.apparel) do
        if EasyLoadoutItemUtils.getItemIdOrName(item, loadout) == itemData.item then
            return true
        end
    end

    ---@param itemData EasyLoadoutDataEquipment
    for _, itemData in pairs(loadout.equipment) do
        if EasyLoadoutItemUtils.getItemIdOrName(item, loadout) == itemData.item then
            return true
        end
    end

    ---@param itemData EasyLoadoutDataItems
    for _, itemData in pairs(loadout.items) do
        if EasyLoadoutItemUtils.getItemIdOrName(item, loadout, typeOverride) == itemData.item then
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
        local slot = hotbar.availableSlot[item:getAttachedSlot()]
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
            local item = container:getItems():get(i)
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

---@private
---@return string
function EasyLoadoutItemUtils.toolTipItemData(itemData)
    local name = "Wrong Dataset"
    local color = EasyLoadoutItemUtils.colorUnknown
    if itemData.fullType ~= nil then
        name = InventoryItemFactory.CreateItem(itemData.fullType):getDisplayName()
        color = EasyLoadoutItemUtils.colorKnown
    end
    if itemData.count ~= nil then
        return string.format("<SETX:%d> %sx <RGB:%f,%f,%f> %s <RGB:1,1,1>\n", EasyLoadoutItemUtils.space,
                             itemData.count, color[1], color[2], color[3], name)
    else
        return string.format("<SETX:%d> <RGB:%f,%f,%f> %s <RGB:1,1,1>\n", EasyLoadoutItemUtils.space,
                             color[1], color[2], color[3], name)
    end
end

---@private
---@return string
function EasyLoadoutItemUtils.toolTipListData(dataList)
    local dataListText = ""
    if dataList ~= nil and EasyLoadoutUtils.getTableLength(dataList) >= 1 then
        for _, itemData in pairs(dataList) do
            dataListText = dataListText .. EasyLoadoutItemUtils.toolTipItemData(itemData)
        end
    else
        dataListText = string.format("<SETX:%d> %s \n", EasyLoadoutItemUtils.space, getText("UI_EasyLoadout_UI_None"))
    end
    return dataListText
end


---@private
---@param loadout EasyLoadoutDataLoadout
---@return string
function EasyLoadoutItemUtils.toolTipRegisteredApparel(loadout)
    local apparel_list = getText("UI_EasyLoadout_ModOptionApparel") .. "\n"
    apparel_list = apparel_list .. EasyLoadoutItemUtils.toolTipListData(loadout.apparel)
    apparel_list = apparel_list .. "\n"
    return apparel_list
end

---@private
---@param loadout EasyLoadoutDataLoadout
---@return string
function EasyLoadoutItemUtils.toolTipRegisteredEquipment(loadout)
    local equipment_list = getText("UI_EasyLoadout_ModOptionEquipment") .. "\n"
    equipment_list = equipment_list .. EasyLoadoutItemUtils.toolTipListData(loadout.equipment)
    equipment_list = equipment_list .. "\n"
    return equipment_list
end

---@private
---@param loadout EasyLoadoutDataLoadout
---@return string
function EasyLoadoutItemUtils.toolTipRegisteredItems(loadout)
    local items_list = getText("UI_EasyLoadout_ModOptionItems") .. "\n"
    items_list = items_list .. EasyLoadoutItemUtils.toolTipListData(loadout.items)
    items_list = items_list .. "\n"
    return items_list
end

---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutItemUtils.toolTipRegistered(loadout, name)
    local toolTip = ISToolTip:new()
    toolTip:setName(name)

    if loadout.config.apparel then
        toolTip.description = toolTip.description .. EasyLoadoutItemUtils.toolTipRegisteredApparel(loadout)
    end
    if loadout.config.equipment then
        toolTip.description = toolTip.description .. EasyLoadoutItemUtils.toolTipRegisteredEquipment(loadout)
    end
    if loadout.config.items then
        toolTip.description = toolTip.description .. EasyLoadoutItemUtils.toolTipRegisteredItems(loadout)
    end

    return toolTip
end

return EasyLoadoutItemUtils
local EasyLoadoutItemUtils = require("utils/EasyLoadoutItemUtils")
local EasyLoadoutActionTransfer = require("actions/EasyLoadoutActionTransfer")
local EasyLoadoutModDataUtils = require("utils/EasyLoadoutModDataUtils")
local EasyLoadoutEvents = {}

---@param player number
---@param item InventoryItem
function EasyLoadoutEvents.applyTag(player, item)
    local character = getSpecificPlayer(player)
    local container = item:getContainer()
    local modData = EasyLoadoutModDataUtils.createOrGetModData(character, container)
    modData.enabled = true
    modData.loadouts[item:getName()] = EasyLoadoutModDataUtils.createLoadoutData()

    EasyLoadoutModDataUtils.transmitModData(container, item, true)
    container:DoRemoveItem(item)
end

---@param player number
---@param item InventoryItem
function EasyLoadoutEvents.renameTag(player, item)
    local character = getSpecificPlayer(player)
    local text_box = ISTextBox:new(0, 0, 280, 180, getText("ContextMenu_EasyLoadoutRenameTag"),
                                   item:getName(), nil, ISInventoryPaneContextMenu.onRenameBagClick,
                                   player, character, item)
    text_box:initialise()
    text_box:addToUIManager()
    if JoypadState.players[player + 1] then
        setJoypadFocus(player, text_box)
    end
end

---@param container ItemContainer
---@param easyLoadoutData EasyLoadoutData
---@param item_name string
function EasyLoadoutEvents.removeTag(container, easyLoadoutData, item_name)
    easyLoadoutData.loadouts[item_name] = nil
    easyLoadoutData.enabled = false
    easyLoadoutData.type = nil
    for _ in pairs(easyLoadoutData.loadouts) do
        easyLoadoutData.enabled = true
        break
    end
    if easyLoadoutData.enabled == false then
        easyLoadoutData = nil
    end

    local loadoutTag = InventoryItemFactory.CreateItem("EasyLoadout.LoadoutNote")
    loadoutTag:setName(item_name)
    EasyLoadoutModDataUtils.transmitModData(container, loadoutTag, false)
    container:AddItem(loadoutTag)
end

---@param loadout EasyLoadoutDataLoadout
---@param container ItemContainer
---@param type string
function EasyLoadoutEvents.setConfigType(container, loadout, type)
    loadout.items = {}
    loadout.registered = false
    loadout.config.type = type

    EasyLoadoutModDataUtils.transmitModData(container)
end

---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
---@param character IsoPlayer
function EasyLoadoutEvents.setFunctionPrivate(container, loadout, character)
    if loadout.config.private then
        loadout.config.private = false
        loadout.config.player = nil
    else
        loadout.config.private = true
        loadout.config.player = character:getSteamID()
    end

    EasyLoadoutModDataUtils.transmitModData(container)
end

---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.setFunctionUndress(container, loadout)
    if loadout.config.undress then
        loadout.config.undress = false
    else
        loadout.config.undress = true
    end
    EasyLoadoutModDataUtils.transmitModData(container)

end

---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.setFunctionApparel(container, loadout)
    if loadout.config.apparel then
        loadout.config.apparel = false
    else
        loadout.config.apparel = true
    end
    EasyLoadoutModDataUtils.transmitModData(container)
end

---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.setFunctionEquipment(container, loadout)
    if loadout.config.equipment then
        loadout.config.equipment = false
    else
        loadout.config.equipment = true
    end
    EasyLoadoutModDataUtils.transmitModData(container)
end

---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.setFunctionItem(container, loadout)
    if loadout.config.items then
        loadout.config.items = false
    else
        loadout.config.items = true
    end
    EasyLoadoutModDataUtils.transmitModData(container)
end

---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.registerApparel(container, loadout)
    local updateModData = false

    for i = 0, container:getItems():size() - 1 do
        ---@type InventoryItem
        local item = container:getItems():get(i)
        local itemType = EasyLoadoutItemUtils.getItemType(item)

        if itemType == "apparel" and not EasyLoadoutItemUtils.checkIfAlreadyRegistered(item, loadout) then
            table.insert(loadout.apparel, {
                item         = EasyLoadoutItemUtils.getItemIdOrName(item, loadout),
                attachedSlot = "",
            })
            updateModData = true
        end
    end
    return updateModData
end

---@param character IsoPlayer
---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.registerEquipment(character, container, loadout)
    local updateModData = false
    for i = 0, container:getItems():size() - 1 do
        ---@type InventoryItem
        local item = container:getItems():get(i)
        local itemType = EasyLoadoutItemUtils.getItemType(item)

        if itemType == "equipment" and not EasyLoadoutItemUtils.checkIfAlreadyRegistered(item, loadout) then
            table.insert(loadout.equipment, {
                item         = EasyLoadoutItemUtils.getItemIdOrName(item, loadout),
                attachedSlot = item:getAttachedSlot(),
                slotType     = EasyLoadoutItemUtils.getAttachedSlot(character, item),
            })
            updateModData = true
        end
    end
    return updateModData
end

---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.registerItem(container, loadout)
    local updateModData = false
    for i = 0, container:getItems():size() - 1 do
        ---@type InventoryItem
        local item = container:getItems():get(i)
        local itemType = EasyLoadoutItemUtils.getItemType(item)

        if itemType == "item" and not item:isFavorite() then
            table.insert(loadout.items, {
                item = item:getName(),
            })
            updateModData = true
        end
    end
    return updateModData
end

---@param character IsoPlayer
---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.registerLoadout(character, container, loadout)
    if container then
        EasyLoadoutEvents.removeLoadout(container, loadout)

        local registeredApparel = false
        local registeredEquipment = false
        local registeredItem = false

        -- TODO: check if disabled
        if loadout.config.apparel then
            registeredApparel = EasyLoadoutEvents.registerApparel(container, loadout, container:getItems())
        end
        if loadout.config.equipment then
            registeredEquipment = EasyLoadoutEvents.registerEquipment(character, container, loadout)
        end
        if loadout.config.items then
            registeredItem = EasyLoadoutEvents.registerItem(container, loadout)
        end

        if registeredApparel or registeredEquipment or registeredItem then
            loadout.registered = true
            EasyLoadoutModDataUtils.transmitModData(container)
        end
    end
end

---@param character IsoPlayer
---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.registerAndStoreLoadout(character, container, loadout)
    if container then
        EasyLoadoutEvents.removeLoadout(container, loadout)

        local registeredApparel = false
        local registeredEquipment = false
        local registeredItem = false

        if loadout.config.apparel then
            registeredApparel = EasyLoadoutEvents.registerApparel(character:getInventory(), loadout)
        end
        if loadout.config.equipment then
            registeredEquipment = EasyLoadoutEvents.registerEquipment(character, character:getInventory(), loadout)
        end
        if loadout.config.items then
            registeredItem = EasyLoadoutEvents.registerItem(character:getInventory(), loadout)
        end

        if registeredApparel or registeredEquipment or registeredItem then
            loadout.registered = true
            EasyLoadoutModDataUtils.transmitModData(container)
        end

        ISTimedActionQueue.add(EasyLoadoutActionTransfer:new(character:getPlayerNum(),
                                                             loadout,
                                                             character:getInventory(),
                                                             container,
                                                             true, false))
    end
end

---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.removeLoadout(container, loadout)
    loadout.apparel = {}
    loadout.equipment = {}
    loadout.items = {}
    loadout.registered = false
    EasyLoadoutModDataUtils.transmitModData(container)
end

---@param character IsoPlayer
---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.wearLoadout(character, container, loadout)
    if loadout.config.undress then
        ISTimedActionQueue.add(EasyLoadoutActionTransfer:new(character:getPlayerNum(),
                                                             loadout,
                                                             character:getInventory(),
                                                             container,
                                                             true, false, true))
    end
    ISTimedActionQueue.add(EasyLoadoutActionTransfer:new(character:getPlayerNum(),
                                                         loadout,
                                                         container,
                                                         character:getInventory(),
                                                         false, true))
end

---@param character IsoPlayer
---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.storeLoadout(character, container, loadout)
    if container then
        ISTimedActionQueue.add(EasyLoadoutActionTransfer:new(character:getPlayerNum(),
                                                             loadout,
                                                             character:getInventory(),
                                                             container,
                                                             true, false))
    end
end

---@param character IsoPlayer
---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function EasyLoadoutEvents.pickUpLoadout(character, container, loadout)
    if container then
        ISTimedActionQueue.add(EasyLoadoutActionTransfer:new(character:getPlayerNum(),
                                                             loadout,
                                                             container,
                                                             character:getInventory(),
                                                             false, false))
    end
end

return EasyLoadoutEvents
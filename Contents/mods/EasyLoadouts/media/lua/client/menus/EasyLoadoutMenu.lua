require "EasyLoadout"
local EasyLoadoutUtils = require("utils/EasyLoadoutUtils")
local EasyLoadoutItemUtils = require("utils/EasyLoadoutItemUtils")
local EasyLoadoutEvents = require("EasyLoadoutEvents")
local EasyLoadoutPluginManageUI = require("menus/EasyLoadoutPluginManageUI")
local EasyLoadoutCompatibilityUtils = require("utils/EasyLoadoutCompatibilityUtils")

---@param configMenu ISContextMenu
---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function buildLoadoutTypeMenu(configMenu, container, loadout)
    local typeMenu = configMenu:getNew(configMenu)
    configMenu:addSubMenu(configMenu:addOption(getText("ContextMenu_EasyLoadoutConfigType")), typeMenu)

    local optionSetID = typeMenu:addOption(getText("ContextMenu_EasyLoadoutConfigTypeId"), container,
                                           EasyLoadoutEvents.setConfigType, loadout, "id")
    addOptionInfo(optionSetID, getText("ContextMenu_EasyLoadoutConfigTypeId"),
                  getText("Tooltip_EasyLoadoutConfigTypeId"))

    local optionSetName = typeMenu:addOption(getText("ContextMenu_EasyLoadoutConfigTypeName"), container,
                                             EasyLoadoutEvents.setConfigType, loadout, "name")
    addOptionInfo(optionSetName, getText("ContextMenu_EasyLoadoutConfigTypeName"),
                  getText("Tooltip_EasyLoadoutConfigTypeName"))

    if loadout.config.type == "name" then
        optionSetName.iconTexture = getTexture(EasyLoadout.icons.on)
        optionSetID.iconTexture = getTexture(EasyLoadout.icons.off)
    else
        optionSetID.iconTexture = getTexture(EasyLoadout.icons.on)
        optionSetName.iconTexture = getTexture(EasyLoadout.icons.off)
    end
end

---@param option ISContextMenu
---@param name string
---@param tooltip string
---@param switch boolean
---@param switchValue boolean
function addOptionInfo(option, name, tooltip, switch, switchValue)
    local toolTip = ISToolTip:new()
    toolTip:setName(name)
    toolTip.description = tooltip

    option.toolTip = toolTip

    if switch then
        if switchValue then
            option.iconTexture = getTexture(EasyLoadout.icons.on)
        else
            option.iconTexture = getTexture(EasyLoadout.icons.off)
        end
    end
end

---@param configMenu ISContextMenu
---@param character IsoPlayer
---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function buildLoadoutFunctionsMenu(configMenu, character, container, loadout)
    local functionMenu = configMenu:getNew(configMenu)
    configMenu:addSubMenu(configMenu:addOption(getText("ContextMenu_EasyLoadoutFunctions")), functionMenu)

    local functionApparel = functionMenu:addOption(getText("ContextMenu_EasyLoadoutFunctionApparel"), container,
                                                   EasyLoadoutEvents.setFunctionApparel, loadout)
    addOptionInfo(functionApparel, getText("ContextMenu_EasyLoadoutFunctionApparel"),
                  getText("Tooltip_EasyLoadoutFunctionApparel"), true, loadout.config.apparel)

    local functionEquipment = functionMenu:addOption(getText("ContextMenu_EasyLoadoutFunctionEquipment"), container,
                                                     EasyLoadoutEvents.setFunctionEquipment, loadout)
    addOptionInfo(functionEquipment, getText("ContextMenu_EasyLoadoutFunctionEquipment"),
                  getText("Tooltip_EasyLoadoutFunctionEquipment"), true, loadout.config.equipment)

    local functionItem = functionMenu:addOption(getText("ContextMenu_EasyLoadoutFunctionItem"), container,
                                                EasyLoadoutEvents.setFunctionItem, loadout)
    addOptionInfo(functionItem, getText("ContextMenu_EasyLoadoutFunctionItem"),
                  getText("Tooltip_EasyLoadoutFunctionItem"), true, loadout.config.items)

    local functionPrivate = functionMenu:addOption(getText("ContextMenu_EasyLoadoutFunctionPrivate"), container,
                                                   EasyLoadoutEvents.setFunctionPrivate, loadout, character)
    addOptionInfo(functionPrivate, getText("ContextMenu_EasyLoadoutFunctionPrivate"),
                  getText("Tooltip_EasyLoadoutFunctionPrivate"), true, loadout.config.private)

    local functionUndress = functionMenu:addOption(getText("ContextMenu_EasyLoadoutFunctionUndress"), container,
                                                   EasyLoadoutEvents.setFunctionUndress, loadout)
    addOptionInfo(functionUndress, getText("ContextMenu_EasyLoadoutFunctionUndress"),
                  getText("Tooltip_EasyLoadoutFunctionUndress"), true, loadout.config.undress)
end

function buildRemoveTagMenu(configMenu, container, easyLoadoutData, loadoutName)
    local optionRemoveTag = configMenu:addOption(getText("ContextMenu_EasyLoadoutConfigRemoveTag"), container,
                                                 EasyLoadoutEvents.removeTag, easyLoadoutData, loadoutName)
    addOptionInfo(optionRemoveTag, getText("ContextMenu_EasyLoadoutConfigRemoveTag"),
                  getText("Tooltip_EasyLoadoutConfigRemoveTag"))
    optionRemoveTag.iconTexture = getTexture(EasyLoadout.icons.remove)
end

function buildManageUIPluginMenu(loadoutMenu, loadout, character, loadoutName, container, easyLoadoutData)
    loadoutMenu:addOption(getText("UI_EasyLoadout_UI_Main_Title"),
                          loadout, EasyLoadoutPluginManageUI.createMenu,
                          character, loadoutName, container, easyLoadoutData)
end

---@param loadoutMenu ISContextMenu
---@param character IsoPlayer
---@param container ItemContainer
---@param easyLoadoutData EasyLoadoutData
---@param loadoutName string
---@param loadout EasyLoadoutDataLoadout
function buildConfigMenu(loadoutMenu, character, container, easyLoadoutData, loadoutName, loadout)
    if EasyLoadoutPluginManageUI ~= nil then
        buildManageUIPluginMenu(loadoutMenu, loadout, character, loadoutName, container, easyLoadoutData)
    else
        local configMenu = loadoutMenu:getNew(loadoutMenu)
        loadoutMenu:addSubMenu(loadoutMenu:addOption(getText("ContextMenu_EasyLoadoutConfig")), configMenu)

        buildLoadoutFunctionsMenu(configMenu, character, container, loadout)
        buildLoadoutTypeMenu(configMenu, container, loadout)
        buildRemoveTagMenu(configMenu, container, easyLoadoutData, loadoutName)
    end
end

---@param loadoutMenu ISContextMenu
---@param character IsoPlayer
---@param container ItemContainer
---@param loadout EasyLoadoutDataLoadout
function buildManageMenu(loadoutMenu, character, container, loadout)
    local manageMenu = loadoutMenu:getNew(loadoutMenu)
    loadoutMenu:addSubMenu(loadoutMenu:addOption(getText("ContextMenu_EasyLoadoutManage")), manageMenu)

    local optionRegisterLoadout = manageMenu:addOption(getText("ContextMenu_EasyLoadoutRegisterLoadout"),
                                                       character, EasyLoadoutEvents.registerLoadout,
                                                       container,
                                                       loadout)
    addOptionInfo(optionRegisterLoadout, getText("ContextMenu_EasyLoadoutRegisterLoadout"),
                  getText("Tooltip_EasyLoadoutRegisterLoadout"))

    local optionRegisterAndStoreLoadout = manageMenu:addOption(getText("ContextMenu_EasyLoadoutRegisterAndStoreLoadout"),
                                                               character,
                                                               EasyLoadoutEvents.registerAndStoreLoadout,
                                                               container, loadout)
    addOptionInfo(optionRegisterAndStoreLoadout, getText("ContextMenu_EasyLoadoutRegisterAndStoreLoadout"),
                  getText("Tooltip_EasyLoadoutRegisterAndStoreLoadout"))

    local optionRemoveLoadout = manageMenu:addOption(getText("ContextMenu_EasyLoadoutRemoveLoadout"),
                                                     container, EasyLoadoutEvents.removeLoadout,
                                                     loadout)
    addOptionInfo(optionRemoveLoadout, getText("ContextMenu_EasyLoadoutRemoveLoadout"),
                  getText("Tooltip_EasyLoadoutRemoveLoadout"))
end

function buildHandleMenu(loadoutMenu, loadout, character, container)
    if loadout.config.apparel or loadout.config.equipment then
        local optionWearLoadout = loadoutMenu:addOption(getText("ContextMenu_EasyLoadoutWearLoadout"),
                                                        character, EasyLoadoutEvents.wearLoadout,
                                                        container,
                                                        loadout)
        addOptionInfo(optionWearLoadout, getText("ContextMenu_EasyLoadoutWearLoadout"),
                      getText("Tooltip_EasyLoadoutWearLoadout"))
    end

    local optionPickUpLoadout = loadoutMenu:addOption(getText("ContextMenu_EasyLoadoutPickUpLoadout"),
                                                      character, EasyLoadoutEvents.pickUpLoadout,
                                                      container,
                                                      loadout)
    addOptionInfo(optionPickUpLoadout, getText("ContextMenu_EasyLoadoutPickUpLoadout"),
                  getText("Tooltip_EasyLoadoutPickUpLoadout"))

    local optionStoreLoadout = loadoutMenu:addOption(getText("ContextMenu_EasyLoadoutStoreLoadout"),
                                                     character, EasyLoadoutEvents.storeLoadout,
                                                     container,
                                                     loadout)
    addOptionInfo(optionStoreLoadout, getText("ContextMenu_EasyLoadoutStoreLoadout"),
                  getText("Tooltip_EasyLoadoutStoreLoadout"))
end

function buildInfoMenu(loadoutMenu, loadout, loadoutName)
    local optionInfo = loadoutMenu:addOption(getText("ContextMenu_EasyLoadoutInfo"))
    optionInfo.toolTip = EasyLoadoutItemUtils.toolTipRegistered(loadout, loadoutName)
end

function buildUpdateMenu(loadoutMenu, loadout, container)
    local optionUpdate = loadoutMenu:addOption(getText("ContextMenu_EasyLoadoutUpdate"),
                          loadout, EasyLoadoutCompatibilityUtils.update, container)

    addOptionInfo(optionUpdate, getText("ContextMenu_EasyLoadoutUpdate"),
                  getText("Tooltip_EasyLoadoutUpdate"))
end

function buildLoadoutMenu(loadoutSubMenu, loadoutName, loadout, character, container, easyLoadoutData)
    local loadoutMenu = loadoutSubMenu:getNew(loadoutSubMenu)
    loadoutSubMenu:addSubMenu(loadoutSubMenu:addOption(loadoutName), loadoutMenu)

    if EasyLoadoutCompatibilityUtils.needUpdate(loadout) then
        buildUpdateMenu(loadoutMenu, loadout, container)
    else
        buildInfoMenu(loadoutMenu, loadout, loadoutName)

        buildHandleMenu(loadoutMenu, loadout, character, container)
        buildManageMenu(loadoutMenu, character, container, loadout)
        buildConfigMenu(loadoutMenu, character, container, easyLoadoutData, loadoutName, loadout)
    end
end

---@param context ISContextMenu
---@param easyLoadoutData EasyLoadoutData
---@param character IsoPlayer
---@param container ItemContainer
function buildLoadoutContextMenu(context, easyLoadoutData, character, container)
    local loadoutSubMenu = context:getNew(context)
    context:addSubMenu(context:addOption(getText("ContextMenu_EasyLoadoutLoadouts")), loadoutSubMenu)

    for loadoutName, loadout in pairs(easyLoadoutData.loadouts) do
        local gameType = getWorld():getGameMode()
        if loadout.config.private == false or loadout.config.player == character:getSteamID()
                or character:isAccessLevel("admin") or gameType ~= "Multiplayer" then
            buildLoadoutMenu(loadoutSubMenu, loadoutName, loadout, character, container, easyLoadoutData)
        end
    end
end

---@param player number
---@param context ISContextMenu
---@param worldObjects IsoObject[]
function worldLoadoutContextMenu(player, context, worldObjects, _)
    local character = getSpecificPlayer(player)
    for loadoutObject, _ in pairs(EasyLoadoutUtils.getLoadoutObjects(worldObjects)) do
        ---@type EasyLoadoutData
        local easyLoadoutData = loadoutObject:getModData().easyLoadout
        if easyLoadoutData and easyLoadoutData.enabled then
            local container = loadoutObject:getContainer();
            buildLoadoutContextMenu(context, easyLoadoutData, character, container)
        end
    end
end

---@param player number
---@param context ISContextMenu
function inventoryLoadoutContextMenu(player, context, items)
    local character = getSpecificPlayer(player)
    items = ISInventoryPane.getActualItems(items)
    for _, item in ipairs(items) do
        local itemId = item:getID()
        ---@type EasyLoadoutData[]
        local loadoutModData = character:getModData().easyLoadout
        if loadoutModData then
            if loadoutModData[itemId] then
                local easyLoadoutData = loadoutModData[itemId]
                if easyLoadoutData and easyLoadoutData.enabled then
                    local container = item:getInventory()
                    buildLoadoutContextMenu(context, easyLoadoutData, character, container)
                end
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(worldLoadoutContextMenu)
Events.OnFillInventoryObjectContextMenu.Add(inventoryLoadoutContextMenu)
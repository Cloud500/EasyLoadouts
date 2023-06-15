---@alias EasyLoadoutModDataContainer {easyLoadout: EasyLoadoutData}
---@alias EasyLoadoutModDataBag {easyLoadout: EasyLoadoutData[]}
---@alias EasyLoadoutData {loadouts: EasyLoadoutDataLoadout[], enabled: boolean, type: string}
---@alias EasyLoadoutDataLoadout {config: EasyLoadoutDataConfig, apparel: EasyLoadoutDataApparel[], equipment: EasyLoadoutDataEquipment[], items: EasyLoadoutDataItems[], registered: boolean}
---@alias EasyLoadoutDataApparel {item: string, attachedSlot: string}
---@alias EasyLoadoutDataEquipment {item: string, attachedSlot: string, slotType: string}
---@alias EasyLoadoutDataItems {item: string}
---@alias EasyLoadoutDataConfig {type: string, private: boolean, player: string, undress: boolean, apparel: boolean, equipment: boolean, items: boolean,}

require "EasyLoadout"
local EasyLoadoutUtils = require("utils/EasyLoadoutUtils")
local EasyLoadoutModDataUtils = {}

---@return EasyLoadoutDataLoadout
function EasyLoadoutModDataUtils.createLoadoutData()
    local test = EasyLoadout

    local loadoutData = {
        registered = false,
        apparel    = {},
        equipment  = {},
        items      = {},
        config     = {
            type      = EasyLoadout.getType(),
            private   = false,
            player    = nil,
            undress   = EasyLoadout.defaults.undress,
            apparel   = EasyLoadout.defaults.apparel,
            equipment = EasyLoadout.defaults.equipment,
            items     = EasyLoadout.defaults.items,
        },
    }
    return loadoutData
end

---@param type string
---@return EasyLoadoutData
function EasyLoadoutModDataUtils.createModData(type)
    local loadoutModData = {}
    loadoutModData.enabled = false
    loadoutModData.loadouts = {}
    loadoutModData.type = type
    return loadoutModData
end

---@param container ItemContainer
---@return EasyLoadoutData
function EasyLoadoutModDataUtils.createOrGetModDataContainer(container)
    ---@type EasyLoadoutModDataContainer
    local modData = container:getModData()
    if modData.easyLoadout == nil then
        modData.easyLoadout = EasyLoadoutModDataUtils.createModData("container")
    end
    return modData.easyLoadout
end

---@param character IsoPlayer
---@param bag_container ItemContainer
---@return EasyLoadoutData
function EasyLoadoutModDataUtils.createOrGetModDataBag(character, bag_container)
    ---@type EasyLoadoutModDataBag
    local modData = character:getModData()
    if modData.easyLoadout == nil then
        modData.easyLoadout = {}
    end
    local bag_id = bag_container:getContainingItem():getID()
    if modData.easyLoadout[bag_id] == nil or not modData.easyLoadout[bag_id].enabled then
        modData.easyLoadout[bag_id] = EasyLoadoutModDataUtils.createModData("bag")
    end
    local test = modData.easyLoadout[bag_id]
    return modData.easyLoadout[bag_id]
end

---@param character IsoPlayer
---@param container ItemContainer
---@return EasyLoadoutData
function EasyLoadoutModDataUtils.createOrGetModData(character, container)
    local parent = EasyLoadoutUtils.getParentContainer(container)
    local modData = nil
    if parent then
        --Container
        modData = EasyLoadoutModDataUtils.createOrGetModDataContainer(parent)
    else
        --Bag
        modData = EasyLoadoutModDataUtils.createOrGetModDataBag(character, container)
    end
    return modData
end

---@param loadout EasyLoadoutDataLoadout
---@param type string
function EasyLoadoutModDataUtils.setLoadoutType(loadout, type)
    if loadout then
        loadout.items = {}
        loadout.registered = false
        loadout.config.type = type
    end
end

---@param container ItemContainer
---@param item InventoryItem
---@param remove boolean
function EasyLoadoutModDataUtils.transmitModData(container, item, remove)
    if isClient() and EasyLoadoutUtils.hasParentContainer(container) then
        container:getParent():transmitModData()
        if item then
            if remove then
                container:removeItemOnServer(item)
            else
                container:addItemOnServer(item)
            end
        end
    end
end

return EasyLoadoutModDataUtils
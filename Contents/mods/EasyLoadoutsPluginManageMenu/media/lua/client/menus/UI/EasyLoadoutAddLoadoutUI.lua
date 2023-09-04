local EasyLoadoutUtils = require("utils/EasyLoadoutUtils")
local EasyLoadoutItemUtils = require("utils/EasyLoadoutItemUtils")

local function isInteger(value)
    return not (value == "" or value == "0" or value:find("%D"))
end

local function addLoadoutUIButtonClick(_, args)
    ---@type EasyLoadoutAddLoadoutUI
    local self = args['self']
    self:changeLoadout()
    self.easyLoadoutUI:update()
end

---@class EasyLoadoutAddLoadoutUI
local EasyLoadoutAddLoadoutUI = {}
EasyLoadoutAddLoadoutUI.__index = EasyLoadoutAddLoadoutUI

---@param loadout EasyLoadoutDataLoadout
---@param character IsoPlayer
---@return EasyLoadoutAddLoadoutUI
function EasyLoadoutAddLoadoutUI:new(loadout, character, easyLoadoutUI)
    ---@type EasyLoadoutAddLoadoutUI
    local o = {}
    setmetatable(o, self)

    ---@type EasyLoadoutDataLoadout
    o.loadout = loadout

    ---@type IsoPlayer
    o.character = character

    o.easyLoadoutUI = easyLoadoutUI

    o.UI = nil

    ---@type boolean
    o.isOpen = false

    o.inventory = {}
    o.inventory.apparel = {}
    o.inventory.equipment = {}
    o.inventory.items = {}

    o:loadInventoryItems()
    o:buildAddLoadoutMenu()
    return o
end

---@private
function EasyLoadoutAddLoadoutUI.changeLoadoutData(UIDataID, UIData, loadoutData, prefix, type)
    local UIDataPrefix = "T_" .. prefix .. "_"
    if string.match(UIDataID, UIDataPrefix) then
        if type == "select" then
            if UIData:getValue() then
                table.insert(loadoutData, UIData.loadout)
            end
        elseif type == "input" then
            local value = UIData:getValue()
            local item_name = string.gsub(UIDataID, UIDataPrefix, '')
            if isInteger(value) then
                UIData.loadout.count = tonumber(value)
                loadoutData[item_name] = UIData.loadout
            end
        end
    end
end

---@private
function EasyLoadoutAddLoadoutUI:changeLoadout()
    for UIDataID, UIData in pairs(self.UI) do
        self.changeLoadoutData(UIDataID, UIData, self.loadout.apparel, "AP", "select")
        self.changeLoadoutData(UIDataID, UIData, self.loadout.equipment, "EQ", "select")
        self.changeLoadoutData(UIDataID, UIData, self.loadout.items, "IT", "input")
    end
end

function EasyLoadoutAddLoadoutUI:loadInventoryItems()
    local container = self.character:getInventory()
    for i = 0, container:getItems():size() - 1 do
        local item = container:getItems():get(i)
        local itemType = EasyLoadoutItemUtils.getItemType(item)
        if not EasyLoadoutItemUtils.checkIfAlreadyRegistered(item, self.loadout) then
            if itemType == "apparel" then
                table.insert(self.inventory.apparel, {
                    item         = EasyLoadoutItemUtils.getItemIdOrName(item, self.loadout),
                    attachedSlot = "",
                    fullType     = item:getFullType(),
                })

            elseif itemType == "equipment" then
                table.insert(self.inventory.equipment, {
                    item         = EasyLoadoutItemUtils.getItemIdOrName(item, self.loadout),
                    attachedSlot = item:getAttachedSlot(),
                    slotType     = EasyLoadoutItemUtils.getAttachedSlot(self.character, item),
                    fullType     = item:getFullType(),
                })
            end

            if not EasyLoadoutItemUtils.checkIfAlreadyRegistered(item, self.loadout, "name") then
                if itemType == "item" then
                    if self.inventory.items[item:getName()] ~= nil then
                        self.inventory.items[item:getName()].count = self.inventory.items[item:getName()].count + 1
                    else
                        self.inventory.items[item:getName()] = {
                            item     = item:getName(),
                            fullType = item:getFullType(),
                            count    = 1
                        }
                    end

                end
            end
        end
    end
end

---@private
function EasyLoadoutAddLoadoutUI:buildInventoryDataList(inventoryData, prefix, type)
    local id = 1
    if inventoryData ~= nil and EasyLoadoutUtils.getTableLength(inventoryData) >= 1 then
        for _, itemData in pairs(inventoryData) do
            local item = InventoryItemFactory.CreateItem(itemData.fullType)
            local name = item:getDisplayName()

            if type == "select" then
                local idString = prefix .. "_" .. id
                self.UI:addText("Label_" .. idString, name, _, "Right")
                self.UI:addTickBox("T_" .. idString, "Left")
                self.UI["T_" .. idString].loadout = itemData
            elseif type == "input" then
                local idString = prefix .. "_" .. itemData.item
                self.UI:addText("Label_" .. idString, name .. " ", _, "Right")
                self.UI:addEntry("T_" .. idString, "")
                self.UI["T_" .. idString].loadout = itemData
            end
            self.UI:nextLine()
            id = id + 1
        end

        else
        self.UI:addText("Label_" .. prefix, getText("UI_EasyLoadout_UI_None"), _, "Center")
        self.UI:nextLine()
    end
end

---@private
function EasyLoadoutAddLoadoutUI:buildAddLoadoutMenuData(name, prefix, inventoryData, type)
    self.UI:addText(prefix .. "_TITLE", name, "Large", "Center")
    self.UI:nextLine()
    self.UI:addEmpty(prefix .. "_SPACE")
    self.UI:nextLine()
    self:buildInventoryDataList(inventoryData, prefix, type)
    self.UI:addEmpty(prefix .. "_SPACE")
    self.UI:nextLine()
end

---@private
function EasyLoadoutAddLoadoutUI:buildAddLoadoutMenu()
    self.UI = NewUI()

    self.UI:setTitle(getText("UI_EasyLoadout_UI_Add_Loadout"))
    self.UI:setWidthPercent(0.15)

    if self.loadout.config.apparel then
        self:buildAddLoadoutMenuData(getText("UI_EasyLoadout_ModOptionApparel"), "AP", self.inventory.apparel, "select")
    end
    if self.loadout.config.equipment then
        self:buildAddLoadoutMenuData(getText("UI_EasyLoadout_ModOptionEquipment"), "EQ", self.inventory.equipment, "select")
    end
    if self.loadout.config.items then
        self:buildAddLoadoutMenuData(getText("UI_EasyLoadout_ModOptionItems"), "IT", self.inventory.items, "input")
    end

    self.UI:addButton("b1", getText("UI_EasyLoadout_UI_Add"), addLoadoutUIButtonClick)
    self.UI['b1']:addArg("self", self)
    self.UI:nextLine()

    self.UI:addEmpty("SPACE")
    self.UI:nextLine()

    self.UI:saveLayout()
    self.UI:close()
end

function EasyLoadoutAddLoadoutUI:open()
    self.UI:open()
    if self.easyLoadoutUI ~= nil and self.easyLoadoutUI.UI ~= nil then
        self.UI:isSubUIOf(self.easyLoadoutUI.UI)
        self.UI:setPositionPixel(self.easyLoadoutUI.UI:getX() - self.UI:getWidth(), self.easyLoadoutUI.UI:getY())
    end
    self.isOpen = true
end

function EasyLoadoutAddLoadoutUI:close()
    self.UI:close()
    self.isOpen = false
end

function EasyLoadoutAddLoadoutUI:getIsVisible()
    if self.UI:getIsVisible() then
        return true
    end
    return false
end

return EasyLoadoutAddLoadoutUI
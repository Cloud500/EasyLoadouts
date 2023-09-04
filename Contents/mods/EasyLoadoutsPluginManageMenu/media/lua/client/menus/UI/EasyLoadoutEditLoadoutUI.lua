local EasyLoadoutUtils = require("utils/EasyLoadoutUtils")

local function isInteger(value)
    return not (value == "" or value == "0" or value:find("%D"))
end

local function editLoadoutUIButtonClick(_, args)
    ---@type EasyLoadoutEditLoadoutUI
    local self = args['self']
    self:changeLoadout()
    self.easyLoadoutUI:update()
end

---@class EasyLoadoutEditLoadoutUI
local EasyLoadoutEditLoadoutUI = {}
EasyLoadoutEditLoadoutUI.__index = EasyLoadoutEditLoadoutUI

---@param loadout EasyLoadoutDataLoadout
---@return EasyLoadoutEditLoadoutUI
function EasyLoadoutEditLoadoutUI:new(loadout, easyLoadoutUI)
    ---@type EasyLoadoutEditLoadoutUI
    local o = {}
    setmetatable(o, self)

    ---@type EasyLoadoutDataLoadout
    o.loadout = loadout

    o.easyLoadoutUI = easyLoadoutUI

    o.UI = nil

    ---@type boolean
    o.isOpen = false

    o:buildEditLoadoutMenu()
    return o
end

---@private
function EasyLoadoutEditLoadoutUI.changeLoadoutData(UIDataID, UIData, loadoutData, prefix, type, dummy_id_rel)
    local UIDataPrefix = "T_" .. prefix .. "_"
    if string.match(UIDataID, UIDataPrefix) then
        if type == "select" then
            if not UIData:getValue() then
                local item_id_str = string.gsub(UIDataID, UIDataPrefix, '')
                local item_id = tonumber(item_id_str)
                table.remove(loadoutData, item_id - dummy_id_rel)
                --print("Delete: " .. loadoutData[item_id].item)
                dummy_id_rel = dummy_id_rel + 1
            end
        elseif type == "input" then
            local value = UIData:getValue()
            local item_name = string.gsub(UIDataID, UIDataPrefix, '')
            if isInteger(value) then
                loadoutData[item_name].count = tonumber(value)
                --print("Change " .. item_name .. ": from " .. loadoutData[item_name].count .. " to " .. tonumber(value))
            else
                loadoutData[item_name] = nil
                --print("Delete: " .. item_name)
            end
        end
    end
    return dummy_id_rel
end

---@private
function EasyLoadoutEditLoadoutUI:changeLoadout()
    local dummy_id_rel_apparel = 0
    local dummy_id_rel_equipment = 0
    for UIDataID, UIData in pairs(self.UI) do
        dummy_id_rel_apparel = self.changeLoadoutData(UIDataID, UIData, self.loadout.apparel, "AP", "select",
                                                      dummy_id_rel_apparel)
        dummy_id_rel_equipment = self.changeLoadoutData(UIDataID, UIData, self.loadout.equipment, "EQ", "select",
                                                        dummy_id_rel_equipment)
        self.changeLoadoutData(UIDataID, UIData, self.loadout.items, "IT", "input", 0)
    end
end

---@private
function EasyLoadoutEditLoadoutUI:buildLoadoutDataList(loadoutData, prefix, type)
    local id = 1
    if loadoutData ~= nil and EasyLoadoutUtils.getTableLength(loadoutData) >= 1 then
        for _, itemData in pairs(loadoutData) do
            local item = InventoryItemFactory.CreateItem(itemData.fullType)
            local name = item:getDisplayName()

            if type == "select" then
                local idString = prefix .. "_" .. id
                self.UI:addText("Label_" .. idString, name, _, "Right")
                self.UI:addTickBox("T_" .. idString, "Left")
                self.UI["T_" .. idString]:setValue(true)
            elseif type == "input" then
                local idString = prefix .. "_" .. itemData.item
                self.UI:addText("Label_" .. idString, name .. " ", _, "Right")
                self.UI:addEntry("T_" .. idString, tostring(itemData.count))
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
function EasyLoadoutEditLoadoutUI:buildEditLoadoutMenuData(name, prefix, loadoutData, type)
    self.UI:addText(prefix .. "_TITLE", name, "Large", "Center")
    self.UI:nextLine()
    self.UI:addEmpty(prefix .. "_SPACE")
    self.UI:nextLine()
    self:buildLoadoutDataList(loadoutData, prefix, type)
    self.UI:addEmpty(prefix .. "_SPACE")
    self.UI:nextLine()
end

---@private
function EasyLoadoutEditLoadoutUI:buildEditLoadoutMenu()
    self.UI = NewUI()

    self.UI:setTitle(getText("UI_EasyLoadout_UI_Edit_Loadout"))
    self.UI:setWidthPercent(0.15)

    if self.loadout.config.apparel then
        self:buildEditLoadoutMenuData(getText("UI_EasyLoadout_ModOptionApparel"), "AP", self.loadout.apparel, "select")
    end
    if self.loadout.config.equipment then
        self:buildEditLoadoutMenuData(getText("UI_EasyLoadout_ModOptionEquipment"), "EQ", self.loadout.equipment, "select")
    end
    if self.loadout.config.items then
        self:buildEditLoadoutMenuData(getText("UI_EasyLoadout_ModOptionItems"), "IT", self.loadout.items, "input")
    end

    self.UI:addButton("BUTTON_1", getText("UI_EasyLoadout_UI_Update"), editLoadoutUIButtonClick)
    self.UI['BUTTON_1']:addArg("self", self)
    self.UI:nextLine()

    self.UI:addEmpty("SPACE")
    self.UI:nextLine()

    self.UI:saveLayout()

    self.UI:close()
end

function EasyLoadoutEditLoadoutUI:open()
    self.UI:open()
    if self.easyLoadoutUI ~= nil and self.easyLoadoutUI.UI ~= nil then
        self.UI:isSubUIOf(self.easyLoadoutUI.UI)
        self.UI:setPositionPixel(self.easyLoadoutUI.UI:getX() + self.easyLoadoutUI.UI:getWidth(), self.easyLoadoutUI.UI:getY())
    end
    self.isOpen = true
end

function EasyLoadoutEditLoadoutUI:close()
    self.UI:close()
    self.isOpen = false
end

function EasyLoadoutEditLoadoutUI:getIsVisible()
    if self.UI:getIsVisible() then
        return true
    end
    return false
end

return EasyLoadoutEditLoadoutUI
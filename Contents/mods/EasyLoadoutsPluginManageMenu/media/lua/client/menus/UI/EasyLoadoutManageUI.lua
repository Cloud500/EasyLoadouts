local EasyLoadoutUtils = require("utils/EasyLoadoutUtils")
local EasyLoadoutModDataUtils = require("utils/EasyLoadoutModDataUtils")
local EasyLoadoutEvents = require("EasyLoadoutEvents")
local EasyLoadoutEditLoadoutUI = require("menus/UI/EasyLoadoutEditLoadoutUI")
local EasyLoadoutAddLoadoutUI = require("menus/UI/EasyLoadoutAddLoadoutUI")

local function mainUICloseClick(_, args)
    ---@type EasyLoadoutManageUI
    local self = args['self']
    self:close()
end

local function mainUISaveConfigClick(_, args)
    ---@type EasyLoadoutManageUI
    local self = args['self']
    self:updateConfig()
end

local function mainUIEditLoadoutButtonClick(_, args)
    ---@type EasyLoadoutManageUI
    local self = args["self"]
    self:ManageEditLoadoutMenu()
end

local function mainUIAddLoadoutButtonClick(_, args)
    ---@type EasyLoadoutManageUI
    local self = args["self"]
    self:ManageAddLoadoutMenu()
end

local function mainUIRemoveTagButtonClick(_, args)
    ---@type EasyLoadoutManageUI
    local self = args["self"]
    self:removeTag()
end

---@class EasyLoadoutManageUI
---@field loadout EasyLoadoutDataLoadout
---@field character IsoPlayer
---@field editLoadoutUI EasyLoadoutEditLoadoutUI
local EasyLoadoutManageUI = {}
EasyLoadoutManageUI.__index = EasyLoadoutManageUI

---@param loadout EasyLoadoutDataLoadout
---@param character IsoPlayer
---@return EasyLoadoutManageUI
function EasyLoadoutManageUI:new(loadout, character, loadoutName, container, easyLoadoutData)
    ---@type EasyLoadoutManageUI
    local o = {}
    setmetatable(o, self)

    ---@type string
    o.loadoutName = loadoutName

    ---@type EasyLoadoutDataLoadout
    o.loadout = loadout

    ---@type IsoPlayer
    o.character = character

    ---@type ItemContainer
    o.container = container

    ---@type EasyLoadoutData
    o.easyLoadoutData = easyLoadoutData

    o.UI = NewUI()

    ---@type EasyLoadoutEditLoadoutUI
    o.editLoadoutUI = nil

    ---@type EasyLoadoutAddLoadoutUI
    o.addLoadoutUI = nil
    return o
end

function EasyLoadoutManageUI:saveModData()
    EasyLoadoutModDataUtils.transmitModData(self.container)
end

function EasyLoadoutManageUI:UpdateEditLoadoutMenu()
    local visible = false
    local xPos, yPos
    if self.editLoadoutUI ~= nil then
        visible = self.editLoadoutUI:getIsVisible()
    end

    if visible then
        xPos = self.editLoadoutUI.UI:getX()
        yPos = self.editLoadoutUI.UI:getY()
        self.editLoadoutUI:close()
    end

    self.editLoadoutUI = nil

    if visible then
        self.editLoadoutUI = EasyLoadoutEditLoadoutUI:new(self.loadout, self)
        self.editLoadoutUI:open()
        self.editLoadoutUI.UI:setPositionPixel(xPos, yPos)
    end
end

function EasyLoadoutManageUI:UpdateAddLoadoutMenu()
    local visible = false
    local xPos, yPos
    if self.addLoadoutUI ~= nil then
        visible = self.addLoadoutUI:getIsVisible()
    end

    if visible then
        xPos = self.addLoadoutUI.UI:getX()
        yPos = self.addLoadoutUI.UI:getY()
        self.addLoadoutUI:close()
    end

    self.addLoadoutUI = nil

    if visible then
        self.addLoadoutUI = EasyLoadoutAddLoadoutUI:new(self.loadout, self.character, self)
        self.addLoadoutUI:open()
        self.addLoadoutUI.UI:setPositionPixel(xPos, yPos)
    end
end

function EasyLoadoutManageUI:update()
    self:saveModData()
    self:UpdateEditLoadoutMenu()
    self:UpdateAddLoadoutMenu()
end

function EasyLoadoutManageUI:ManageEditLoadoutMenu()
    if self.editLoadoutUI == nil then
        self.editLoadoutUI = EasyLoadoutEditLoadoutUI:new(self.loadout, self)
    end

    if self.editLoadoutUI:getIsVisible() then
        self.editLoadoutUI:close()
        self.editLoadoutUI = nil
    else
        self.editLoadoutUI:open()
    end
end

function EasyLoadoutManageUI:ManageAddLoadoutMenu()
    if self.addLoadoutUI == nil then
        self.addLoadoutUI = EasyLoadoutAddLoadoutUI:new(self.loadout, self.character, self)
    end

    if self.addLoadoutUI:getIsVisible() then
        self.addLoadoutUI:close()
        self.addLoadoutUI = nil
    else
        self.addLoadoutUI:open()
    end
end



function EasyLoadoutManageUI:freeLine()
    self.UI:addEmpty("SPACE" .. EasyLoadoutUtils.getTableLength(self.UI))
    self.UI:nextLine()
end

---@private
function EasyLoadoutManageUI:buildMainMenu()
    self.UI:setTitle(getText("UI_EasyLoadout_UI_Main_Title"))

    self.UI:addText("MANAGE_LOADOUT_TITLE", getText("ContextMenu_EasyLoadoutManage"), "Large", "Center")
    self.UI:nextLine()

    self:freeLine()

    self.UI:addButton("add_loadout", getText("UI_EasyLoadout_UI_Add_Loadout"), mainUIAddLoadoutButtonClick)
    self.UI["add_loadout"]:addArg("self", self)
    self.UI:nextLine()

    self.UI:addButton("edit_loadout", getText("UI_EasyLoadout_UI_Edit_Loadout"), mainUIEditLoadoutButtonClick)
    self.UI["edit_loadout"]:addArg("self", self)
    self.UI:nextLine()

    self:freeLine()

    self.UI:addText("CONFIG_LOADOUT_TITLE", getText("ContextMenu_EasyLoadoutFunctions"), "Large", "Center")
    self.UI:nextLine()

    self:freeLine()

    self.UI:addText("Label_Apparel", getText("ContextMenu_EasyLoadoutFunctionApparel"), _, "Right")
    self.UI:addTickBox("T_Apparel", "Left")
    self.UI["T_Apparel"]:setValue(self.loadout.config.apparel)
    self.UI:nextLine()
    self.UI:addText("Label_Equipment", getText("ContextMenu_EasyLoadoutFunctionEquipment"), _, "Right")
    self.UI:addTickBox("T_Equipment", "Left")
    self.UI["T_Equipment"]:setValue(self.loadout.config.equipment)
    self.UI:nextLine()
    self.UI:addText("Label_Items", getText("ContextMenu_EasyLoadoutFunctionItem"), _, "Right")
    self.UI:addTickBox("T_Items", "Left")
    self.UI["T_Items"]:setValue(self.loadout.config.items)
    self.UI:nextLine()

    self:freeLine()

    self.UI:addText("Label_Private", getText("ContextMenu_EasyLoadoutFunctionPrivate"), _, "Right")
    self.UI:addTickBox("T_Private", "Left")
    self.UI["T_Private"]:setValue(self.loadout.config.private)
    self.UI:nextLine()

    self.UI:addText("Label_Undress", getText("ContextMenu_EasyLoadoutFunctionUndress"), _, "Right")
    self.UI:addTickBox("T_Undress", "Left")
    self.UI["T_Undress"]:setValue(self.loadout.config.undress)
    self.UI:nextLine()

    self:freeLine()

    self.UI:addText("Label_Type", getText("UI_EasyLoadout_ModOptionType") .. " ", _, "Right")
    self.UI:addComboBox("T_Type", {
        getText("UI_EasyLoadout_ModOptionType_Id"),
        getText("UI_EasyLoadout_ModOptionType_Name")
    })

    self.UI:nextLine()

    self:freeLine()
    self:freeLine()

    self.UI:addButton("remove_tag", getText("UI_EasyLoadout_UI_Remove_Tag"), mainUIRemoveTagButtonClick)
    self.UI["remove_tag"]:addArg("self", self)
    self.UI:nextLine()

    self:freeLine()
    self:freeLine()

    self.UI:addButton("save_config", getText("UI_EasyLoadout_UI_Save_Config"), mainUISaveConfigClick)
    self.UI["save_config"]:addArg("self", self)
    self.UI:addButton("close_menu", getText("UI_EasyLoadout_UI_Close"), mainUICloseClick)
    self.UI["close_menu"]:addArg("self", self)
    self.UI:nextLine()
    self:freeLine()
end

function EasyLoadoutManageUI:showMainMenu()
    self:buildMainMenu()
    self.UI:saveLayout()
    if self.loadout.config.type == "name" then
        self.UI["T_Type"]:select(getText("UI_EasyLoadout_ModOptionType_Name"))
    elseif self.loadout.config.type == "id" then
        self.UI["T_Type"]:select(getText("UI_EasyLoadout_ModOptionType_Id"))
    end
end

function EasyLoadoutManageUI:updateConfig()
    self.loadout.config.apparel = self.UI["T_Apparel"]:getValue()
    self.loadout.config.equipment = self.UI["T_Equipment"]:getValue()
    self.loadout.config.items = self.UI["T_Items"]:getValue()

    self.loadout.config.private = self.UI["T_Private"]:getValue()
    self.loadout.config.undress = self.UI["T_Undress"]:getValue()

    if self.UI["T_Type"]:getValue() == getText("UI_EasyLoadout_ModOptionType_Name") then
        self.loadout.config.type = "name"
    elseif self.UI["T_Type"]:getValue() == getText("UI_EasyLoadout_ModOptionType_Id") then
        self.loadout.config.type = "id"
    end
    self:saveModData()
end

function EasyLoadoutManageUI:removeTag()
    EasyLoadoutEvents.removeTag(self.container, self.easyLoadoutData, self.loadoutName)
    self:close()
end

function EasyLoadoutManageUI:close()
    self.UI:close()
end

return EasyLoadoutManageUI
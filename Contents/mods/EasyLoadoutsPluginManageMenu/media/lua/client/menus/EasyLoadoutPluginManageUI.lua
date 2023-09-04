local EasyLoadoutManageUI = require("menus/UI/EasyLoadoutManageUI")

local EasyLoadoutPluginManageUI = {}

function EasyLoadoutPluginManageUI.createMenu(loadout, character, loadoutName, container, easyLoadoutData)
    local menu = EasyLoadoutManageUI:new(loadout, character, loadoutName, container, easyLoadoutData)
    menu:showMainMenu()
end

return EasyLoadoutPluginManageUI
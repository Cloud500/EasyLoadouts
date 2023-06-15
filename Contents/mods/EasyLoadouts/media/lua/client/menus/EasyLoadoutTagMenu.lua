local EasyLoadoutUtils  = require("utils/EasyLoadoutUtils")
local EasyLoadoutEvents = require("EasyLoadoutEvents")

---@param player number
---@param context ISContextMenu
---@param items InventoryItem[]
function tagContextMenu(player, context, items)
    local character = getSpecificPlayer(player)
    items           = ISInventoryPane.getActualItems(items)
    for _, item in ipairs(items) do
        if item:getFullType() == "EasyLoadout.LoadoutNote" then
            local optionApplyTag = context:addOption(getText("ContextMenu_EasyLoadoutApplyTag"), player,
                                                     EasyLoadoutEvents.applyTag, item)
            if not EasyLoadoutUtils.checkIfContainerAllowed(character, item) then
                local toolTip               = ISWorldObjectContextMenu.addToolTip()
                toolTip.description         = getText("Tooltip_EasyLoadoutApplyTagNotAllowed")
                optionApplyTag.toolTip      = toolTip
                optionApplyTag.notAvailable = true
            end
            local optionRename = context:addOption(getText("ContextMenu_EasyLoadoutRenameTag"), player,
                                                   EasyLoadoutEvents.renameTag, item);
            break
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(tagContextMenu)
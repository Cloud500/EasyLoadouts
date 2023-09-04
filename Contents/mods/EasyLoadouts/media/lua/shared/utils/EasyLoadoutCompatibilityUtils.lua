require "EasyLoadout"
local EasyLoadoutPatch1 = require("utils/CompatibilityPatches/EasyLoadoutPatch1")

local EasyLoadoutCompatibilityUtils = {}

---@param loadout EasyLoadoutDataLoadout
---@return boolean
function EasyLoadoutCompatibilityUtils.needUpdate(loadout)
    if loadout.internalVersion == nil then
        loadout.internalVersion = 1
    end

    if loadout.internalVersion < EasyLoadout.internalVersion then
        return true
    else
        return false
    end
end

---@param loadout EasyLoadoutDataLoadout
---@param container ItemContainer
function EasyLoadoutCompatibilityUtils.update(loadout, container)
    if loadout.internalVersion == 1 then
        EasyLoadoutPatch1:patch(loadout, container)
        loadout.internalVersion = 2
    end
end

return EasyLoadoutCompatibilityUtils
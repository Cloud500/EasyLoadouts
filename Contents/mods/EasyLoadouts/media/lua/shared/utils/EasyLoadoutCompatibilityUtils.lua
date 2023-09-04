require "EasyLoadout"
local EasyLoadoutPatch1 = require("CompatibilityPatches/EasyLoadoutPatch1")

local EasyLoadoutCompatibilityUtils = {}

---@param loadout EasyLoadoutDataLoadout
---@return boolean
function EasyLoadoutCompatibilityUtils.needUpdate(loadout)
    if loadout.internalVersion ~= nil or loadout.internalVersion < EasyLoadout.internalVersion then
        return true
    else
        return false
    end
end

---@param loadout EasyLoadoutDataLoadout
---@param container ItemContainer
function EasyLoadoutCompatibilityUtils.update(loadout, container)
    if loadout.internalVersion ~= nil or loadout.internalVersion == 1 then
        EasyLoadoutPatch1:patch(loadout, container)
    end
end
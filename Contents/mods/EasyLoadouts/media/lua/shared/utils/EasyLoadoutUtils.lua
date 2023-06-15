local EasyLoadoutUtils = {}

---@param container ItemContainer
---@return boolean
function EasyLoadoutUtils.hasParentContainer(container)
    local parent = container:getParent()
    if parent then
        return true
    else
        return false
    end
end

---@param container ItemContainer
---@return ItemContainer | nil
function EasyLoadoutUtils.getParentContainer(container)
    if EasyLoadoutUtils.hasParentContainer(container) then
        return container:getParent()
    else
        return nil
    end
end


---@param tbl table
---@param value any
function EasyLoadoutUtils.tableContains(tbl, value)
    local found = nil
    if EasyLoadoutUtils.getTableLength(tbl) == 0 then
        return found
    end
    for _, v in pairs(tbl) do
        if v == value then
            found = true
        end
    end
    return found
end

---@param table table
---@return number
function EasyLoadoutUtils.getTableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

---@param worldObjects IsoObject[]
---@return table
function EasyLoadoutUtils.getLoadoutWorldObjects(worldObjects)
    local loadoutObjects = {}
    for _, worldObject in ipairs(worldObjects) do
        if worldObject and worldObject:getContainer() and loadoutObjects[worldObject] == nil then
            loadoutObjects[worldObject] = 1
        end
    end
    return loadoutObjects
end

---@param loadoutObjects table
---@return table
function EasyLoadoutUtils.getLoadoutSquare(loadoutObjects)
    local square = clickedSquare
    if square then
        if square:getObjects() then
            local worldObjects = square:getObjects()
            for i = 0, worldObjects:size() - 1 do
                local obj = worldObjects:get(i)
                if obj and obj:getContainer() and loadoutObjects[obj] == nil then
                    loadoutObjects[obj] = 1
                end
            end
        end
    end
    return loadoutObjects
end

---@param worldObjects IsoObject[]
---@return table
function EasyLoadoutUtils.getLoadoutObjects(worldObjects)
    local loadoutObjects = EasyLoadoutUtils.getLoadoutWorldObjects(worldObjects)
    return EasyLoadoutUtils.getLoadoutSquare(loadoutObjects)
end

---@param character IsoPlayer
---@param item InventoryItem
---@return boolean
function EasyLoadoutUtils.checkIfContainerAllowed(character, item)
    if character:getInventory() == item:getContainer() then
        return false
    elseif item:getContainer():getType() == "floor" then
        return false
    elseif instanceof(item:getContainer():getParent(), "BaseVehicle") then
        return false
    else
        return true
    end
end

return EasyLoadoutUtils
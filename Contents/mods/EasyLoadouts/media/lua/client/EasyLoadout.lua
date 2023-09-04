EasyLoadout = {}

EasyLoadout.name = 'EasyLoadout'
EasyLoadout.author = 'Cloud500'
EasyLoadout.version = 'v0.6.0'
EasyLoadout.internalVersion = 2

EasyLoadout.defaults = {
    type      = 2,
    undress   = true,
    apparel   = true,
    equipment = true,
    items     = false,
}

EasyLoadout.icons = {
    on     = "media/textures/el_on.png",
    off    = "media/textures/el_off.png",
    remove = "media/textures/el_remove.png",
}

function EasyLoadout.init()
    local output = string.format("Mod: %s %s loaded.", EasyLoadout.name, EasyLoadout.version)
    print(output)
end

function EasyLoadout.getType()
    if EasyLoadout.defaults.type == 1 then
        return "id"
    elseif EasyLoadout.defaults.type == 2 then
        return "name"
    end
    return "id"
end

function EasyLoadout.loadMModOptions()
    if ModOptions and ModOptions.getInstance then
        local settings = ModOptions:getInstance(EasyLoadout.defaults, "EasyLoadout", "Easy Loadout")
        ModOptions:loadFile()

        local modOptionType = settings:getData("type")
        modOptionType.name = "UI_EasyLoadout_ModOptionType"
        modOptionType.tooltip = "UI_EasyLoadout_Tooltip_ModOptionType"
        modOptionType[1] = getText("UI_EasyLoadout_ModOptionType_Id")
        modOptionType[2] = getText("UI_EasyLoadout_ModOptionType_Name")

        local modOptionUndress = settings:getData("undress")
        modOptionUndress.name = "UI_EasyLoadout_ModOptionUndress"
        modOptionUndress.tooltip = "UI_EasyLoadout_Tooltip_ModOptionUndress"

        local modOptionApparel = settings:getData("apparel")
        modOptionApparel.name = "UI_EasyLoadout_ModOptionApparel"
        modOptionApparel.tooltip = "UI_EasyLoadout_Tooltip_ModOptionApparel"

        local modOptionEquipment = settings:getData("equipment")
        modOptionEquipment.name = "UI_EasyLoadout_ModOptionEquipment"
        modOptionEquipment.tooltip = "UI_EasyLoadout_Tooltip_ModOptionEquipment"

        local modOptionItems = settings:getData("items")
        modOptionItems.name = "UI_EasyLoadout_ModOptionItems"
        modOptionItems.tooltip = "UI_EasyLoadout_Tooltip_ModOptionItems"
    end
end

Events.OnGameStart.Add(EasyLoadout.init)

EasyLoadout.loadMModOptions()
# Easy Loadouts

![Version](https://img.shields.io/badge/Version-0.2.1-orange?style=plastic)
[![Steam Favorites](https://img.shields.io/steam/favorites/2982771622?logo=steam&style=plastic)](https://steamcommunity.com/sharedfiles/filedetails/?id=2982771622)
[![Steam Subscriptions](https://img.shields.io/steam/subscriptions/2982771622?logo=steam&style=plastic)](https://steamcommunity.com/sharedfiles/filedetails/?id=2982771622)

Mod for Project Zomboid to equip apparel/equipment/items easily.

Inspired by the excellent mod [Easy Outfits](https://steamcommunity.com/sharedfiles/filedetails/?id=2927625589)
by [Cosmic](https://steamcommunity.com/profiles/76561198041121447) I wrote an "extended version".

**Features:**

- Manage apparel
- Manage equipment (weapons/tools)
- Manage items
- Save apparel/equipment by ID or by name
- Loadout can be set to private
- Settings adjustable for each Loadout
- Default Loadout settings via [Mod Options](https://steamcommunity.com/sharedfiles/filedetails/?id=2169435993)
- Automatic Hotbar equipping

## Quick How to

1. Craft a Loadout Note
2. (Optional) Rename Loadout note
3. Put the Loadout note into any container (except car and ground)
4. Apply Loadout Note
5. (Optional) Configure Loadout Settings
6. Register a Loadout via *Register* or *Store and Register*

## How to

### 1. Add Loadout to container

A Loadout note can be created from a notebook and a pen.
(The Note can optionally be renamed.)
To register a loadout in a container, the Note must simply be placed in the container
and select *Apply Loadout* in the context menu.

Henceforth, in the context menu of the container, there is a sub-item *Loadouts* where the loadout are listed.

A container can have any number of loadouts, for each additional one just another loadout note needs to be applied.

### 2. Register Loadout

Under the point Manage there are 2 possibilities to register loadouts:

- Register
- Store and Register

**Register**:
Registers all apparel/equipment/items (enabled in the configuration) which are in the container.

**Store and Register**:
Registers all apparel/equipment/items (enabled in the configuration) which are in the inventory
and puts them into the container.

*Note*: If there is equipment in the hotbar, it will be saved and put back into the corresponding
slot when you put it on.

### 3. Handling Loadout

There are 3 functions for using the loadouts:

- Wear
- Pick up
- Store

**Wear**:
Takes the Loadout from the container and puts on apparel/equipment.

**Pick up**:
Only takes the Loadout from the container.

**Store**:
Places apparel/equipment/items (including worn/equipped) assigned to the loadout in the container.

#### 4. Configure Loadout

The behavior of the loadout can be set under the Functions point.
These settings can also be configured as default values
via [Mod Options](https://steamcommunity.com/sharedfiles/filedetails/?id=2169435993).

- Allow Apparel
- Allow Equipment
- Allow Items
- Private
- Undress
- Type
    - Apparel/Equipment by Unique ID
    - Apparel/Equipment by Name

**Allow Apparel**:
If enabled, Apparel will be included in the loadout.

**Allow Equipment**:
If enabled, Equipment (weapons/tools) will be included in the loadout.

**Allow Items**:
If enabled, anything that is not Apparel or Equipment is included in the loadout.
This also affects the number of items, if 5 bandages are registered, 5 bandages are always "moved".

**Private**:
Set the loadout to private so that only the player (or admins) can use/edit this loadout.
It does not prevent the apparel/equipment/items from being taken out of the container by other players.

**Undress**:
Remove *all* worn clothing before the loadout is worn.

**Apparel/Equipment by Unique ID**:
Loadout refers to the Ids of apparel and equipment (Items are generally not saved by ID).
This means that if a T-shirt is registered, the loadout will only apply to that specific T-shirt and not to any other
T-shirt.

**Apparel/Equipment by Name**:
Loadout refers to the name of the apparel and equipment (Items are generally saved by Name).
This means that if a T-shirt is registered, but there are several T-shirts in the container, the first one in
the container will be taken.

# Known bugs

- Some mods which offer apparel for additional hotbar slots throw errors on equipping.
  Has as so far, no impact on the Functionality, but is somewhat annoying.

# Current translations

- EN
- DE

# Plugins

## Manage UI

tba

# FAQ

## Does it work in multiplayer mode?

Yes

## Does it work with existing saves?

Yes

## Is the mod compatible with XY?

So far no incompatibility is known

# Help and support

## Translation

[Help to Translate](https://poeditor.com/join/project/lskTKeAc7p)

## Bugs/Features

[Github Issues](https://github.com/Cloud500/EasyLoadouts/issues/new/choose)

# Credits

- [Cosmic](https://steamcommunity.com/profiles/76561198041121447) for inspiration.
- [Supartayasa](https://pngtree.com/freepng/set-of-black-circle-on-off-button-design-with-red-and-green-power-symbolas_8716019.html?sol=downref&id=bef)
  for the On/Off images.
- [The Indie Stone](https://projectzomboid.com) for the Spiffo pictures and the excellent game

[![Permission](http://projectzomboid.com/images/MODS_02.png)](http://theindiestone.com/forums/index.php/topic/2530-mod-permissions/?p=36477)
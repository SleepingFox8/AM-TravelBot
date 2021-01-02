# TravelBot

TravelBot is a minecraft bot written for [advanced macros mod](https://www.curseforge.com/minecraft/mc-mods/advanced-macros) v9.2.0 that provides the user with a set of tools for marking paths in your desired minecraft world, and a bot which can use those paths to navigate to set destinations.

![](https://i.imgur.com/tLZjoKH.jpg)

## Path types

TravelBot is aware of paths with different travel speeds (provided the user marks them correctly) and finds the fastest path to it's destination accordingly. When paths are rendered, different path types are notated via different colors. Each node has a type. Path type is determined by what type of nodes a path is connecting. If a path is connecting two nodes of the same type, the path will be the same type as the nodes. Otherwise the path is "normal" type. 

![](https://i.imgur.com/fi8xEuV.png)

### Normal

These paths are green and indicate a normal path that a bot can walk on. By sprinting on these paths, players can travel up to 5.6 m/s.

### Iceroad
These paths are blue and indicate a packed ice floor with a 2 block high ceiling. By sprint jumping on these paths, players can travel up to 16.9 m/s.

### Rail
These paths are grey and indicate a minecart rail line. This path type is currently used for analytics rather than a different method of travel. As such, these are traveled in the same manner as normal paths.

## Node Markers

Nodes may contain colored blocks inside of them that signify different things

![](https://i.imgur.com/aNgkmNf.png)

### Destination

A small red cube. Signifies a named node destination that is able to be selected by users for travel.

### Selected Node

A medium yellow cube. Signifies that the node is currently selected. The currently selected node is used by path notators to modify nodes and paths.

## 2D HUD

TravelBot displays some information about the world in a 2D HUD at the top left of the user's screen.

![](https://i.imgur.com/BNxmOAj.png)

### Current Location

The ``zones.json`` file for the given world is where zoning information is stored. TravelBot will display the name of any zone the player is inside of. If the player is not in any known zone then ``Unknown`` will be displayed.
 
## Usage

### Key Bindings

Users should use Advanced Macros to bind keyboard keys to

``travelTo.lua``
``toggleRender.lua``

if they intend to notate paths of their own, users should also use Advanced Macros to bind keyboard keys to all the ``.lua`` files in the [nodeManagementTools/](nodeManagementTools/) directory.

### Travel

- ``toggleRender.lua`` will toggle a 3D hud which visualizes all nodes and paths in a 100 block horizontal square around the player, as well as enable a 2D HUD that displays the name of the zone the player is currently inside of. Pressing ``toggleRender.lua`` multiple times will cycle between normal visualization of 3D hud paths, Xrayed vision of 3D hud paths, and hidding all HUD items.

- ``travelTo.lua`` will check if there is a nearby path or node within 10 block walking distance, and present the user with a list of destinations to travel to from there. Currently all known destinations are displayed and as a result, some destinations will not be travlable to if there is no known path to it. If there is not a nearby path or node within 10 block walking distance ``travelTo.lua`` will refuse to run. As such, it is recommended to turn on ``toggleRender.lua`` in order to find nearby paths or nodes before running ``travelTo.lua``

### Path notation

``toggleRender.lua`` should be enabled at least once before using any path notation tools.

The names of the ``.lua`` files in [nodeManagementTools/](nodeManagementTools/) correspond with creating, modifying, and removing nodes

- ``selectNearestNode.lua`` Selects node closest to player if it is less than 10 blocks away
- ``connectNearestwithSelected.lua`` connects (creates path between) node closest to player and selected node
- ``createAndSelectNewNode.lua`` creates new node of selected pathType at the player's current position, selects the new node
- ``deleteSelectedNode.lua`` removes all connections to selected node and then deletes node
- ``extendFromSelected.lua`` creates node of selected pathType at the player's current position, connects (creates path between) the new node and last selected node, selects new node.
- ``makeSelectedADestination.lua`` requires a destination name from use user, assigns that destination name to the selected node
- ``moveSelected.lua`` moves selected node to player's current position
- ``removeConnectionClosestAndSelected.lua`` removes any connection between selected node and node closest to player
- ``removeSelectedDestination.lua`` removes destination name and status from selected node
- ``selectPathType.lua`` toggles between path types used during the creation of any new nodes
- ``setPathTypeOfSelectedNode.lua`` changes the path type of the selected node to the selected path type
- ``injectNodeInClosestPath.lua`` injects a node at the closest point in any path to the player if it is less then 10m away

-- initialization
    -- ensure imports are from file instead of cache
        local function import(path)
            package.loaded[path] = nil
            local imported = require (path)
            package.loaded[path] = nil
            return imported
        end
    -- import dependencies
        local botTools = import("../AM-BotTools/botTools")
        local compTools = import("../AM-CompTools/compTools")
        local nodeTools = import("../nodeTools")
    --assertions
        if compTools.givenScriptIsRunning("AM-TravelBot/toggleRender.lua") == false then
            log("&7[&6NodeManagement&7]&f Please render nodes with toggleRender.lua before modifying them")
            return 0
        end

    --initialize GLBL table if needed
        if GLBL == nil then
            GLBL = {}
        end
        
    --initialize SCRIPT table
    --Stores global variables for just this script
        local SCRIPT = {}

-- main program
    --initialize MAIN table
    --Stores variables for just MAIN function
        local MAIN = {}

    MAIN.nodeIdToDestName = nodeTools.loadDestinationsFromJSON()
    MAIN.destNameToNodeId = nodeTools.getDestNameToNodeId(MAIN.nodeIdToDestName)

    GLBL.selectedNodeId = compTools.readAll("nodeManagementTools/selectedNode.txt")
    GLBL.nodes = nodeTools.loadNodesfromJSON()

    MAIN.newDestName = prompt("Renaming node \"" .. GLBL.selectedNodeId .. "\". Enter new name: ")

    if MAIN.newDestName == nil then
        log("&7[&6NodeManagement&7]§f No destination name given. Canceling destination assignment...")
    elseif MAIN.destNameToNodeId[MAIN.newDestName] ~= nil then
        log("&7[&6NodeManagement&7]§f That destination name is already in use...")
    else
        nodeTools.assignNodeDestinationName(GLBL.selectedNodeId, MAIN.newDestName)

        log("&7[&6NodeManagement&7]§f Successfully assigned node: \"".. GLBL.selectedNodeId .. "\" the destination name: \"" .. MAIN.newDestName .. "\"")
    end
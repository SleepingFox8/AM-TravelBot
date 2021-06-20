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

    GLBL.selectedNodeId = compTools.readAll("nodeManagementTools/selectedNode.txt")
    GLBL.nodes = nodeTools.loadNodesfromJSON()

    MAIN.destinations = nodeTools.loadDestinationsFromJSON()

    if MAIN.destinations[GLBL.selectedNodeId] ~= nil then

        --remove destination mapping
        nodeTools.assignNodeDestinationName(GLBL.selectedNodeId, nil)

        nodeTools.saveNodesToJSON()
        log("&7[&6NodeManagement&7]§f Removed " .. GLBL.selectedNodeId .. " from list of destinations")
    else
        log("&7[&6NodeManagement&7]§f The selected node \"" .. GLBL.selectedNodeId .. "\" is already not a destination")
    end 
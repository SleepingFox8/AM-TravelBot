-- initialization
    -- import dependencies
        local botTools = require ("./AM-Tools/botTools")
        local compTools = require ("./AM-Tools/compTools")
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

    GLBL.selectedNodeId = botTools.readAll("nodeManagementTools/selectedNode.txt")
    GLBL.nodes = nodeTools.loadNodesfromJSON()

    -- remove selectedNode's neighbors connections to selectedNode
        for key,value in pairs(GLBL.nodes[GLBL.selectedNodeId].connections) do 
            MAIN.neighbor = key
            GLBL.nodes[MAIN.neighbor].connections[GLBL.selectedNodeId] = nil
        end

    --remove destination mapping (if it exists)
    nodeTools.assignNodeDestinationName(GLBL.selectedNodeId, nil)

    -- delete selected node
        GLBL.nodes[GLBL.selectedNodeId] = nil

        log("&7[&6NodeManagement&7]§f deleted " .. GLBL.selectedNodeId)

    nodeTools.saveNodesToJSON()
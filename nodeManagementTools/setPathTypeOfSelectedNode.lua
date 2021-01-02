--initialization
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

    if GLBL.selectedPathType == nil then
        GLBL.selectedPathType = "normal"
    end
-- main program
    --initialize MAIN table
    --Stores variables for just MAIN function
        local MAIN = {}

    GLBL.nodes = nodeTools.loadNodesfromJSON()
    GLBL.selectedNodeId = botTools.readAll("nodeManagementTools/selectedNode.txt")

    GLBL.nodes[GLBL.selectedNodeId].pathType = GLBL.selectedPathType

    log("&7[&6NodeManagement&7]§f \"" .. GLBL.selectedNodeId .. "\"".. " pathType set to " .. GLBL.selectedPathType)
    
    nodeTools.saveNodesToJSON()
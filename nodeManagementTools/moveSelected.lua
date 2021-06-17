-- initialization
    -- import dependencies
        local botTools = require ("./AM-Tools/botTools")
        local compTools = require ("./AM-Tools/compTools")
        local nodeTools = require "nodeTools"
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

    MAIN.x, MAIN.y, MAIN.z = getPlayerPos()
    MAIN.x = math.floor(MAIN.x)
    MAIN.y = MAIN.y + 0.1
    MAIN.y = math.floor(MAIN.y)
    MAIN.z = math.floor(MAIN.z)

    GLBL.nodes[GLBL.selectedNodeId].x = MAIN.x
    GLBL.nodes[GLBL.selectedNodeId].y = MAIN.y
    GLBL.nodes[GLBL.selectedNodeId].z = MAIN.z

    log("&7[&6NodeManagement&7]§f Moved: " .. GLBL.selectedNodeId)

    nodeTools.saveNodesToJSON()
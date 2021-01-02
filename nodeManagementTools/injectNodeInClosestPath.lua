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

-- main program
    --initialize MAIN table
    --Stores variables for just MAIN function
        local MAIN = {}

    GLBL.selectedNodeId = botTools.readAll("nodeManagementTools/selectedNode.txt")
    GLBL.nodes = nodeTools.loadNodesfromJSON()

    --find closest point to nearby path within 10 meters
    MAIN.ppX,MAIN.ppY,MAIN.ppZ,MAIN.ppDistance, MAIN.nodeA, MAIN.nodeB, MAIN.ppPathType = nodeTools.pathCloseby()

    --if path point within 10 meters found
    if MAIN.ppX ~= false then

        --create new node at injection point
            --generate name for new node
            MAIN.newNodeName = nodeTools.generateRandomNodeName()

            GLBL.nodes[MAIN.newNodeName] = {
                ["x"] = MAIN.ppX,
                ["y"] = MAIN.ppY,
                ["z"] = MAIN.ppZ,
                ["connections"] = {},
                ["pathType"] = MAIN.ppPathType
            }
        --update connections
            --connect new node with old nodes
                GLBL.nodes[MAIN.newNodeName].connections[MAIN.nodeA] = true
                GLBL.nodes[MAIN.newNodeName].connections[MAIN.nodeB] = true

            --connect old node with new node
                GLBL.nodes[MAIN.nodeA].connections[MAIN.newNodeName] = true
                GLBL.nodes[MAIN.nodeB].connections[MAIN.newNodeName] = true

            --disconnect old node path
                GLBL.nodes[MAIN.nodeA].connections[MAIN.nodeB] = nil
                GLBL.nodes[MAIN.nodeB].connections[MAIN.nodeA] = nil

        log("&7[&6NodeManagement&7]§f Injected node")

        --save changes
        nodeTools.saveNodesToJSON()
    else
        log("&7[&6NodeManagement&7]§f No path found nearby to inject node into")
    end
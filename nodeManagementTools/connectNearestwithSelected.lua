--initialization
    -- import dependencies
        local botTools = require ("./AM-Tools/botTools")
        local compTools = require ("./AM-Tools/compTools")
    --assertions
        if compTools.givenScriptIsRunning("TravelBot/toggleRender.lua") == false then
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
    GLBL.selectedNodeId = botTools.readAll("nodeManagementTools/selectedNode.txt")
    GLBL.nodes = nodeTools.loadNodesfromJSON()

    if nodeTools.nodeCloseby() then

        SCRIPT.closestNodeName = nodeTools.nodeCloseby()

        -- connect GLBL.nodes
            -- connect closest node with selected node
                GLBL.nodes[SCRIPT.closestNodeName].connections[GLBL.selectedNodeId] = true
            
            -- connect selected node with new node
                GLBL.nodes[GLBL.selectedNodeId].connections[SCRIPT.closestNodeName] = true

        log("&7[&6NodeManagement&7]§f Connected nodes " .. GLBL.selectedNodeId .. " and " .. SCRIPT.closestNodeName)

        nodeTools.saveNodesToJSON()
    else
        log("&7[&6NodeManagement&7]§f No nodes close enough to player to connect to...")
    end
-- initialization
    -- ensure imports are from file instead of cache
        local function import(path)
            package.loaded[path] = nil
            local imported = require (path)
            package.loaded[path] = nil
            return imported
        end
    -- import dependencies
        local botTools = import("../AM-Tools/botTools")
        local compTools = import("../AM-Tools/compTools")
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

    if nodeTools.nodeCloseby() then

        MAIN.closestNodeName = nodeTools.nodeCloseby()

        -- connect nodes
            -- connect closest node with selected node
                GLBL.nodes[MAIN.closestNodeName].connections[GLBL.selectedNodeId] = nil
            
            -- connect selected node with new node
                GLBL.nodes[GLBL.selectedNodeId].connections[MAIN.closestNodeName] = nil

        nodeTools.saveNodesToJSON()

        log("&7[&6NodeManagement&7]§f disconnected nodes " .. GLBL.selectedNodeId .. " and " .. MAIN.closestNodeName)
    else
        log("&7[&6NodeManagement&7]§f No nodes close enough to player to connect to...")
    end
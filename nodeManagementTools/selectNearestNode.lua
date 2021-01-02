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

--Assign SCRIPT variables
    SCRIPT.nodeIdToDestName = nodeTools.loadDestinationsFromJSON()
    SCRIPT.destNameToNodeId = nodeTools.getDestNameToNodeId(SCRIPT.nodeIdToDestName)

-- main program
    --initialize MAIN table
    --Stores variables for just MAIN function
        local MAIN = {}

    if nodeTools.nodeCloseby() then
        MAIN.nodeToSelect = nodeTools.nodeCloseby()
        log("&7[&6NodeManagement&7]§f Selected node: " .. MAIN.nodeToSelect .. " pathType: \"" .. GLBL.nodes[MAIN.nodeToSelect].pathType .."\"" )
        if SCRIPT.nodeIdToDestName[MAIN.nodeToSelect] ~= nil then
            log("&7[&6NodeManagement&7]§f Destination name: " .. SCRIPT.nodeIdToDestName[MAIN.nodeToSelect])
        end
        nodeTools.selectNode(MAIN.nodeToSelect)
    else
        log("&7[&6NodeManagement&7]§f No nodes nearby to select")
    end
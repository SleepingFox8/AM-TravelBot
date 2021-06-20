--initialization
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
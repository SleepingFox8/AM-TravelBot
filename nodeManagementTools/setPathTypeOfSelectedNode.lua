--initialization
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

    if GLBL.selectedPathType == nil then
        GLBL.selectedPathType = "normal"
    end
-- main program
    --initialize MAIN table
    --Stores variables for just MAIN function
        local MAIN = {}

    GLBL.nodes = nodeTools.loadNodesfromJSON()
    GLBL.selectedNodeId = compTools.readAll("nodeManagementTools/selectedNode.txt")

    GLBL.nodes[GLBL.selectedNodeId].pathType = GLBL.selectedPathType

    log("&7[&6NodeManagement&7]§f \"" .. GLBL.selectedNodeId .. "\"".. " pathType set to " .. GLBL.selectedPathType)
    
    nodeTools.saveNodesToJSON()
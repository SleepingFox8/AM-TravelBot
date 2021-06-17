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

    --initialize RNG
    math.randomseed( os.time() )

    if GLBL.selectedPathType == nil then
        GLBL.selectedPathType = "normal"
    end

-- main program

    --initialize MAIN table
    --Stores variables for just MAIN function
        local MAIN = {}

    GLBL.nodes = nodeTools.loadNodesfromJSON()

    log("&7[&6NodeManagement&7]§f selectedPathType: " .. GLBL.selectedPathType)

    MAIN.x, MAIN.y, MAIN.z = getPlayerPos()

    MAIN.x = math.floor(MAIN.x)
    MAIN.y = MAIN.y + 0.1
    MAIN.y = math.floor(MAIN.y)
    MAIN.z = math.floor(MAIN.z)

    MAIN.newNodeName = nodeTools.generateRandomNodeName()
    
    GLBL.nodes[MAIN.newNodeName] = {
        ["x"] = MAIN.x,
        ["y"] = MAIN.y,
        ["z"] = MAIN.z,
        ["connections"] = {},
        ["pathType"] = GLBL.selectedPathType
    }

    nodeTools.selectNode(MAIN.newNodeName)

    log("&7[&6NodeManagement&7]§f Created new node named: " .. MAIN.newNodeName)

    nodeTools.saveNodesToJSON()
-- initialization
    -- ensure imports are from file instead of cache
        local function import(path)
            package.loaded[path] = nil
            local imported = require (path)
            package.loaded[path] = nil
            return imported
        end
    -- import dependencies
        local json = import("./json.lua/json")
        local nodeTools = import"nodeTools"

--initialize GLBL table if needed
    if GLBL == nil then
        GLBL = {}
    end
    
--initialize SCRIPT table
--Stores global variables for just this script
    local SCRIPT = {}

--initialize RNG
    math.randomseed( os.time() )

--Main Program
    --initialize MAIN table
    --Stores variables for just MAIN function
        local MAIN = {}

    -- get GLBL.nodes
    GLBL.nodes = nodeTools.loadNodesfromJSON()

    -- get total path distance
        MAIN.totalDistance = 0
        MAIN.connectionsAlreadyUsed = {}
        
        for key,value in pairs(GLBL.nodes) do
            MAIN.node = key

            for key,value in pairs(GLBL.nodes[MAIN.node]["connections"]) do
                MAIN.neighbor = key

                if MAIN.connectionsAlreadyUsed[MAIN.neighbor .. MAIN.node] == nil then
                    MAIN.totalDistance = MAIN.totalDistance + compTools.distanceBetweenPoints(GLBL.nodes[MAIN.neighbor].x,GLBL.nodes[MAIN.neighbor].y,GLBL.nodes[MAIN.neighbor].z, GLBL.nodes[MAIN.node].x,GLBL.nodes[MAIN.node].y,GLBL.nodes[MAIN.node].z)
                    MAIN.connectionsAlreadyUsed[MAIN.node .. MAIN.neighbor] = true
                end
            end
        end

        log("Distance of all paths (in meters): ", math.floor(MAIN.totalDistance))

    -- display number of expandable rails
        MAIN.nearestExpandableRail, MAIN.expandbleRailCount = nodeTools.nearestExpandableRail()
        log("Expandable rails: ", MAIN.expandbleRailCount)

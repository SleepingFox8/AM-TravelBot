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
        local compTools = import("./AM-CompTools/compTools")
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

    -- define player movement speeds in m/s
        SCRIPT.walkingSpeed = 4.317
        SCRIPT.sprintSpeed = 5.612
        SCRIPT.sprintJumpingSpeed = 7
        SCRIPT.sprintJumpingRooflessIceSpeed = 9.23
        SCRIPT.sprintJumpingIceSpeed = 16.9

-- functions
    function SCRIPT.pathTypeBetweenNodes(node1, node2)
        --initialize function
            --initialize function table
                local FUNC = {}
            --store arguments in known scoped table
                FUNC.node1, FUNC.node2 = node1, node2

        if FUNC.node1.pathType == FUNC.node2.pathType then
            return FUNC.node1.pathType
        else
            return "normal"
        end
    end

    function SCRIPT.getPathTypeTravelSpeed(pathType)
        --initialize function
            --initialize function table
                local FUNC = {}
            --store arguments in known scoped table
                FUNC.pathType = pathType

        if FUNC.pathType == "iceroad" then
            return SCRIPT.sprintJumpingIceSpeed
        elseif FUNC.pathType == "roofless iceroad" then
            return SCRIPT.sprintJumpingRooflessIceSpeed
        else
            return SCRIPT.sprintSpeed
        end
        
    end

    function SCRIPT.secondsToClock(seconds)
        return os.date('!%d:%H:%M:%S', seconds)
    end

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

    -- display minimum time to travel all paths

        MAIN.totalTravelTime = 0

        -- for each unuque path
        for key,value in pairs(GLBL.nodes) do
            MAIN.node = key
            -- for each unuque path
            for key,value in pairs(GLBL.nodes[MAIN.node]["connections"]) do
                MAIN.neighbor = key
                -- for each unuque path
                if MAIN.connectionsAlreadyUsed[MAIN.neighbor .. MAIN.node] == nil then
                    MAIN.pathType = SCRIPT.pathTypeBetweenNodes(MAIN.node, MAIN.neighbor)
                    MAIN.travelSpeed = SCRIPT.getPathTypeTravelSpeed(MAIN.pathType)
                    MAIN.pathDistance = compTools.distanceBetweenPoints(GLBL.nodes[MAIN.neighbor].x,GLBL.nodes[MAIN.neighbor].y,GLBL.nodes[MAIN.neighbor].z, GLBL.nodes[MAIN.node].x,GLBL.nodes[MAIN.node].y,GLBL.nodes[MAIN.node].z)

                    MAIN.totalTravelTime = MAIN.totalTravelTime + MAIN.pathDistance / MAIN.travelSpeed
                end
            end
        end

        log("Minimum time to traverse all paths: " .. SCRIPT.secondsToClock(MAIN.totalTravelTime))

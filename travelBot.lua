--initialization
    -- ensure imports are from file instead of cache
        local function import(path)
            package.loaded[path] = nil
            local imported = require (path)
            package.loaded[path] = nil
            return imported
        end
    -- import dependencies
        local botTools = import("./AM-BotTools/botTools")
        local compTools = import("./AM-CompTools/compTools")
        local nodeTools = import"nodeTools"

    local travelBot = { _version = "0.0.0" }
    
    --initialize GLBL table if needed
        if GLBL == nil then
            GLBL = {}
        end

    --initialize SCRIPT table
    --Stores global variables for just this script
        local SCRIPT = {}

--function declarations

    -- A* pathfinding related
        function SCRIPT.h(node, goal)
            --initialize function table
                local FUNC = {}

            FUNC.cost = nil
            FUNC.distance = SCRIPT.distanceBetweenNodes(node, goal)

            -- assume there could be an iceroad ahead
                FUNC.cost = FUNC.distance / SCRIPT.sprintJumpingIceSpeed

            return FUNC.cost
        end

        function SCRIPT.d(node1, node2)
            --initialize function table
                local FUNC = {}

            FUNC.cost = nil
            FUNC.distance = SCRIPT.distanceBetweenNodes(node1, node2)
            -- determine type of connection
                -- iceroad
                    if nodeTools.getPathTypeFromNodeTypes(GLBL.nodes[node1].pathType, GLBL.nodes[node2].pathType) == "iceroad" then
                        FUNC.cost = FUNC.distance / SCRIPT.sprintJumpingIceSpeed
                -- roofless iceroad
                    elseif nodeTools.getPathTypeFromNodeTypes(GLBL.nodes[node1].pathType, GLBL.nodes[node2].pathType) == "roofless iceroad" then
                        FUNC.cost = FUNC.distance / SCRIPT.sprintJumpingRooflessIceSpeed
                -- normal
                    else
                        FUNC.cost = FUNC.distance / SCRIPT.sprintJumpingSpeed
                    end

            return FUNC.cost
        end

        -- find the distance between two GLBL.nodes
        function SCRIPT.distanceBetweenNodes(node, goal)
            return compTools.distanceBetweenPoints(GLBL.nodes[goal].x, GLBL.nodes[goal].y, GLBL.nodes[goal].z, GLBL.nodes[node].x, GLBL.nodes[node].y, GLBL.nodes[node].z)
        end

        function SCRIPT.reconstruct_path(cameFrom, current)
            --initialize function table
                local FUNC = {}

            FUNC.total_path = {}
            FUNC.total_path[1] = current

            FUNC.index = 2
            -- while current in cameFrom.Keys:
            while cameFrom[current] ~= nil do
                current = cameFrom[current]
                -- FUNC.total_path.append(current)
                FUNC.total_path[FUNC.index] = current
                    FUNC.index = FUNC.index + 1
            end

            compTools.reverse(FUNC.total_path)

            return FUNC.total_path
        end

        function SCRIPT.A_Star(start, goal)
            --initialize function table
                local FUNC = {}
                
            -- The set of discovered GLBL.nodes that may need to be (re-)expanded.
            -- Initially, only the start node is known.
            FUNC.openSet = {}
            FUNC.openSet[start] = true

            -- For node n, FUNC.cameFrom[n] is the node immediately preceding it on the cheapest path from start
            -- to n currently known.
            FUNC.cameFrom = {}

            -- For node n, FUNC.gScore[n] is the cost of the cheapest path from start to n currently known.

            FUNC.gScore = {}
            -- all GLBL.nodes (aside from start) have default value of infinity
                for key,value in pairs(GLBL.nodes) do 
                    FUNC.gScore[key] = 1/0
                end
            FUNC.gScore[start] = 0

            -- For node n, FUNC.fScore[n] := FUNC.gScore[n] + SCRIPT.h(n). FUNC.fScore[n] represents our current best guess as to
            -- how short a path from start to finish can be if it goes through n.
            FUNC.fScore = {}
                -- map with default value of Infinity
                for key,value in pairs(GLBL.nodes) do
                    FUNC.fScore[key] = 1/0
                end
            FUNC.fScore[start] = SCRIPT.h(start, goal)

            -- while FUNC.openSet is not empty
            while(compTools.tableIsEmpty(FUNC.openSet) ~= true)do
                FUNC.current = nil
                -- FUNC.current = the node in FUNC.openSet having the lowest FUNC.fScore[] value
                    FUNC.lowest = 1/0
                    FUNC.nameOfLowest = nil
                    for key,value in pairs(FUNC.openSet) do
                        if FUNC.fScore[key] < FUNC.lowest then
                            FUNC.lowest = FUNC.fScore[key]
                            FUNC.nameOfLowest = key
                        end
                    end
                    FUNC.current = FUNC.nameOfLowest
                if FUNC.current == goal then
                    return SCRIPT.reconstruct_path(FUNC.cameFrom, FUNC.current)
                end

                -- FUNC.openSet.Remove(FUNC.current)
                    FUNC.openSet[FUNC.current] = nil
                -- for each FUNC.neighbor of FUNC.current
                for key,value in pairs(GLBL.nodes[FUNC.current].connections) do 
                    FUNC.neighbor = key
                    -- SCRIPT.d(FUNC.current, FUNC.neighbor) is the weight of the edge from FUNC.current to FUNC.neighbor
                    -- FUNC.tentative_gScore is the distance from start to the FUNC.neighbor through FUNC.current
                    FUNC.tentative_gScore = FUNC.gScore[FUNC.current] + SCRIPT.d(FUNC.current, FUNC.neighbor)
                    if FUNC.tentative_gScore < FUNC.gScore[FUNC.neighbor] then
                        -- This path to FUNC.neighbor is better than any previous one. Record it!
                        FUNC.cameFrom[FUNC.neighbor] = FUNC.current
                        FUNC.gScore[FUNC.neighbor] = FUNC.tentative_gScore
                        FUNC.fScore[FUNC.neighbor] = FUNC.gScore[FUNC.neighbor] + SCRIPT.h(FUNC.neighbor, goal)
                        -- if FUNC.neighbor not in FUNC.openSet
                        if FUNC.openSet[FUNC.neighbor] == nil then
                            -- FUNC.openSet.add(neighbor)
                            FUNC.openSet[FUNC.neighbor] = true
                        end
                    end
                end
            end

            -- return failure
            return false
        end

        function SCRIPT.namePathToPointPath(namePath)
            --initialize function table
                local FUNC = {}

            FUNC.pointPath = {}

            FUNC.i = 1
            for key,value in pairs(namePath) do 
                FUNC.node = value
                FUNC.pointPath[FUNC.i] = {GLBL.nodes[FUNC.node].x, GLBL.nodes[FUNC.node].y, GLBL.nodes[FUNC.node].z}
                -- keep at end of loop
                    FUNC.i = FUNC.i + 1
            end

            return FUNC.pointPath
        end
    
    -- Walk-Path related
        function SCRIPT.travelTypePath(typePath)
            --initialize function
                --initialize function table
                    local FUNC = {}
                --store arguments in known scoped table
                    FUNC.typePath = typePath

            -- for all path points
                FUNC.i = 1
                while (FUNC.i <= #FUNC.typePath) do
                    --determine type of path being traveled on
                        FUNC.pathType = nil
                        if FUNC.i == 1 then
                            FUNC.pathType = "normal"
                        else
                            FUNC.pathType = nodeTools.getPathTypeFromNodeTypes(FUNC.typePath[FUNC.i-1].pathType, FUNC.typePath[FUNC.i].pathType)
                        end

                        

                    --walk to next point according to pathType
                        --iceroad
                            if FUNC.pathType == "iceroad" then
                                botTools.sprintJumpToPoint(FUNC.typePath[FUNC.i].x, FUNC.typePath[FUNC.i].y, FUNC.typePath[FUNC.i].z)
                        --"roofless iceroad"
                            elseif FUNC.pathType == "roofless iceroad" then
                                botTools.sprintJumpToPoint(FUNC.typePath[FUNC.i].x, FUNC.typePath[FUNC.i].y, FUNC.typePath[FUNC.i].z)
                        --normal
                            else
                                botTools.sprintToPoint(FUNC.typePath[FUNC.i].x, FUNC.typePath[FUNC.i].y, FUNC.typePath[FUNC.i].z)
                            end

                    -- keep at end of loop
                        FUNC.i = FUNC.i + 1
                end    
            -- give time for bot to stop
                sleep(500)
            -- sneak to the last point (ensures bot ends on that exact block)
                botTools.sneakToPoint(FUNC.typePath[#FUNC.typePath].x, FUNC.typePath[#FUNC.typePath].y, FUNC.typePath[#FUNC.typePath].z)
        end

    -- time related
        function SCRIPT.getPathEta(nodeNamePath)
            --initialize function table
                local FUNC = {}

            FUNC.totalTravelTime = 0
            FUNC.lastNode = nil
            for key,value in pairs(nodeNamePath) do
                if key == 1 then
                    FUNC.lastNode = value
                else
                    FUNC.currentNode = value
                    FUNC.distance = SCRIPT.distanceBetweenNodes(FUNC.currentNode, FUNC.lastNode)

                    -- iceroad path
                        if GLBL.nodes[FUNC.currentNode].pathType == "iceroad" and GLBL.nodes[FUNC.lastNode].pathType == "iceroad" then
                            FUNC.totalTravelTime = FUNC.totalTravelTime + FUNC.distance / SCRIPT.sprintJumpingIceSpeed
                    -- "roofless iceroad" path
                        elseif GLBL.nodes[FUNC.currentNode].pathType == "roofless iceroad" and GLBL.nodes[FUNC.lastNode].pathType == "roofless iceroad" then
                            FUNC.totalTravelTime = FUNC.totalTravelTime + FUNC.distance / SCRIPT.sprintJumpingRooflessIceSpeed
                    -- normal path
                        else
                            FUNC.totalTravelTime = FUNC.totalTravelTime + FUNC.distance / SCRIPT.sprintSpeed
                        end

                    -- keep at end
                        FUNC.lastNode = FUNC.currentNode
                end
            end
            return FUNC.totalTravelTime
        end

        function SCRIPT.SecondsToClock(seconds)
            return os.date('!%H:%M:%S', seconds)
        end

    function SCRIPT.coordinatesToString(x,y,z)
        --initialize function table
            local FUNC = {}

        FUNC.x = math.floor(x)
        FUNC.y = math.floor(y)
        FUNC.z = math.floor(z)
        return "[x:" .. FUNC.x .. ", y:" .. FUNC.y .. ", z:" .. FUNC.z .. "]"
    end

    function SCRIPT.nodeCoordinatesString(nodeName)
        --initialize function table
            local FUNC = {}

        FUNC.x = GLBL.nodes[nodeName].x
        FUNC.y = GLBL.nodes[nodeName].y
        FUNC.z = GLBL.nodes[nodeName].z
        return SCRIPT.coordinatesToString(FUNC.x,FUNC.y,FUNC.z)
    end

    function SCRIPT.getNamedDestinations()
        --initialize function table
            local FUNC = {}
        
        FUNC.namedDestinations = {}
        for key,value in pairs(GLBL.nodes) do
            FUNC.node = key
            if GLBL.nodes[FUNC.node].isNamedDestination == true then
                --append named destination to list
                    FUNC.namedDestinations[node] = true
            end
        end

        FUNC.namedDestinations = compTools.sortTableByKeys(FUNC.namedDestinations)

        return FUNC.namedDestinations
    end

    function SCRIPT.nodeIdPathToTypePath(nodeIdPath)
        --initialize function table
            local FUNC = {}

        FUNC.typePath = {}
        for key,value in pairs(nodeIdPath) do
            FUNC.nodeId = value

            FUNC.typePath[#FUNC.typePath+1] = GLBL.nodes[FUNC.nodeId]
        end

        return FUNC.typePath
    end

    function travelBot.travelTo(targetNodeId)
        --initialize function table
            local FUNC = {}
        -- store function args in scope-safe table
            FUNC.targetNodeId = targetNodeId
        --determing if starting on node or path and resolve starting node name
            if nodeTools.nodeCloseby() then
                log("&7[&6TravelBot&7]§f Starting route on node...")
                FUNC.startPoint = nodeTools.nodeCloseby()
            else
                log("&7[&6TravelBot&7]§f Starting route at path point...")
                FUNC.startX,FUNC.startY,FUNC.startZ,FUNC.startDistance, FUNC.nodeA, FUNC.nodeB, FUNC.currentPathType = nodeTools.pathCloseby()
                GLBL.nodes["pathEntryPoint"] = {
                    ["x"] = FUNC.startX,
                    ["y"] = FUNC.startY,
                    ["z"] = FUNC.startZ,
                    ["connections"] = {
                        [FUNC.nodeA] = true,
                        [FUNC.nodeB] = true
                    },
                    ["pathType"] = FUNC.currentPathType
                }
                FUNC.startPoint = "pathEntryPoint"
            end
        -- (start, goal)
        FUNC.namePath = SCRIPT.A_Star(FUNC.startPoint, FUNC.targetNodeId)

        if FUNC.namePath == false then
            log("&7[&6TravelBot&7]§f No known path to target location...")
            -- remove pathEntryPoint
                GLBL.nodes["pathEntryPoint"] = nil
            return false
        else
            -- calculate ETA
                FUNC.etaInSeconds = SCRIPT.getPathEta(FUNC.namePath)
                FUNC.clockETA = SCRIPT.SecondsToClock(FUNC.etaInSeconds)
                if SCRIPT.nodeIdToDestName[FUNC.targetNodeId] ~= nil then
                    log("&7[&6TravelBot&7]§f Traveling to \"" .. SCRIPT.nodeIdToDestName[FUNC.targetNodeId] .. "\" at " .. SCRIPT.nodeCoordinatesString(FUNC.targetNodeId) .. " ETA: " .. FUNC.clockETA)
                else
                    log("&7[&6TravelBot&7]§f Traveling to \"" .. FUNC.targetNodeId .. "\" at " .. SCRIPT.nodeCoordinatesString(FUNC.targetNodeId) .. " ETA: " .. FUNC.clockETA)
                end
            
            FUNC.typePath = SCRIPT.nodeIdPathToTypePath(FUNC.namePath)
            -- remove GLBL.nodes["pathEntryPoint"] now that we are done with FUNC.namePath
                GLBL.nodes["pathEntryPoint"] = nil

            -- start travel time timer
                FUNC.start_time = os.time()
            -- travel to destination
                SCRIPT.travelTypePath(FUNC.typePath)
            -- stop travel time timer and calculate time it took to complete travel
                FUNC.timeDiff = os.difftime(os.time(),FUNC.start_time)

            -- determine name of destination to display to user
                if SCRIPT.nodeIdToDestName[FUNC.targetNodeId] ~= nil then
                    FUNC.stringDestName = SCRIPT.nodeIdToDestName[FUNC.targetNodeId]
                else
                    FUNC.stringDestName = FUNC.targetNodeId
                end

            log("&7[&6TravelBot&7]§f You have arrived at \"" .. FUNC.stringDestName .. "\" after " .. SCRIPT.SecondsToClock(FUNC.timeDiff))
            botTools.freezeAllMotorFunctions()
            return true
        end
    end

-- declaration script wide variables

    -- define player movement speeds
        SCRIPT.walkingSpeed = 4.317
        -- 5.612 == player speed in m/s
        SCRIPT.sprintSpeed = 5.612
        SCRIPT.sprintJumpingSpeed = 7
        SCRIPT.sprintJumpingRooflessIceSpeed = 9.23
        SCRIPT.sprintJumpingIceSpeed = 16.9

        -- from my own recordings
            -- SCRIPT.sprintSpeed = 5.612
            -- SCRIPT.sprintJumpingSpeed = 7.1
            -- SCRIPT.sprintJumpingRooflessIceSpeed = 9.23
            -- SCRIPT.sprintJumpingIceSpeed = 19.4

    --load destinations
        SCRIPT.nodeIdToDestName = nodeTools.loadDestinationsFromJSON()
        SCRIPT.destNameToNodeId = nodeTools.getDestNameToNodeId(SCRIPT.nodeIdToDestName)

    -- get GLBL.nodes
        GLBL.nodes = nodeTools.loadNodesfromJSON()

return travelBot
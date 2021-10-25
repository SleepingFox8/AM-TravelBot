-- initialization
    --initialize SCRIPT table

    --Stores global variables for just this script
        local SCRIPT = {}

    --initialize GLBL table if needed
        if GLBL == nil then
            GLBL = {}
        end

    -- ensure imports are from file instead of cache
        local function import(path)
            package.loaded[path] = nil
            local imported = require (path)
            package.loaded[path] = nil
            return imported
        end
    -- import dependencies
        SCRIPT.json = import("./json.lua/json")
        SCRIPT.botTools = import("./AM-BotTools/botTools")
        SCRIPT.compTools = import("./AM-CompTools/compTools")
        SCRIPT.nodeTools = import"nodeTools"
        SCRIPT.travelBot = import"travelBot"

    function SCRIPT.slog(string)
        log("&7[&6PathValidation&7]&f ", string)
    end

    -- global variable declaration
        -- define player movement speeds
            SCRIPT.walkingSpeed = 4.317
            SCRIPT.sprintSpeed = 5.612
            SCRIPT.sprintJumpingSpeed = 7
            SCRIPT.sprintJumpingRooflessIceSpeed = 9.23
            SCRIPT.sprintJumpingIceSpeed = 16.9

-- function declarations

    function SCRIPT.saveValidatedPathsToJson(validatedPaths)
        --function initialization
            --initialize function table
                local FUNC = {}
            --store arguments in locally scoped table for scope safety
                FUNC.validatedPaths = validatedPaths
        
        SCRIPT.nodeTools.ensureFileExists(SCRIPT.nodeTools.pathToCurrentStorageDir() .. "validatedPaths.json")
        FUNC.jsonValidatedPaths = SCRIPT.json.encode(FUNC.validatedPaths)

        -- opens file
        FUNC.file = io.open(SCRIPT.nodeTools.pathToCurrentStorageDir() .. "validatedPaths.json", "w")

        FUNC.file:write(FUNC.jsonValidatedPaths)

        -- closes file
        FUNC.file:close()
    end

    -- A* pathfinding related
        function SCRIPT.h(node, goal)
            return 0
        end

        function SCRIPT.d(node1, node2)
            --initialize function table
                local FUNC = {}

            FUNC.cost = nil
            FUNC.distance = SCRIPT.distanceBetweenNodes(node1, node2)
            -- determine type of connection
                -- iceroad
                    if SCRIPT.nodeTools.getPathTypeFromNodeTypes(GLBL.nodes[node1].pathType, GLBL.nodes[node2].pathType) == "iceroad" then
                        FUNC.cost = FUNC.distance / SCRIPT.sprintJumpingIceSpeed
                -- roofless iceroad
                    elseif SCRIPT.nodeTools.getPathTypeFromNodeTypes(GLBL.nodes[node1].pathType, GLBL.nodes[node2].pathType) == "roofless iceroad" then
                        FUNC.cost = FUNC.distance / SCRIPT.sprintJumpingRooflessIceSpeed
                -- normal
                    else
                        FUNC.cost = FUNC.distance / SCRIPT.sprintJumpingSpeed
                    end

            return FUNC.cost
        end

        -- find the distance between two GLBL.nodes
        function SCRIPT.distanceBetweenNodes(node, goal)
            return SCRIPT.compTools.distanceBetweenPoints(GLBL.nodes[goal].x, GLBL.nodes[goal].y, GLBL.nodes[goal].z, GLBL.nodes[node].x, GLBL.nodes[node].y, GLBL.nodes[node].z)
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

        function SCRIPT.tableKeyCount(table)
            --initialize function
                --initialize function table
                    local FUNC = {}
                --store arguments in known scoped table
                    FUNC.table = table
    
            FUNC.count = 0
            for _ in pairs(FUNC.table) do
                FUNC.count = FUNC.count + 1
            end
            return FUNC.count
        end

        function SCRIPT.findNearestUnvalidatedPath(start, goal)
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

            FUNC.firstPass = true
            -- while FUNC.openSet is not empty
            while(SCRIPT.compTools.tableIsEmpty(FUNC.openSet) ~= true)do
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

                if FUNC.firstPass == false then
                    FUNC.forwardsName = FUNC.cameFrom[FUNC.current]..FUNC.current 
                    FUNC.backwardsName = FUNC.current..FUNC.cameFrom[FUNC.current]

                    if GLBL.validatedPaths[FUNC.forwardsName] == nil and GLBL.validatedPaths[FUNC.backwardsName] == nil then
                        -- return nodes who's path has not yet been explored
                        return FUNC.cameFrom[FUNC.current], FUNC.current 
                    end
                else
                    FUNC.firstPass = false
                end

                -- if FUNC.current == goal then
                --     return SCRIPT.reconstruct_path(FUNC.cameFrom, FUNC.current)
                -- end

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

        function SCRIPT.loadValidatedPathsFromJson()
            --function initialization
                --initialize function table
                    local FUNC = {}

            FUNC.player = getPlayer()
            SCRIPT.nodeTools.ensureFileExists(SCRIPT.nodeTools.pathToCurrentStorageDir() .. "validatedPaths.json")
            return SCRIPT.json.decode(SCRIPT.compTools.readAll(SCRIPT.nodeTools.pathToCurrentStorageDir() .. "validatedPaths.json"))
        end

-- toggle this script off if it is already running
    if SCRIPT.compTools.anotherInstanceOfThisScriptIsRunning() then
        SCRIPT.slog("Stopping validation...")
        SCRIPT.compTools.stopOtherInstancesOfThisScript()
        SCRIPT.botTools.freezeAllMotorFunctions()
        -- uncrouch
            sneak(1)
            waitTick()
        SCRIPT.slog("Saving validated paths to file...")

        SCRIPT.saveValidatedPathsToJson(GLBL.validatedPaths)

        SCRIPT.slog("Validated paths saved...")

        -- silently end this script
            return 0
    end
    
-- Main program
    --initialize MAIN table
    --Stores variables for just MAIN function
        local MAIN = {}

    -- get GLBL.nodes
        GLBL.nodes = SCRIPT.nodeTools.loadNodesfromJSON()

    GLBL.validatedPaths = SCRIPT.loadValidatedPathsFromJson()
    

    -- find node to start from
    MAIN.startingNode = SCRIPT.nodeTools.nodeCloseby()

    if MAIN.startingNode == false then
        MAIN.pathFail,_,_, _, MAIN.nodeA, MAIN.nodeB = SCRIPT.nodeTools.pathCloseby()

        if MAIN.pathFail == false then
            SCRIPT.slog("No paths nearby. Cannot run script...")
            return 0
        end

        MAIN.pX, MAIN.pY, MAIN.pZ = getPlayerPos()

        MAIN.distanceToNodeA = SCRIPT.compTools.distanceBetweenPoints(MAIN.pX, MAIN.pY, MAIN.pZ, GLBL.nodes[MAIN.nodeA].x,GLBL.nodes[MAIN.nodeA].y,GLBL.nodes[MAIN.nodeA].z)
        MAIN.distanceToNodeB = SCRIPT.compTools.distanceBetweenPoints(MAIN.pX, MAIN.pY, MAIN.pZ, GLBL.nodes[MAIN.nodeB].x,GLBL.nodes[MAIN.nodeB].y,GLBL.nodes[MAIN.nodeB].z)

        if MAIN.distanceToNodeA < MAIN.distanceToNodeB then
            MAIN.startingNode = MAIN.nodeA
        else
            MAIN.startingNode = MAIN.nodeB
        end
    end

    MAIN.pathTraveled = SCRIPT.travelBot.travelTo(MAIN.startingNode)

    -- leave second argument nil
    MAIN.nodeA, MAIN.nodeB = SCRIPT.findNearestUnvalidatedPath(MAIN.startingNode)

    MAIN.endedAt = nil
    while MAIN.nodeA ~= false do

        if MAIN.endedAt ~= MAIN.nodeA then
            SCRIPT.travelBot.travelTo(MAIN.nodeA)
        end
        SCRIPT.travelBot.travelTo(MAIN.nodeB)
        MAIN.endedAt = MAIN.nodeB

        GLBL.validatedPaths[MAIN.nodeA..MAIN.nodeB] = true

        log("&dNum validated paths: " , SCRIPT.tableKeyCount(GLBL.validatedPaths))

        -- leave at end of while loop
            -- leave second argument nil
            MAIN.nodeA, MAIN.nodeB = SCRIPT.findNearestUnvalidatedPath(MAIN.nodeB)
    end

    SCRIPT.slog("Path validation completed. Saving validated paths")
    SCRIPT.saveValidatedPathsToJson(GLBL.validatedPaths)
    SCRIPT.slog("Paths saved")

    

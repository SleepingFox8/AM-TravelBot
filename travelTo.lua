-- initialization
    -- ensure imports are from file instead of cache
        local function import(path)
            package.loaded[path] = nil
            local imported = require (path)
            package.loaded[path] = nil
            return imported
        end

    -- declare scoped tables
        --initialize GLBL table if needed
            if GLBL == nil then
                GLBL = {}
            end
            
        --initialize SCRIPT table
        --Stores global variables for just this script
            local SCRIPT = {}

    -- import dependencies
        local json = import("./json.lua/json")
        local botTools = import("./AM-BotTools/botTools")
        local compTools = import("./AM-CompTools/compTools")
        local nodeTools = import"nodeTools"
        local travelBot = import"travelBot"

    function SCRIPT.slog(string)
        log("&7[&6TravelBot&7]§f ", string)
    end

    --initialize RNG
        math.randomseed( os.time() )

-- function declarations

        function SCRIPT.getRandomNodeName()
            return SCRIPT.nodeNames[ math.random( #SCRIPT.nodeNames ) ]
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
            -- store function args in scope-safe table
                FUNC.nodeName = nodeName
    
            FUNC.x = GLBL.nodes[FUNC.nodeName].x
            FUNC.y = GLBL.nodes[FUNC.nodeName].y
            FUNC.z = GLBL.nodes[FUNC.nodeName].z
            return SCRIPT.coordinatesToString(FUNC.x,FUNC.y,FUNC.z)
        end

        function SCRIPT.arrivalRoutine()
            GLBL.travelTo_travelCanceled = false
            say("/logout")
            botTools.disconnectIfAfkForTenSeconds()
        end

        function SCRIPT.logTripDetails(etaInSeconds, node)
            --initialize function table
                local FUNC = {}
            -- store function args in scope-safe table
                FUNC.etaInSeconds, FUNC.node = etaInSeconds, node

                -- find node name
                    if SCRIPT.nodeIdToDestName[FUNC.node] ~= nil then
                        FUNC.targetName = SCRIPT.nodeIdToDestName[FUNC.node]
                    else
                        FUNC.targetName = FUNC.node
                    end
                -- format eta
                    FUNC.etaString = SCRIPT.SecondsToClock(FUNC.etaInSeconds)
                -- log details
                    SCRIPT.slog(" Traveling to \"" .. FUNC.targetName .. "\" at " .. SCRIPT.nodeCoordinatesString(FUNC.node) .. " ETA: " .. FUNC.etaString)
        end

        function SCRIPT.attemptTravelTo(targetNode)
            --initialize function table
                local FUNC = {}
            -- store function args in scope-safe table
                FUNC.targetNode = targetNode

            -- determine if path to target
                SCRIPT.slog("Finding path to destination")
                FUNC.pathToTarget, FUNC.etaInSeconds = travelBot.findPathToNode(FUNC.targetNode)
                if FUNC.pathToTarget == false then
                    return false
                end

            -- find node name
                if SCRIPT.nodeIdToDestName[FUNC.targetNode] ~= nil then
                    FUNC.targetName = SCRIPT.nodeIdToDestName[FUNC.targetNode]
                else
                    FUNC.targetName = FUNC.targetNode
                end

            SCRIPT.logTripDetails(FUNC.etaInSeconds, FUNC.targetNode)

            -- travel to destination
                -- start timer
                FUNC.start_time = os.time()
                -- travel to destination
                    GLBL.travelTo_lastTarget = FUNC.targetNode
                    travelBot.travelTypePath(FUNC.pathToTarget)
                -- calculate time it took to complete travel
                    FUNC.timeDiff = os.difftime(os.time(),FUNC.start_time)
                    log(FUNC.targetName)
                SCRIPT.slog("You have arrived at \"" .. FUNC.targetName .. "\" after " .. SCRIPT.SecondsToClock(FUNC.timeDiff))

            SCRIPT.arrivalRoutine()
        end

-- declaration script wide variables
    --load destinations
        SCRIPT.nodeIdToDestName = nodeTools.loadDestinationsFromJSON()
        SCRIPT.destNameToNodeId = nodeTools.getDestNameToNodeId(SCRIPT.nodeIdToDestName)

        -- inject special destinations as options
            if SCRIPT.destNameToNodeId["[Expansion] > Nearest expandable rail"] == nil then
                SCRIPT.destNameToNodeId["[Expansion] > Nearest expandable rail"] = "not nil"
            end

            if SCRIPT.destNameToNodeId["[Demo Mode] continuously travel to random node"] == nil then
                SCRIPT.destNameToNodeId["[Demo Mode] continuously travel to random node"] = "not nil"
            end

    -- get GLBL.nodes
        GLBL.nodes = nodeTools.loadNodesfromJSON()

    -- get list of node names
        SCRIPT.nodeNames = {}
        SCRIPT.i = 1
        for key,value in pairs(GLBL.nodes) do 
            SCRIPT.nodeNames[SCRIPT.i] = key
            -- keep at end of loop
                SCRIPT.i = SCRIPT.i + 1
        end

    GLBL.minNodeDistance = 1000

-- Main program

    --initialize MAIN table
    --Stores variables for just MAIN function
        local MAIN = {}

    -- toggle this script off if it is already running
        if compTools.anotherInstanceOfThisScriptIsRunning() then
            compTools.stopOtherInstancesOfThisScript()
            botTools.freezeAllMotorFunctions()
            -- uncrouch
                sneak(1)
                waitTick()
            SCRIPT.slog("Traveling was canceled")
            GLBL.travelTo_travelCanceled = true
            -- silently end this script
                return 0
        end

    SCRIPT.slog("Finding nearby nodes or paths to travel from...")
    if nodeTools.nodeCloseby() or nodeTools.pathCloseby() then

        MAIN.resume = false
        if GLBL.travelTo_travelCanceled == true then

            if SCRIPT.nodeIdToDestName[GLBL.travelTo_lastTarget] ~= nil then
                MAIN.targetName = SCRIPT.nodeIdToDestName[GLBL.travelTo_lastTarget]
            else
                MAIN.targetName = GLBL.travelTo_lastTarget
            end

            MAIN.resumeOptions = {}
            MAIN.resumeOptions[1] = "Resume Travel"
            MAIN.resumeOptions[2] = "Different Route"

            MAIN.resumeRoute = prompt("Resume travel to \""..MAIN.targetName.."\" ?", "choice", table.unpack(MAIN.resumeOptions))

            if MAIN.resumeRoute == nil then
                SCRIPT.slog("No destination selected. Canceling travel...")
                return 0
            end

            if MAIN.resumeRoute == "Resume Travel" then
                MAIN.resume = true
            else 
                MAIN.resume = false
            end

        end

        if MAIN.resume == true then

            MAIN.targetNode = GLBL.travelTo_lastTarget

            if SCRIPT.attemptTravelTo(MAIN.targetNode) == false then
                SCRIPT.slog("No known path to target destination")
                return 0
            end
        else

            -- prompt player to pick destination
                SCRIPT.namedDestinations = compTools.sortTableByKeys(SCRIPT.destNameToNodeId)
                MAIN.targetName = prompt("Enter destination to travel to: ", "choice", table.unpack(SCRIPT.namedDestinations))

            if MAIN.targetName ~= nil then
                -- catch any special destinations
                    -- [Expansion] > Nearest expandable rail
                        if MAIN.targetName == "[Expansion] > Nearest expandable rail" then
                            MAIN.targetNode = nodeTools.nearestExpandableRail()
                            if MAIN.targetNode ~= false then
                                SCRIPT.nodeIdToDestName[MAIN.targetNode] = "[Expansion] > Nearest expandable rail"
                                -- travel to destination

                                    -- list the coords
                                        SCRIPT.slog("X: " .. GLBL.nodes[MAIN.targetNode].x)
                                        SCRIPT.slog("Y: " .. GLBL.nodes[MAIN.targetNode].y)
                                        SCRIPT.slog("Z: " .. GLBL.nodes[MAIN.targetNode].z)
                                        SCRIPT.slog("Distance: " .. compTools.playerDistanceFrom(GLBL.nodes[MAIN.targetNode].x, GLBL.nodes[MAIN.targetNode].y, GLBL.nodes[MAIN.targetNode].z))

                                    if SCRIPT.attemptTravelTo(MAIN.targetNode) == false then
                                        SCRIPT.slog("No known path to target destination")
                                        return 0
                                    end
                            else
                                SCRIPT.slog("There are currently no known expandable rails")
                            end
                    -- "[Demo Mode] continuously travel to random node"
                        elseif MAIN.targetName == "[Demo Mode] continuously travel to random node" then
                            while(true)do
                                MAIN.targetNode = SCRIPT.getRandomNodeName()
                                GLBL.travelTo_lastTarget = FUNC.targetNode
                                travelBot.travelTo(MAIN.targetNode)
                            end
                else
                    -- travel to destination if path available
                        
                        -- get nodeID of target
                        MAIN.targetNode = SCRIPT.destNameToNodeId[MAIN.targetName]

                        if SCRIPT.attemptTravelTo(MAIN.targetNode) == false then
                            SCRIPT.slog("No known path to target destination")
                            return 0
                        end
                end

                if MAIN.pathTraveled then
                    GLBL.travelTo_travelCanceled = false
                    say("/logout")
                    botTools.disconnectIfAfkForTenSeconds()
                end
            else
                SCRIPT.slog("No destination selected. Canceling travel...")
            end
        end
    else
        SCRIPT.slog("No closeby GLBL.nodes to start travel from...")
    end

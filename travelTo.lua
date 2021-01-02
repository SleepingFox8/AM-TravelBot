-- initialization
    -- import dependencies
        json = require ("./json.lua/json")
        botTools = require ("./AM-Tools/botTools")
        compTools = require ("./AM-Tools/compTools")
        nodeTools = require "nodeTools"
        travelBot = require "travelBot"

    --initialize GLBL table if needed
        if GLBL == nil then
            GLBL = {}
        end
        
    --initialize SCRIPT table
    --Stores global variables for just this script
        local SCRIPT = {}

    --initialize RNG
        math.randomseed( os.time() )

-- function declarations

        function getRandomNodeName()
            return SCRIPT.nodeNames[ math.random( #SCRIPT.nodeNames ) ]
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
            log("&7[&6TravelBot&7]§f Traveling was canceled")
            GLBL.travelTo_travelCanceled = true
            -- silently end this script
                return 0
        end

    log("&7[&6TravelBot&7]§f Finding nearby nodes or paths to travel from...")
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
                log("&7[&6TravelBot&7]§f No destination selected. Canceling travel...")
                return 0
            end

            if MAIN.resumeRoute == "Resume Travel" then
                MAIN.resume = true
            else 
                MAIN.resume = false
            end

        end

        if MAIN.resume == true then

            MAIN.pathTraveled = travelBot.travelTo(GLBL.travelTo_lastTarget)

            if MAIN.pathTraveled then
                GLBL.travelTo_travelCanceled = false
                say("/logout")
                botTools.disconnectIfAfkForTenSeconds()
            end

        else

            -- prompt player to pick destination
                SCRIPT.namedDestinations = botTools.sortTableByKeys(SCRIPT.destNameToNodeId)
                SCRIPT.target = prompt("Enter destination to travel to: ", "choice", table.unpack(SCRIPT.namedDestinations))

            if SCRIPT.target ~= nil then
                -- catch any special destinations
                    -- [Expansion] > Nearest expandable rail
                        if SCRIPT.target == "[Expansion] > Nearest expandable rail" then
                            SCRIPT.target = nodeTools.nearestExpandableRail()
                            if SCRIPT.target ~= false then
                                SCRIPT.nodeIdToDestName[SCRIPT.target] = "[Expansion] > Nearest expandable rail"
                                -- travel to destination
                                    GLBL.travelTo_lastTarget = SCRIPT.target
                                    MAIN.pathTraveled = travelBot.travelTo(SCRIPT.target)
                            else
                                log("&7[&6TravelBot&7]§f There are currently no known expandable rails")
                            end
                    -- "[Demo Mode] continuously travel to random node"
                        elseif SCRIPT.target == "[Demo Mode] continuously travel to random node" then
                            while(true)do
                                SCRIPT.target = getRandomNodeName()
                                travelBot.travelTo(SCRIPT.target)
                            end
                else
                    SCRIPT.target = SCRIPT.destNameToNodeId[SCRIPT.target]
                    -- travel to destination
                        GLBL.travelTo_lastTarget = SCRIPT.target
                        MAIN.pathTraveled = travelBot.travelTo(SCRIPT.target)
                end

                if MAIN.pathTraveled then
                    GLBL.travelTo_travelCanceled = false
                    say("/logout")
                    botTools.disconnectIfAfkForTenSeconds()
                end
            else
                log("&7[&6TravelBot&7]§f No destination selected. Canceling travel...")
            end
        end
    else
        log("&7[&6TravelBot&7]§f No closeby GLBL.nodes to start travel from...")
    end

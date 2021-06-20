--initialization
    -- ensure imports are from file instead of cache
        local function import(path)
            package.loaded[path] = nil
            local imported = require (path)
            package.loaded[path] = nil
            return imported
        end
    -- import dependencies
        local json = import("./json.lua/json")
        local botTools = import("./AM-BotTools/botTools")
        local compTools = import("./AM-CompTools/compTools")

        --initialize "class" object
            local nodeTools = { _version = "0.0.0" }

    --initialize GLBL table if needed
        if GLBL == nil then
            GLBL = {}
        end

--nodeTools function declarations
    --files

        function nodeTools.pathToCurrentStorageDir()
            --function initialization
                --initialize function table
                    local FUNC = {}

            --declare local function variables
                FUNC.player = getPlayer()
                
                if getWorld().isSinglePlayer == true then
                    FUNC.dirString = "nodeData/single-player/" .. FUNC.player.dimension.name .. "/"
                else
                    FUNC.dirString = "nodeData/multiplayer/" .. getWorld().ip .. "/" .. FUNC.player.dimension.name .. "/"
                end

                FUNC.tokens = compTools.split(FUNC.dirString, ":")

            if #FUNC.tokens > 1 then

                FUNC.noColonDirString = FUNC.tokens[1]


                FUNC.i = 2
                while FUNC.i <= #FUNC.tokens do
                    FUNC.noColonDirString = FUNC.noColonDirString .. "~colon~"
                    FUNC.noColonDirString = FUNC.noColonDirString .. FUNC.tokens[FUNC.i]

                    --keep at end of while loop
                        FUNC.i = FUNC.i + 1
                end
                return FUNC.noColonDirString
            else
                return FUNC.dirString
            end
        end

        function nodeTools.file_exists(name)
            --function initialization
                --initialize function table
                    local FUNC = {}
                --store arguments in locally scoped table for scope safety
                    FUNC.name = name

            FUNC.f=io.open(FUNC.name,"r")
            if FUNC.f~=nil then io.close(FUNC.f) return true else return false end
        end

        --leaves existing files alone
        --creates new file if file not yet exist
        function nodeTools.ensureFileExists(dir)
            --function initialization
                --initialize function table
                    local FUNC = {}
                --store arguments in locally scoped table for scope safety
                    FUNC.dir = dir

            FUNC.fileExists = nodeTools.file_exists(dir)
            if FUNC.fileExists ~= true then
                log("&7[&6NodeTools&7]§f File not found... creating new file for given server / dimension")

                --create file
                    FUNC.file = filesystem.open(dir, "w")
                    FUNC.file:close()
                --write empty json data to file
                    --prepair empty json string to write
                        --initialize an empty table for storage (otherwise retreiving a json from an empty file will err)
                        GLBL.nodes = {}
                        FUNC.jsonNodes = json.encode(GLBL.nodes)

                    -- opens file
                    FUNC.file = io.open(dir, "w")

                    FUNC.file:write(FUNC.jsonNodes)
                    FUNC.file:close()
            end
        end

        --node data
            function nodeTools.loadNodesfromJSON()
                --function initialization
                    --initialize function table
                        local FUNC = {}

                FUNC.player = getPlayer()
                if GLBL.nodes == nil or GLBL.lastConnectedServerIpForNodes ~= getWorld().ip or GLBL.lastDimensionForNodes ~= FUNC.player.dimension.name then
                    log("&7[&6NodeTools&7]§f retrieving nodes for given server/dimension from file...")
                    nodeTools.ensureFileExists(nodeTools.pathToCurrentStorageDir() .. "nodes.json")
                    -- update last world data grabbed from
                        GLBL.lastConnectedServerIpForNodes = getWorld().ip
                        GLBL.lastDimensionForNodes = FUNC.player.dimension.name
                    return json.decode(compTools.readAll(nodeTools.pathToCurrentStorageDir() .. "nodes.json"))
                else
                    return GLBL.nodes
                end
            end

            function nodeTools.saveNodesToJSON()
                --function initialization
                    --initialize function table
                        local FUNC = {}

                nodeTools.ensureFileExists(nodeTools.pathToCurrentStorageDir() .. "nodes.json")
                -- save GLBL.nodes to file
                    FUNC.jsonNodes = json.encode(GLBL.nodes)

                    -- opens file
                    FUNC.file = io.open(nodeTools.pathToCurrentStorageDir() .. "nodes.json", "w")

                    FUNC.file:write(FUNC.jsonNodes)

                    -- closes file
                    FUNC.file:close()
            end

        --destinations
            function nodeTools.loadDestinationsFromJSON()
                nodeTools.ensureFileExists(nodeTools.pathToCurrentStorageDir() .. "destinations.json")
                return json.decode(compTools.readAll(nodeTools.pathToCurrentStorageDir() .. "destinations.json"))
            end

            function nodeTools.getDestNameToNodeId(table)
                --function initialization
                    --initialize function table
                        local FUNC = {}
                    --store arguments in locally scoped table for scope safety
                        FUNC.table = table

                FUNC.destNameToNodeId = {}
                for key,value in pairs(FUNC.table) do 
                    FUNC.ID = key
                    FUNC.destName = value

                    FUNC.destNameToNodeId[FUNC.destName] = FUNC.ID
                end
                return FUNC.destNameToNodeId
            end

    function nodeTools.nodeCloseby()
        --function initialization
            --initialize function table
                local FUNC = {}

        GLBL.nodes = nodeTools.loadNodesfromJSON()

        -- find nearest node
            FUNC.nearestNodeName = nil
            FUNC.nearestNodeDistance = 1/0

            for key,value in pairs(GLBL.nodes) do 
                FUNC.node = key
                FUNC.x = GLBL.nodes[FUNC.node].x
                FUNC.y = GLBL.nodes[FUNC.node].y
                FUNC.z = GLBL.nodes[FUNC.node].z
                if compTools.playerDistanceFrom(FUNC.x,FUNC.y,FUNC.z) < FUNC.nearestNodeDistance then
                    FUNC.nearestNodeDistance = compTools.playerDistanceFrom(FUNC.x,FUNC.y,FUNC.z)
                    FUNC.nearestNodeName = FUNC.node
                end
            end
        if FUNC.nearestNodeDistance < 10 then
            return FUNC.nearestNodeName
        else
            return false
        end
    end

    function nodeTools.nearestExpandableRail()
        --function initialization
            --initialize function table
                local FUNC = {}

        GLBL.nodes = nodeTools.loadNodesfromJSON()

        FUNC.expandableCount = 0

        -- find nearest node
            FUNC.nearestExpandableRail = nil
            FUNC.nearestExpandableRailDistance = 1/0

            for key,value in pairs(GLBL.nodes) do 
                FUNC.node = key
                FUNC.x = GLBL.nodes[FUNC.node].x
                FUNC.y = GLBL.nodes[FUNC.node].y
                FUNC.z = GLBL.nodes[FUNC.node].z
                if GLBL.nodes[FUNC.node].pathType == "rail" and compTools.numOfKeysInTable(GLBL.nodes[FUNC.node].connections) == 1 then

                    FUNC.expandableCount = FUNC.expandableCount + 1

                    if compTools.playerDistanceFrom(FUNC.x,FUNC.y,FUNC.z) < FUNC.nearestExpandableRailDistance then
                        FUNC.nearestExpandableRailDistance = compTools.playerDistanceFrom(FUNC.x,FUNC.y,FUNC.z)
                        FUNC.nearestExpandableRail = FUNC.node
                    end
                end
            end

        if FUNC.nearestExpandableRail ~= nil then
            return FUNC.nearestExpandableRail, FUNC.expandableCount
        else
            return false
        end
    end

    function nodeTools.pathCloseby()
        --function initialization
            --initialize function table
                local FUNC = {}

        --declare local function variables
            FUNC.nearestPathPoint = {}
            FUNC.nearestPathPointDistance = 1/0
            FUNC.nodeToolsDrawnLines = {}
            FUNC.nodeA = 0
            FUNC.nodeB = 0
            FUNC.pathType = 0

        GLBL.nodes = nodeTools.loadNodesfromJSON()

        for key,value in pairs(GLBL.nodes) do 
            FUNC.node = key
            for key,value in pairs(GLBL.nodes[FUNC.node]["connections"]) do
                FUNC.neighbor = key
                if FUNC.nodeToolsDrawnLines[FUNC.neighbor .. FUNC.node] == nil then

                    -- only consider draw lines that have at least one node within GLBL.minNodeDistance to the player.
                    -- nodeTools.closestPointOnLineToPlayer() is computationally intensive on super large worlds
                    if compTools.playerDistanceFrom(GLBL.nodes[FUNC.node].x,GLBL.nodes[FUNC.node].y,GLBL.nodes[FUNC.node].z) < GLBL.minNodeDistance or compTools.playerDistanceFrom(GLBL.nodes[FUNC.neighbor].x,GLBL.nodes[FUNC.neighbor].y,GLBL.nodes[FUNC.neighbor].z) < GLBL.minNodeDistance then
                   
                        FUNC.ntX, FUNC.ntY, FUNC.ntZ = nodeTools.closestPointOnLineToPlayer(GLBL.nodes[FUNC.node].x,GLBL.nodes[FUNC.node].y,GLBL.nodes[FUNC.node].z,      GLBL.nodes[FUNC.neighbor].x,GLBL.nodes[FUNC.neighbor].y,GLBL.nodes[FUNC.neighbor].z)

                        if compTools.playerDistanceFrom(FUNC.ntX, FUNC.ntY, FUNC.ntZ) < FUNC.nearestPathPointDistance then
                            FUNC.nearestPathPointDistance = compTools.playerDistanceFrom(FUNC.ntX, FUNC.ntY, FUNC.ntZ)
                            FUNC.nearestPathPoint = {FUNC.ntX, FUNC.ntY, FUNC.ntZ}
                            FUNC.nodeA = FUNC.node
                            FUNC.nodeB = FUNC.neighbor

                            -- determine type of connection
                                FUNC.pathType = nodeTools.getPathTypeFromNodeTypes(GLBL.nodes[FUNC.nodeA].pathType, GLBL.nodes[FUNC.nodeB].pathType)
                        end

                        --leave at end of if
                            FUNC.nodeToolsDrawnLines[FUNC.node .. FUNC.neighbor] = true
                    end
                end
            end
        end

        if FUNC.nearestPathPointDistance < 10 then
            return FUNC.nearestPathPoint[1], FUNC.nearestPathPoint[2], FUNC.nearestPathPoint[3], FUNC.nearestPathPointDistance, FUNC.nodeA, FUNC.nodeB, FUNC.pathType
            -- FUNC.nodeA, FUNC.nodeB, FUNC.pathType
        else
            return false
        end

    end

    -- node names
        function randomHexChar()
            --function initialization
                --initialize function table
                    local FUNC = {}

            FUNC.randHexNum = math.random(16) - 1
            if FUNC.randHexNum < 10 then
                return FUNC.randHexNum
            elseif FUNC.randHexNum == 10 then
                return "A"
            elseif FUNC.randHexNum == 11 then
                return "B"
            elseif FUNC.randHexNum == 12 then
                return "C"
            elseif FUNC.randHexNum == 13 then
                return "D"
            elseif FUNC.randHexNum == 14 then
                return "E"
            elseif FUNC.randHexNum == 15 then
                return "F"
            end
        end

        function nodeTools.generateRandomNodeName()
            --function initialization
                --initialize function table
                    local FUNC = {}

            FUNC.nodeName = "0x"
            FUNC.i = 0
            while(FUNC.i < 32) do
                FUNC.nodeName = FUNC.nodeName .. randomHexChar()
                -- keep at end of loop
                    FUNC.i = FUNC.i + 1
            end
            return FUNC.nodeName
        end

        function nodeTools.saveDestinationsToJson(destinations)
            --function initialization
                --initialize function table
                    local FUNC = {}
                --store arguments in locally scoped table for scope safety
                    FUNC.destinations = destinations
            
            nodeTools.ensureFileExists(nodeTools.pathToCurrentStorageDir() .. "destinations.json")
            FUNC.jsonDestinations = json.encode(FUNC.destinations)

            -- opens file
            FUNC.file = io.open(nodeTools.pathToCurrentStorageDir() .. "destinations.json", "w")

            FUNC.file:write(FUNC.jsonDestinations)

            -- closes file
            FUNC.file:close()
        end

        function nodeTools.assignNodeDestinationName(nodeId, destName)
            --function initialization
                --initialize function table
                    local FUNC = {}
                --store arguments in locally scoped table for scope safety
                    FUNC.nodeId = nodeId
                    FUNC.destName = destName

            GLBL.nodes = nodeTools.loadNodesfromJSON()
            if FUNC.destName ~= nil then
                log("Assigning destName: " .. FUNC.destName .. " to nodeId: " .. FUNC.nodeId)
            else
                log("Removing Destination status")
            end
            assert(GLBL.nodes[FUNC.nodeId] ~= nil, "Attempt to assign destination name to non existant node...")
            FUNC.destinations = nodeTools.loadDestinationsFromJSON()
            FUNC.destinations[FUNC.nodeId] = FUNC.destName
            nodeTools.saveDestinationsToJson(FUNC.destinations)
        end

    -- select
        function nodeTools.selectNode(nodeName)
            --function initialization
                --initialize function table
                    local FUNC = {}
                --store arguments in locally scoped table for scope safety
                    FUNC.nodeName = nodeName

            -- opens file for writing
                FUNC.file = io.open("nodeManagementTools/selectedNode.txt", "w")
    
            -- writes node name to file
                FUNC.file:write(FUNC.nodeName)
    
            -- closes file
                FUNC.file:close()
        end

    function nodeTools.maxHorizontalDistanceBetweenPoints(x1,y1,z1,x2,y2,z2)
        --function initialization
                --initialize function table
                    local FUNC = {}
                --store arguments in locally scoped table for scope safety
                    FUNC.x1,FUNC.y1,FUNC.z1 = x1,y1,z1
                    FUNC.x2,FUNC.y2,FUNC.z2 = x2,y2,z2

        --declare local function variables
            --find distances
                FUNC.dx = math.abs(x2 - x1)
                FUNC.dy = math.abs(y2 - y1)
                FUNC.dz = math.abs(z2 - z1)

        --find axis with greatest distance
            -- Driving axis is X-axis
                if (FUNC.dx >= FUNC.dy and FUNC.dx >= FUNC.dz) then
                    return FUNC.dx
            -- Driving axis is Y-axis
                elseif (FUNC.dy >= FUNC.dx and FUNC.dy >= FUNC.dz) then
                    return FUNC.dy
            -- Driving axis is Z-axis"
                else
                    return FUNC.dz
                end
    end

    function nodeTools.pointBetweenPointsAtHorizontalDistance(x1,y1,z1,x2,y2,z2, distanceFromPointOne)
        --function initialization
                --initialize function table
                    local FUNC = {}
                --store arguments in locally scoped table for scope safety
                    FUNC.x1,FUNC.y1,FUNC.z1 = x1,y1,z1
                    FUNC.x2,FUNC.y2,FUNC.z2 = x2,y2,z2
                    FUNC.distanceFromPointOne = distanceFromPointOne

        --declare local function variables
            --find distances
                FUNC.dx = math.abs(FUNC.x2 - FUNC.x1)
                FUNC.dy = math.abs(FUNC.y2 - FUNC.y1)
                FUNC.dz = math.abs(FUNC.z2 - FUNC.z1)

        --determine directions
            if (FUNC.x2 > FUNC.x1) then
                FUNC.xs = 1
            else
                FUNC.xs = -1
            end

            if (FUNC.y2 > FUNC.y1) then 
                FUNC.ys = 1
            else
                FUNC.ys = -1
            end

            if (FUNC.z2 > FUNC.z1) then
                FUNC.zs = 1
            else
                FUNC.zs = -1
            end

        --find driving axis
            -- Driving axis is X-axis
                if (FUNC.dx >= FUNC.dy and FUNC.dx >= FUNC.dz) then
                    FUNC.percentTraveledAlongLine = FUNC.distanceFromPointOne / FUNC.dx
            -- Driving axis is Y-axis
                elseif (FUNC.dy >= FUNC.dx and FUNC.dy >= FUNC.dz) then
                    FUNC.percentTraveledAlongLine = FUNC.distanceFromPointOne / FUNC.dy
            -- Driving axis is Z-axis"
                else
                    FUNC.percentTraveledAlongLine = FUNC.distanceFromPointOne / FUNC.dz
                end


        --find true line point
            -- find x
                FUNC.exactX = FUNC.x1 + (FUNC.dx * FUNC.percentTraveledAlongLine * FUNC.xs)
            -- find y
                FUNC.exactY = FUNC.y1 + (FUNC.dy * FUNC.percentTraveledAlongLine * FUNC.ys)
            -- find z
                FUNC.exactZ = FUNC.z1 + (FUNC.dz * FUNC.percentTraveledAlongLine * FUNC.zs)
        --find pixel line point via rounding to nearest pixel
            FUNC.pixelX = math.floor(FUNC.exactX+0.5)
            FUNC.pixelY = math.floor(FUNC.exactY+0.5)
            FUNC.pixelZ = math.floor(FUNC.exactZ+0.5)
        return FUNC.pixelX, FUNC.pixelY, FUNC.pixelZ
    end

    function nodeTools.closestPointOnLineToPlayer(x1,y1,z1,x2,y2,z2)
        if x1==x2 and y1==y2 and z1==z2 then
            log("WARNING node and neighbor sharing same position at x,y,z: ", x1,y1,z1)
            return x1,y1,z1
        end
        --function initialization
                --initialize function table
                    local FUNC = {}
                --store arguments in locally scoped table for scope safety
                    FUNC.x1,FUNC.y1,FUNC.z1 = x1,y1,z1
                    FUNC.x2,FUNC.y2,FUNC.z2 = x2,y2,z2

        --declare local variables
            --find distances
                FUNC.dx = math.abs(x2 - x1)
                FUNC.dy = math.abs(y2 - y1)
                FUNC.dz = math.abs(z2 - z1)
            --not yet assignable
                FUNC.L = 0
                FUNC.R = 0
                FUNC.closestPoint = 0

        --find driving axis
            -- Driving axis is X-axis
                if (FUNC.dx >= FUNC.dy and FUNC.dx >= FUNC.dz) then
                    FUNC.L = 0
                    FUNC.R = FUNC.dx
            -- Driving axis is Y-axis
                elseif (FUNC.dy >= FUNC.dx and FUNC.dy >= FUNC.dz) then
                    FUNC.L = 0
                    FUNC.R = FUNC.dy
            -- Driving axis is Z-axis"
                else
                    FUNC.L = 0
                    FUNC.R = FUNC.dz
                end
        --binary search for the closest point
            FUNC.closestPoint = {}
            while FUNC.L <= FUNC.R do
                --declare local variables
                    FUNC.midPoint = math.floor((FUNC.L + FUNC.R) / 2)
                    FUNC.lowerPoint = FUNC.midPoint - 1
                    FUNC.higherPoint = FUNC.midPoint + 1

                    FUNC.mx,FUNC.my,FUNC.mz = nodeTools.pointBetweenPointsAtHorizontalDistance(x1,y1,z1, x2,y2,z2, FUNC.midPoint)
                    FUNC.lx,FUNC.ly,FUNC.lz = nodeTools.pointBetweenPointsAtHorizontalDistance(x1,y1,z1, x2,y2,z2, FUNC.lowerPoint)
                    FUNC.hx,FUNC.hy,FUNC.hz = nodeTools.pointBetweenPointsAtHorizontalDistance(x1,y1,z1, x2,y2,z2, FUNC.higherPoint)

                    FUNC.lowPointDistance = compTools.playerDistanceFrom(FUNC.lx,FUNC.ly,FUNC.lz)
                    FUNC.midPointDistance = compTools.playerDistanceFrom(FUNC.mx,FUNC.my,FUNC.mz)
                    FUNC.highPointDistance = compTools.playerDistanceFrom(FUNC.hx,FUNC.hy,FUNC.hz)

                --midpoint is closest
                    if FUNC.midPointDistance < FUNC.lowPointDistance and FUNC.midPointDistance < FUNC.highPointDistance then
                        FUNC.closestPoint = {FUNC.mx,FUNC.my,FUNC.mz}
                        break
                --FUNC.lowerPoint is closest
                    elseif FUNC.lowPointDistance < FUNC.midPointDistance and FUNC.lowPointDistance < FUNC.highPointDistance then
                        FUNC.R = FUNC.midPoint - 1

                        -- set midpoint as closest since FUNC.lowerPoint could be out of bounds
                        FUNC.closestPoint = {FUNC.mx,FUNC.my,FUNC.mz}

                --FUNC.higherPoint is closest
                    elseif FUNC.highPointDistance < FUNC.midPointDistance and FUNC.highPointDistance < FUNC.lowPointDistance then
                        FUNC.L = FUNC.midPoint + 1

                        -- set midpoint as closest since FUNC.higherPoint could be out of bounds
                        FUNC.closestPoint = {FUNC.mx,FUNC.my,FUNC.mz}

                --mid and lower are tied
                    elseif FUNC.midPointDistance == FUNC.lowPointDistance then
                        FUNC.closestPoint = {FUNC.mx,FUNC.my,FUNC.mz}
                        break
                --mid and higher are tied
                    elseif FUNC.midPointDistance == FUNC.highPointDistance then
                        FUNC.closestPoint = {FUNC.mx,FUNC.my,FUNC.mz}
                        break
                    end
            end
        return FUNC.closestPoint[1], FUNC.closestPoint[2], FUNC.closestPoint[3]
    end

    --Zones

        function nodeTools.getPolyZones()
            --function initialization
                --initialize function table
                    local FUNC = {}

            nodeTools.ensureFileExists(nodeTools.pathToCurrentStorageDir() .. "zones.json")
            return json.decode(compTools.readAll(nodeTools.pathToCurrentStorageDir() .. "zones.json"))
        end

        -- returns table containing every pixel in a polyZone
        function nodeTools.getPolyPixels(polygon)
            --initialize function table
                local FUNC = {}

            --store arguments in known scoped table
                FUNC.polygon = polygon

            FUNC.polyPixels = {}

            --calculate pixels for all of polyLine
                FUNC.lastPoint = FUNC.polygon[1]
                -- for each line
                    FUNC.i = 2
                    while FUNC.i <= #FUNC.polygon do
                        FUNC.point = FUNC.polygon[FUNC.i]
                        FUNC.linePixels = compTools.Bresenham3D(FUNC.lastPoint[1],0,FUNC.lastPoint[2], FUNC.point[1],0,FUNC.point[2])

                        -- append all pixels to FUNC.polyPixels
                            FUNC.j = 1
                            while FUNC.j <= #FUNC.linePixels do
                                FUNC.polyPixels[#FUNC.polyPixels + 1] = {
                                    ["x"] = FUNC.linePixels[FUNC.j][1],
                                    ["z"] = FUNC.linePixels[FUNC.j][3]
                                }
                                -- keep at end of while loop
                                    FUNC.j = FUNC.j + 1
                            end

                        -- keep at end of while loop
                            FUNC.lastPoint = FUNC.point
                            FUNC.i = FUNC.i + 1
                    end
            --calculate pixels for line between start and finish points in polyLine
                FUNC.firstPoint = FUNC.polygon[1]
                FUNC.linePixels = compTools.Bresenham3D(FUNC.lastPoint[1],0,FUNC.lastPoint[2], FUNC.firstPoint[1],0,FUNC.firstPoint[2])

                -- append lastLine pixels to FUNC.polyPixels
                    FUNC.j = 1
                    while FUNC.j <= #FUNC.linePixels do
                        FUNC.polyPixels[#FUNC.polyPixels + 1] = {
                            ["x"] = FUNC.linePixels[FUNC.j][1],
                            ["z"] = FUNC.linePixels[FUNC.j][3]
                        }
                        -- keep at end of while loop
                            FUNC.j = FUNC.j + 1
                    end
                    
            return FUNC.polyPixels
        end

        function nodeTools.polyPixelsToPixelTable(polyPixels)
            --initialize function table
                local FUNC = {}
            --store arguments in known scoped table
                FUNC.polyPixels = polyPixels

            FUNC.polyTable = {}

            FUNC.i = 1
            while FUNC.i <= #FUNC.polyPixels do
                FUNC.coordString = "x:" .. FUNC.polyPixels[FUNC.i].x .. " z:" .. FUNC.polyPixels[FUNC.i].z
                FUNC.polyTable[FUNC.coordString] = true

                --keep at end of while loop
                    FUNC.i = FUNC.i + 1
            end

            return FUNC.polyTable
        end

        function nodeTools.getZoneBounds(polyPixels)
            --initialize function table
                local FUNC = {}
            --store arguments in known scoped table
                FUNC.polyPixels = polyPixels

            FUNC.bounds = {
                ["lowestX"] = 1/0,
                ["lowestZ"] = 1/0,
                ["highestX"] = -1/0,
                ["highestZ"] = -1/0
            }
            
            -- for loop
                FUNC.i = 1
                while FUNC.i <= #FUNC.polyPixels do

                    -- update lowestX
                        if FUNC.polyPixels[FUNC.i].x < FUNC.bounds.lowestX then
                            FUNC.bounds.lowestX = FUNC.polyPixels[FUNC.i].x
                        end

                    -- update highestX
                        if FUNC.polyPixels[FUNC.i].x > FUNC.bounds.highestX then
                            FUNC.bounds.highestX = FUNC.polyPixels[FUNC.i].x
                        end
                    -- update lowestZ
                        if FUNC.polyPixels[FUNC.i].z < FUNC.bounds.lowestZ then
                            FUNC.bounds.lowestZ = FUNC.polyPixels[FUNC.i].z
                        end
                    -- update highestZ
                        if FUNC.polyPixels[FUNC.i].z > FUNC.bounds.highestZ then
                            FUNC.bounds.highestZ = FUNC.polyPixels[FUNC.i].z
                        end

                    -- keep at end of loop
                        FUNC.i = FUNC.i + 1
                end

            return FUNC.bounds
        end

        function nodeTools.getZoneData()
            --initialize function table
                local FUNC = {}


            FUNC.player = getPlayer()
            if GLBL.zoneData == nil or GLBL.lastConnectedServerIpForZoneData ~= getWorld().ip or GLBL.lastDimensionForZoneData ~= FUNC.player.dimension.name then
                -- update last world data grabbed from
                    GLBL.lastConnectedServerIpForZoneData = getWorld().ip
                    GLBL.lastDimensionForZoneData = FUNC.player.dimension.name
                log("&7[&6NodeTools&7]§f retrieving \"zone data\" for given server/dimension from file...")
                FUNC.zoneData = {}
                GLBL.polyZones = nodeTools.getPolyZones()

                for key,value in pairs(GLBL.polyZones) do 
                    FUNC.zoneName = key

                    -- calculate zone properties
                        FUNC.polyPixels = nodeTools.getPolyPixels(GLBL.polyZones[FUNC.zoneName])

                    FUNC.zoneData[FUNC.zoneName] = {
                        ["zoneName"] = FUNC.zoneName,
                        ["pixelTable"] = nodeTools.polyPixelsToPixelTable(FUNC.polyPixels),
                        ["zoneBounds"] = nodeTools.getZoneBounds(FUNC.polyPixels),
                        ["polyPixels"] = FUNC.polyPixels
                    }
                end

                return FUNC.zoneData
            else
                return GLBL.zoneData
            end
        end

        function nodeTools.pointInZone(x,z,zoneName,zoneData)
            --initialize function table
                local FUNC = {}
            --store arguments in known scoped table
                FUNC.x = x
                FUNC.z = z
                FUNC.zoneName = zoneName
                FUNC.zoneData = zoneData

            FUNC.origX = FUNC.x
            FUNC.origZ = FUNC.z

            -- inside bounding box
                if FUNC.x < FUNC.zoneData[FUNC.zoneName].zoneBounds.lowestX then
                    return false
                elseif FUNC.x > FUNC.zoneData[FUNC.zoneName].zoneBounds.highestX then
                    return false
                elseif FUNC.z < FUNC.zoneData[FUNC.zoneName].zoneBounds.lowestZ then
                    return false
                elseif FUNC.z > FUNC.zoneData[FUNC.zoneName].zoneBounds.highestZ then
                    return false
            -- outside bounding box
                else
                    FUNC.oddIntersections = 0
                    -- raycast east
                        FUNC.intersections = 0
                        FUNC.lastBlockWasIntersection = false
                        -- for loop
                            while FUNC.x <= FUNC.zoneData[FUNC.zoneName].zoneBounds.highestX do
                                FUNC.coordString = "x:" .. FUNC.x .. " z:" .. FUNC.z
                                if FUNC.zoneData[FUNC.zoneName].pixelTable[FUNC.coordString] ~= nil then
                                    -- ensure horizontal lines are counted as only one intersection
                                        if FUNC.lastBlockWasIntersection == false then
                                            FUNC.intersections = FUNC.intersections + 1
                                        end
                                    FUNC.lastBlockWasIntersection = true
                                else
                                    FUNC.lastBlockWasIntersection = false
                                end

                                -- keep at end of loop
                                    FUNC.x = FUNC.x + 1
                            end
                        -- store intersection result for quorum
                            if not (FUNC.intersections % 2 == 0) then
                                -- .....it is odd
                                FUNC.oddIntersections = FUNC.oddIntersections + 1
                            end


                    -- raycast south
                        -- restore original point values
                            FUNC.x = FUNC.origX
                            FUNC.z = FUNC.origZ

                        FUNC.intersections = 0
                        FUNC.lastBlockWasIntersection = false
                        -- for loop
                            while FUNC.x <= FUNC.zoneData[FUNC.zoneName].zoneBounds.highestX and FUNC.z <= FUNC.zoneData[FUNC.zoneName].zoneBounds.highestZ do
                                -- check for intersection
                                    FUNC.coordString = "x:" .. FUNC.x .. " z:" .. FUNC.z
                                    if FUNC.zoneData[FUNC.zoneName].pixelTable[FUNC.coordString] ~= nil then
                                        -- ensure horizontal lines are counted as only one intersection
                                            if FUNC.lastBlockWasIntersection == false then
                                                FUNC.intersections = FUNC.intersections + 1
                                            end
                                        FUNC.lastBlockWasIntersection = true
                                    else
                                        FUNC.lastBlockWasIntersection = false
                                    end

                                -- move one block south
                                    FUNC.z = FUNC.z + 1
                            end
                        -- store intersection result for quorum
                            if not (FUNC.intersections % 2 == 0) then
                                -- .....it is odd
                                FUNC.oddIntersections = FUNC.oddIntersections + 1
                            end


                    -- raycast south east
                        -- restore original point values
                            FUNC.x = FUNC.origX
                            FUNC.z = FUNC.origZ

                        FUNC.intersections = 0
                        FUNC.lastBlockWasIntersection = false
                        -- for loop
                            while FUNC.x <= FUNC.zoneData[FUNC.zoneName].zoneBounds.highestX and FUNC.z <= FUNC.zoneData[FUNC.zoneName].zoneBounds.highestZ do
                                -- check for intersection
                                    FUNC.coordString = "x:" .. FUNC.x .. " z:" .. FUNC.z
                                    if FUNC.zoneData[FUNC.zoneName].pixelTable[FUNC.coordString] ~= nil then
                                        -- ensure horizontal lines are counted as only one intersection
                                            if FUNC.lastBlockWasIntersection == false then
                                                FUNC.intersections = FUNC.intersections + 1
                                            end
                                        FUNC.lastBlockWasIntersection = true
                                    else
                                        FUNC.lastBlockWasIntersection = false
                                    end

                                -- move one block east
                                    FUNC.x = FUNC.x + 1

                                -- check for intersection
                                    FUNC.coordString = "x:" .. FUNC.x .. " z:" .. FUNC.z
                                    if FUNC.zoneData[FUNC.zoneName].pixelTable[FUNC.coordString] ~= nil then
                                        -- ensure horizontal lines are counted as only one intersection
                                            if FUNC.lastBlockWasIntersection == false then
                                                FUNC.intersections = FUNC.intersections + 1
                                            end
                                        FUNC.lastBlockWasIntersection = true
                                    else
                                        FUNC.lastBlockWasIntersection = false
                                    end

                                -- move one block south
                                    FUNC.z = FUNC.z + 1
                            end
                        -- store intersection result for quorum
                            if not (FUNC.intersections % 2 == 0) then
                                -- .....it is odd
                                FUNC.oddIntersections = FUNC.oddIntersections + 1
                            end



                    -- return result of quorum
                        if FUNC.oddIntersections >= 2 then
                            -- .....it is odd
                            return true
                        else
                            -- .....it is even
                            return false
                        end
                end
        end

        function nodeTools.playerInZone(zoneName, zoneData)
            --initialize function table
                local FUNC = {}
            --store arguments in known scoped table
                FUNC.zoneName = zoneName
                FUNC.zoneData = zoneData

            FUNC.pX, FUNC.pY, FUNC.pZ = getPlayerPos()
            FUNC.playerInZone = nodeTools.pointInZone(math.floor(FUNC.pX),math.floor(FUNC.pZ), FUNC.zoneName,FUNC.zoneData)

            if FUNC.playerInZone then
                return true
            else
                return false
            end
        end

    function nodeTools.getPathTypeFromNodeTypes(nodeOnePathType, nodeTwoPathType)
            if nodeOnePathType == nodeTwoPathType then
                return nodeOnePathType
            else
                return "normal"
            end
    end

    function nodeTools.clostestNodeTo(x,y,z)
        --initialize function table
            local FUNC = {}

        -- find nearest node
            FUNC.nearestNodeName = nil
            FUNC.nearestNodeDistance = 1/0

            for key,value in pairs(GLBL.nodes) do
                FUNC.node = key
                -- get node location
                    FUNC.nX = GLBL.nodes[FUNC.node].x
                    FUNC.nY = GLBL.nodes[FUNC.node].y
                    FUNC.nZ = GLBL.nodes[FUNC.node].z
                FUNC.distanceToNode = compTools.distanceBetweenPoints(x,y,z, FUNC.nX,FUNC.nY,FUNC.nZ)
                if FUNC.distanceToNode < FUNC.nearestNodeDistance then
                    FUNC.nearestNodeDistance = FUNC.distanceToNode
                    FUNC.nearestNodeName = node
                end
            end
        return FUNC.nearestNodeName
    end

return nodeTools
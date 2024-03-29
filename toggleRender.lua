--initialization

    --initialize SCRIPT table
    --Stores global variables for just this script
        local SCRIPT = {}

    -- ensure imports are from file instead of cache
        local function import(path)
            package.loaded[path] = nil
            local imported = require (path)
            package.loaded[path] = nil
            return imported
        end
    -- import dependencies
        SCRIPT.compTools = import("./AM-CompTools/compTools")
        SCRIPT.nodeTools = import"nodeTools"
        SCRIPT.json = import("./json.lua/json")
        
    --initialize GLBL table if needed
        if GLBL == nil then
            GLBL = {}
        end

-- declare script wide variables

    --declare SCRIPT.colors table for passing SCRIPT.colors to AdvancedMacros 3Dhud blocks
        SCRIPT.colors = {
            blue = {
                -- red
                    [1] = 0,
                -- green
                    [2] = 0,
                -- blue
                    [3] = 1,
                -- opacity
                    [4] = 1     
            },
            lightBlue = {
                -- red
                    [1] = 0.5,
                -- green
                    [2] = 0.5,
                -- blue
                    [3] = 1,
                -- opacity
                    [4] = 1     
            },
            green = {
                -- red
                    [1] = 0,
                -- green
                    [2] = 1,
                -- blue
                    [3] = 0,
                -- opacity
                    [4] = 1     
            },
            red = {
                -- red
                    [1] = 1,
                -- green
                    [2] = 0,
                -- blue
                    [3] = 0,
                -- opacity
                    [4] = 1     
            },
            yellow = {
                -- red
                    [1] = 1,
                -- green
                    [2] = 1,
                -- blue
                    [3] = 0,
                -- opacity
                    [4] = 1     
            },
            grey = {
                -- red
                    [1] = 0.5,
                -- green
                    [2] = 0.5,
                -- blue
                    [3] = 0.5,
                -- opacity
                    [4] = 1
            }
        }

    SCRIPT.renderDistance = 100
    SCRIPT.frameBuffer = {}

    --load destinations
        SCRIPT.nodeIdToDestName = SCRIPT.nodeTools.loadDestinationsFromJSON()
        -- SCRIPT.destNameToNodeId = SCRIPT.nodeTools.getDestNameToNodeId(SCRIPT.nodeIdToDestName)

-- functions

    function SCRIPT.replace_char(pos, str, r)
        return str:sub(1, pos-1) .. r .. str:sub(pos+1)
    end
    function SCRIPT.loadValidatedPathsFromJson()
        --function initialization
            --initialize function table
                local FUNC = {}

        -- SCRIPT.nodeTools.ensureFileExists(SCRIPT.nodeTools.pathToCurrentStorageDir() .. "validatedPaths.json")
        SCRIPT.nodeTools.ensureFileExists(SCRIPT.nodeTools.pathToCurrentStorageDir() .. "validatedPaths.json")
        FUNC.fileString = SCRIPT.compTools.readAll(SCRIPT.nodeTools.pathToCurrentStorageDir() .. "validatedPaths.json")

        -- turn string to valid JSON
        FUNC.fileString = "{".. SCRIPT.replace_char(#FUNC.fileString, FUNC.fileString, "}")

        return SCRIPT.json.decode(FUNC.fileString )
    end
    -- GLBL.rendering
            -- private functions 
                -- node visualization
                --spawn blocks as rendered
                    function spawnBlockAt(x,y,z, color, blockSize)
                        --function initialization
                            --initialize function table
                                local FUNC = {}
                            --store arguments in locally scoped table for scope safety
                                FUNC.x = x
                                FUNC.y = y
                                FUNC.z = z
                                FUNC.color = color
                                FUNC.blockSize = blockSize

                        -- spawn hud3D block
                            FUNC.x = FUNC.x - ((FUNC.blockSize-1) / 2)
                            FUNC.y = FUNC.y - ((FUNC.blockSize-1) / 2)
                            FUNC.z = FUNC.z - ((FUNC.blockSize-1) / 2)
                            FUNC.hb = hud3D.newBlock(FUNC.x,FUNC.y,FUNC.z)
                            FUNC.hb.enableDraw()
                            FUNC.hb.overlay()
                            FUNC.hb.setColor(FUNC.color)
                            FUNC.hb.setWidth( FUNC.blockSize )
                            FUNC.hb.xray(GLBL.toggleRenderXray)
                    end

                -- prepair blocks to be rendered
                    function prepairBlockAt(x,y,z, color, blockSize)
                        --function initialization
                            --initialize function table
                                local FUNC = {}
                            --store arguments in locally scoped table for scope safety
                                FUNC.x = x
                                FUNC.y = y
                                FUNC.z = z
                                FUNC.color = color
                                FUNC.blockSize = blockSize

                        if SCRIPT.compTools.playerhorizontalSquareDistanceBetween(FUNC.x,FUNC.z) <= SCRIPT.renderDistance then
                            SCRIPT.frameBuffer[#SCRIPT.frameBuffer+1]= {
                                ["x"] = FUNC.x,
                                ["y"] = FUNC.y,
                                ["z"] = FUNC.z,
                                ["color"] = FUNC.color,
                                ["blockSize"] = FUNC.blockSize
                            }
                        end
                    end

                function prepairPoints(listOfPoints, color)
                    --function initialization
                        --initialize function table
                            local FUNC = {}
                        --store arguments in locally scoped FUNC table for scope safety
                            FUNC.listOfPoints = listOfPoints
                            FUNC.color = color

                    for key,value in pairs(FUNC.listOfPoints) do 
                        if SCRIPT.compTools.playerhorizontalSquareDistanceBetween(FUNC.listOfPoints[key][1],FUNC.listOfPoints[key][3]) <= SCRIPT.renderDistance then
                            prepairBlockAt(FUNC.listOfPoints[key][1],FUNC.listOfPoints[key][2],FUNC.listOfPoints[key][3], FUNC.color, 1)
                        end
                    end
                end

                function renderBlocks()
                    --function initialization
                        --initialize function table
                            local FUNC = {}
                        
                    for key,value in pairs(SCRIPT.frameBuffer) do
                        FUNC.block = value
                            spawnBlockAt(FUNC.block.x,FUNC.block.y,FUNC.block.z, FUNC.block.color, FUNC.block.blockSize)
                    end
                end

        -- public functions
            function prepairNextFrame()
                --function initialization
                    --initialize function table
                        local FUNC = {}

                --declare local function variables
                    FUNC.color = 0
                    FUNC.pathColor = 0
                --clear Frame Buffer
                    SCRIPT.frameBuffer = {}

                -- render nearby nodes and paths
                    FUNC.drawnLines = {}
                    FUNC.selectedNodeName = SCRIPT.compTools.readAll("nodeManagementTools/selectedNode.txt")
                    -- for each node
                    for key,value in pairs(GLBL.nodes) do
                        FUNC.node = key

                        -- don't crash if GLBL.nodes was modified by another thread while this for loop is running.
                            if GLBL.nodes[FUNC.node] == nil then
                                break
                            end

                        -- temp catch for nil values
                            if GLBL.nodes == nil then
                                log("GLBL.nodes is NIL")
                            end
                            if FUNC.node == nil then
                                log("FUNC.node is nil")
                            end
                            if GLBL.nodes[FUNC.node] == nil then
                                log("GLBL.nodes[FUNC.node] is NIL")
                                log("FUNC.node: ", FUNC.node)
                            end
                            if GLBL.nodes[FUNC.node].x == nil then 
                                log("GLBL.nodes[FUNC.node].x is NIL")
                            end
                            if GLBL.nodes[FUNC.node].z == nil then
                                log("GLBL.nodes[FUNC.node].z is NIL")
                            end
                            if SCRIPT.renderDistance == nil then
                                log("SCRIPT.renderDistance is NIL")
                            end
                            if SCRIPT.compTools.playerhorizontalSquareDistanceBetween == nil then
                                log("SCRIPT.compTools.playerhorizontalSquareDistanceBetween is NIL")
                            end

                        if SCRIPT.compTools.playerhorizontalSquareDistanceBetween(GLBL.nodes[FUNC.node].x, GLBL.nodes[FUNC.node].z) <= SCRIPT.renderDistance then

                            -- determine block color
                                if GLBL.nodes[FUNC.node].pathType == "normal" then
                                    -- normal color
                                        FUNC.color = SCRIPT.colors.green
                                elseif GLBL.nodes[FUNC.node].pathType == "iceroad" then
                                    -- iceroad color
                                        FUNC.color = SCRIPT.colors.blue
                                elseif GLBL.nodes[FUNC.node].pathType == "roofless iceroad" then
                                    -- "roofless iceroad" color
                                        FUNC.color = SCRIPT.colors.lightBlue
                                elseif GLBL.nodes[FUNC.node].pathType == "rail" then
                                    -- iceroad color
                                        FUNC.color = SCRIPT.colors.grey
                                end

                            --render block for node
                                prepairBlockAt(GLBL.nodes[FUNC.node].x, GLBL.nodes[FUNC.node].y, GLBL.nodes[FUNC.node].z, FUNC.color, 3)
                            --render yellow block inside selected node
                                if FUNC.node == FUNC.selectedNodeName then
                                    prepairBlockAt(GLBL.nodes[FUNC.node].x, GLBL.nodes[FUNC.node].y, GLBL.nodes[FUNC.node].z, SCRIPT.colors.yellow, 2)
                                end
                            --render red block inside destination nodes
                                if SCRIPT.nodeIdToDestName[FUNC.node] ~= nil then
                                    prepairBlockAt(GLBL.nodes[FUNC.node].x, GLBL.nodes[FUNC.node].y, GLBL.nodes[FUNC.node].z, SCRIPT.colors.red, 1.5)
                                end
                        end
                        --draw line between FUNC.node and it's neighbors
                            for key,value in pairs(GLBL.nodes[FUNC.node]["connections"]) do
                                FUNC.neighbor = key

                                -- don't crash if GLBL.nodes was modified by another thread while this for loop is running.
                                    if GLBL.nodes[FUNC.node] == nil then
                                        break
                                    end

                                if FUNC.drawnLines[FUNC.neighbor .. FUNC.node] == nil then
                                    -- only consider draw lines that have at least one node within GLBL.minNodeDistance to the player.
                                    -- SCRIPT.nodeTools.pointBetweenPointsAtHorizontalDistance() is computationally intensive on super large worlds
                                    GLBL.minNodeDistance = 1000
                                    if SCRIPT.compTools.playerDistanceFrom(GLBL.nodes[FUNC.node].x,GLBL.nodes[FUNC.node].y,GLBL.nodes[FUNC.node].z) < GLBL.minNodeDistance or SCRIPT.compTools.playerDistanceFrom(GLBL.nodes[FUNC.neighbor].x,GLBL.nodes[FUNC.neighbor].y,GLBL.nodes[FUNC.neighbor].z) < GLBL.minNodeDistance then
                                        FUNC.lbX, FUNC.lbY, FUNC.lbZ = SCRIPT.nodeTools.closestPointOnLineToPlayer(GLBL.nodes[FUNC.node].x,GLBL.nodes[FUNC.node].y,GLBL.nodes[FUNC.node].z,      GLBL.nodes[FUNC.neighbor].x,GLBL.nodes[FUNC.neighbor].y,GLBL.nodes[FUNC.neighbor].z)
                                        if SCRIPT.compTools.playerhorizontalSquareDistanceBetween(FUNC.lbX, FUNC.lbZ) <= SCRIPT.renderDistance then
                                            FUNC.listOfPoints = SCRIPT.compTools.Bresenham3D(GLBL.nodes[FUNC.node].x,GLBL.nodes[FUNC.node].y,GLBL.nodes[FUNC.node].z,GLBL.nodes[FUNC.neighbor].x,GLBL.nodes[FUNC.neighbor].y,GLBL.nodes[FUNC.neighbor].z)
                                            -- check what color line should be
                                                if SCRIPT.compTools.givenScriptIsRunning("AM-TravelBot/validatePaths.lua") == true then
                                                    -- based on validation
                                                        -- if path validated
                                                        if GLBL.validatedPaths[FUNC.node..FUNC.neighbor] ~= nil or GLBL.validatedPaths[FUNC.neighbor..FUNC.node] ~= nil then
                                                            FUNC.pathColor = SCRIPT.colors.green
                                                        else
                                                            FUNC.pathColor = SCRIPT.colors.red
                                                        end
                                                else
                                                    -- based on path type
                                                        -- iceroad
                                                            if SCRIPT.nodeTools.getPathTypeFromNodeTypes(GLBL.nodes[FUNC.node].pathType, GLBL.nodes[FUNC.neighbor].pathType) == "iceroad" then
                                                                -- iceroad color
                                                                    FUNC.pathColor = SCRIPT.colors.blue
                                                        -- roofless iceroad
                                                            elseif SCRIPT.nodeTools.getPathTypeFromNodeTypes(GLBL.nodes[FUNC.node].pathType, GLBL.nodes[FUNC.neighbor].pathType) == "roofless iceroad" then
                                                                -- iceroad color
                                                                    FUNC.pathColor = SCRIPT.colors.lightBlue
                                                        -- rail
                                                            elseif SCRIPT.nodeTools.getPathTypeFromNodeTypes(GLBL.nodes[FUNC.node].pathType, GLBL.nodes[FUNC.neighbor].pathType) == "rail" then
                                                                --rail color
                                                                    FUNC.pathColor = SCRIPT.colors.grey
                                                        -- normal
                                                            else
                                                                -- normal color
                                                                    FUNC.pathColor = SCRIPT.colors.green
                                                            end
                                                end

                                            prepairPoints(FUNC.listOfPoints, FUNC.pathColor)
                                            FUNC.drawnLines[FUNC.node .. FUNC.neighbor] = true
                                            --spawn red block at closest point on all lines to player
                                                -- FUNC.rbX, FUNC.rbY, FUNC.rbZ = SCRIPT.nodeTools.closestPointOnLineToPlayer(GLBL.nodes[FUNC.node].x,GLBL.nodes[FUNC.node].y,GLBL.nodes[FUNC.node].z,      GLBL.nodes[FUNC.neighbor].x,GLBL.nodes[FUNC.neighbor].y,GLBL.nodes[FUNC.neighbor].z)
                                                -- prepairBlockAt(FUNC.rbX, FUNC.rbY, FUNC.rbZ, SCRIPT.colors.red, 0.5)
                                        end
                                    end
                                end
                            end
                    end
                --spawn red block at closest point on line to player
                    -- FUNC.ppX, FUNC.ppY, FUNC.ppZ, FUNC.ppDistance, FUNC.ppNodeA, FUNC.ppNodeB, FUNC.ppPathType = SCRIPT.nodeTools.pathCloseby()
                    -- if FUNC.ppX ~= false then
                    --     --assign color based on pathType
                    --         if FUNC.ppPathType == "normal" then
                    --             FUNC.ppColor = SCRIPT.colors.green
                    --         elseif FUNC.ppPathType == "rail" then
                    --             FUNC.ppColor = SCRIPT.colors.grey
                    --         elseif FUNC.ppPathType == "iceroad" then
                    --             FUNC.ppColor = SCRIPT.colors.blue
                    --         end
                    --     prepairBlockAt(FUNC.ppX, FUNC.ppY, FUNC.ppZ, SCRIPT.colors.red, 0.5)
                    -- end

                --spawn blocks at zone border
                    -- for key,value in pairs(GLBL.zoneData) do
                    --     FUNC.zone = key
                    --     for key,value in pairs(GLBL.zoneData[FUNC.zone].polyPixels) do
                    --         FUNC.polyPixel = value
                    --         prepairBlockAt(FUNC.polyPixel.x,100, FUNC.polyPixel.z, SCRIPT.colors.red, 1)
                    --     end
                    -- end
            end
-- Main Progam

    --ensure selectedNode.txt exists (going to read from it later)
        SCRIPT.nodeTools.ensureFileExists("nodeManagementTools/selectedNode.txt")

    --initialize MAIN table
    --Stores variables for just MAIN function
        local MAIN = {}

    --ensure "GLBL.toggleRenderState" is intialized
        if GLBL.toggleRenderState == nil then
            GLBL.toggleRenderState = "hidden"
        end

    -- generate zone pixels for rendering
        -- MAIN.polyZones = SCRIPT.nodeTools.getPolyZones()
        -- SCRIPT.polyPixels = SCRIPT.nodeTools.getPolyPixels(MAIN.polyZones["zone1"])

    -- GLBL.zoneData = SCRIPT.nodeTools.getZoneData()
    GLBL.nodes = SCRIPT.nodeTools.loadNodesfromJSON()

    if GLBL.validatedPaths == nil then
        GLBL.validatedPaths = SCRIPT.loadValidatedPathsFromJson()
    end

    -- initialize GUI table
        GLBL.GUI = GLBL.GUI or {}
        MAIN.drawn = 5

    -- set render state to "hidden" if no rendering engine is already running
        if SCRIPT.compTools.anotherInstanceOfThisScriptIsRunning() == false then
            GLBL.toggleRenderState = "hidden"
        end

    --determing state
        if GLBL.toggleRenderState == "hidden" then
            GLBL.rendering = true
            GLBL.toggleRenderXray = false

            GLBL.toggleRenderState = "visible"

            log("&7[&6ToggleRender&7]§f paths visible (started rendering engine)")

            --main render loop
                while GLBL.rendering do
                    prepairNextFrame()
                    -- clear all rendered
                        hud3D.clearAll()
                    renderBlocks()
                    -- log if player is inside any zones
                        -- MAIN.currentNation = false
                        -- for key,value in pairs(GLBL.zoneData) do
                        --     MAIN.zone = key
                        --     if SCRIPT.nodeTools.playerInZone(MAIN.zone, GLBL.zoneData) then
                        --         MAIN.currentNation = MAIN.zone
                        --     end
                        -- end
                        -- if MAIN.currentNation == false then
                        --     -- log("player not in any nation")
                        --     MAIN.currentNation = "Unknown"
                        -- end
                        -- -- render nation as text in top left of screen
                        --     -- erase old render if it was rendered
                        --         if GLBL.GUI.nation ~= nil then
                        --             GLBL.GUI.nation.disableDraw()
                        --         end
                        
                        --     GLBL.GUI.nation = hud2D.newText("Current location: " .. MAIN.currentNation, 5, MAIN.drawn)
                        --     GLBL.GUI.nation.enableDraw()

                    sleep(100)
                end
                -- clear all rendered
                    hud3D.clearAll()
                    -- GLBL.GUI.nation.disableDraw()

                log("&7[&6ToggleRender&7]§f rendering engine stopped")

        elseif GLBL.toggleRenderState == "visible" then
            GLBL.rendering = true
            GLBL.toggleRenderXray = true

            GLBL.toggleRenderState = "xray"

            log("&7[&6ToggleRender&7]§f paths xrayed")
        elseif GLBL.toggleRenderState == "xray" then
            GLBL.rendering = false
            GLBL.toggleRenderXray = false
            GLBL.toggleRenderState = "hidden"

            SCRIPT.compTools.stopOtherInstancesOfThisScript()

            log("&7[&6ToggleRender&7]§f paths hidden (rendering engine stopped)")

            -- clear all rendered
                hud3D.clearAll()
                -- GLBL.GUI.nation.disableDraw()
        end
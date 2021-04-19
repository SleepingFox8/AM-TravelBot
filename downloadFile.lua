-- botTools = require ("./AM-Tools/botTools")
-- compTools = require ("./AM-Tools/compTools")
json = require ("./json.lua/json")

-- -- Main program

--     --initialize MAIN table
--     --Stores variables for just MAIN function
--     local MAIN = {}

--     -- toggle this script off if it is already running
--         if compTools.anotherInstanceOfThisScriptIsRunning() then
--             compTools.stopOtherInstancesOfThisScript()
--             botTools.freezeAllMotorFunctions()
--             -- uncrouch
--                 sneak(1)
--                 waitTick()
--             log("&7[&6TravelBot&7]§f Traveling was canceled")
--             GLBL.travelTo_travelCanceled = true
--             -- silently end this script
--                 return 0
--         end


-- attempt 1
    -- print("retrieve the content of a URL")
    -- -- retrieve the content of a URL
    --     local http = require("socket.http")
    --     local body, code = http.request("https://raw.githubusercontent.com/ccmap/data/master/land_claims.civmap.json")
    --     local body, code, item3 = http.request{url = "https://raw.githubusercontent.com/ccmap/data/master/land_claims.civmap.json"}
        
    --     if not body then error(code) end

    -- print("Body: ")
    -- print(item3)

    -- print("code: ")
    -- print(code)

    -- print("save the content to a file")
    -- -- save the content to a file
    --     -- local f = assert(io.open('test.json', 'r')) -- open in "binary" mode
    --     -- f:write(body)
    --     -- f:close()

    --     local file = io.open("test.json", "w")
    --     file:write(item3)
    --     file:close()
    -- print("download completed")

-- attempt 2
    -- local http = require("socket.http")
    -- local ltn12 = require("ltn12")

    -- local file = ltn12.sink.file(io.open('test.json', 'w'))
    -- http.request {
    --     url = 'https://raw.githubusercontent.com/ccmap/data/master/land_claims.civmap.json',
    --     sink = file,
    -- }

-- attempt 3
    -- local curl = require "luacurl"
    -- local c = curl.new()

    -- function GET(url)
    --     c:setopt(curl.OPT_URL, url)
    --     local t = {} -- this will collect resulting chunks
    --     c:setopt(curl.OPT_WRITEFUNCTION, function (param, buf)
    --         table.insert(t, buf) -- store a chunk of data received
    --         return #buf
    --     end)
    --     c:setopt(curl.OPT_PROGRESSFUNCTION, function(param, dltotal, dlnow)
    --         print('%', url, dltotal, dlnow) -- do your fancy reporting here
    --     end)
    --     c:setopt(curl.OPT_NOPROGRESS, false) -- use this to activate progress
    --     assert(c:perform())
    --     return table.concat(t) -- return the whole data as a string
    -- end

    -- local s = GET 'http://www.lua.org/'
    -- print(s)

-- attempt 4
--gets a file from a url and puts it in a table
    -- local lib = require("./spider-ppa/CobwebPackageManager/fileLib")
    -- local lib = require("fileLib")

    --gets a file from a url and puts it in a table
    local function getFile(url, timeout)
        local settings={}
        if not timeout then
            settings.httpTimeout=10000
        else
            settings.httpTimeout=timeout
        end
        local http=httpRequest({url=url}, {url=url, requestMethod="GET", timeout=settings.httpTimeout})
        local file=http["input"]
        local err=http.getResponseCode()
        local line=file:readLine()
        local output={}
        while line~=nil do
            table.insert(output, line)
            line=file:readLine()
        end
        return output
    end

    local function getFileStringFromURL(url)
        local fileResults = getFile(url, 10000)
        local fileString = ""
        for key,value in pairs(fileResults) do 
            fileString = fileString..value.."\n"
        end
        return fileString
    end

    log("downloading file...")

    local fileString = getFileStringFromURL("https://raw.githubusercontent.com/ccmap/data/master/land_claims.civmap.json")

    -- write file
        local file = io.open("test.json", "wb")
        file:write(fileString)
        file:close()

    log("file saved")
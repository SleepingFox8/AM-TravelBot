--initialization
    --initialize GLBL table if needed
        if GLBL == nil then
            GLBL = {}
        end

-- main program
    if GLBL.selectedPathType == nil or GLBL.selectedPathType == "rail" then
        GLBL.selectedPathType = "normal"
        log("&7[&6NodeManagement&7]§f selectedPathType = \"&anormal&f\"")
    elseif GLBL.selectedPathType == "normal" then
        GLBL.selectedPathType = "iceroad"
        log("&7[&6NodeManagement&7]§f selectedPathType = \"&9iceroad&f\"")
    elseif GLBL.selectedPathType == "iceroad" then
        GLBL.selectedPathType = "roofless iceroad"
        log("&7[&6NodeManagement&7]§f selectedPathType = \"&broofless iceroad&f\"")
    elseif GLBL.selectedPathType == "roofless iceroad" then
        GLBL.selectedPathType = "rail"
        log("&7[&6NodeManagement&7]§f selectedPathType = \"&7rail&f\"")
    end
coreline = {} -- Namespace for coreline API
cl = coreline -- Shorthand alias for developers to use

function InitializeCoreline()
    if coreline.ready then return end
    
    coreline.version = "0.0.1pa" -- pa = pre-alpha; a = alpha; b = beta;
    coreline.ready = false
    coreline.config = require("cl_config.lua")
    coreline.players = {}
    coreline.functions = {}
    coreline.clientEvents = {}
    coreline.serverEvents = {}
    coreline.modules = {}

    LoadModules()

    -- First we need to check if coreline is truly ready, but skipping that for now
    coreline.ready = true
end

function ParseFileNames(output)
    local files = {}
    for line in output:gmatch("[^\r\n]+") do
        if line:match("%.lua$") then
            table.insert(files, line)
        end
    end

    return files
end

function LoadModules()
    local moduleFolder = "modules/"
    local files = GetModuleFiles(moduleFolder)

    for _, file in ipairs(files) do
        local modName = file:gsub("%.lua$", "")
        local module = require(("core.modules.%s"):format(modName))
        coreline.modules[modName] = module
        if type(module.init) == "function" then module.init() end
    end
end

function ReloadModules()
    print("^3[Core] Reloading modules...^0")

    local moduleFolder = "modules/"
    local files = GetModuleFiles(moduleFolder)

    for _, file in ipairs(files) do
        local modName = file:gsub("%.lua$", "")
        local existingModule = coreline.modules[modName]
        if existingModule and type(existingModule.unload) == "function" then
            local success, err = coreline.SafeExecute(modName, existingModule.unload)
            if not success then
                print(("^1[Core] Error unloading module %s: %s^0"):format(modName, tostring(err)))
            end
        end

        package.loaded[("core.modules.%s"):format(modName)] = nil
    end

    coreline.modules = {}

    for _, file in ipairs(files) do
        local modName = file:gsub("%.lua$", "")
        local success, result = coreline.SafeExecute(("Require %s"):format(modName), require, ("core.modules.%s"):format(modName))
        if success then
            coreline.modules[modName] = result
            print("^2[Core] Reloaded: ^0" .. modName)

            if type(result.init) == "function" then
                local initSuccess, initErr = coreline.SafeExecute(("Module Initialization %s"):format(modName), result.init)
                if not initSuccess then
                    print(("^1[Core] Error in init() of module %s: %s^0"):format(modName, tostring(initErr)))
                end
            end
        else
            print("^1[Core] Failed to reload " .. modName .. ": ^0" .. tostring(result))
        end
    end

    print("^3[Core] Module reload complete.^0")
end

function coreline.functions.RegisterEvent(name, handler, isServerEvent)
    if isServerEvent then
        coreline.serverEvents[name] = handler
        RegisterNetEvent(name)
    else
        coreline.clientEvents[name] = handler
    end

    AddEventHandler(name, function(...)
        coreline.SafeExecute(name, handler, ...)
    end)
end

function coreline.functions.SafeExecute(name, func, ...)
    local ok, err = pcall(func, ...)
    if not ok then
        print(("^1[ERROR]^0 Event '%s' failed: %s"):format(name, err))
    end
end

if not coreline.ready then
    InitializeCoreline()
end

-- MOVE THIS FUNCTION TO A HELPER FUNCTION LATER
function GetModuleFiles(moduleFolder)
    local isWindowsMachine = package.config:sub(1,1) == "\\"
    local currentPath = GetResourcePath(GetCurrentResourceName()) .. "/" .. moduleFolder
    local command = isWindowsMachine and ('dir /b "%s"'):format(currentPath) or ('ls "%s"'):format(currentPath)

    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()

    return ParseFileNames(result)
end
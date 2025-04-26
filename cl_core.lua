coreline = {} -- Should always use this when working on coreline directly
cl = coreline -- A shorthand for developers to use.

function InitializeCoreline()
    if coreline.ready then return end
    
    coreline.version = "0.0.1pa" -- pa = pre-alpha; a = alpha; b = beta;
    coreline.ready = false
    coreline.config = require("cl_config.lua")
    coreline.players = {}
    coreline.clientEvents = {}
    coreline.serverEvents = {}

    LoadModules()
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
    local isWindowsMachine = package.config:sub(1,1) == "\\"
    local currentPath = GetResourcePath(GetCurrentResourceName()) .. "/modules"
    local command = isWindowsMachine and ('dir /b "%s"'):format(currentPath) or ('ls "%s"'):format(currentPath)

    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()

    local files = ParseFileNames(result)

    for _, file in ipairs(files) do
        local modName = file:gsub("%.lua$", "")
        local module = require(("core.modules.%s"):format(modName))
        cl[modName] = module
        if type(module.init) == "function" then module.init() end
    end
end

local loadedModules = {}

function ReloadModules()
    print("^3[Core] Reloading modules...^0")

    -- Folder containing your modules
    local moduleFolder = "modules/"

    -- Clear previously loaded modules
    local files = GetModuleFiles(moduleFolder)
    for _, modulePath in ipairs(files) do
        package.loaded[modulePath] = nil
    end

    -- Re-require the modules
    for _, modulePath in ipairs(files) do
        local success, result = pcall(require, modulePath)
        if success then
            loadedModules[modulePath] = result
            print("^2[Core] Reloaded: ^0" .. modulePath)
        else
            print("^1[Core] Failed to reload " .. modulePath .. ": ^0" .. tostring(result))
        end
    end

    print("^3[Core] Module reload complete.^0")
end

function coreline.RegisterEvent(name, handler, isServerEvent)
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

function coreline.SafeExecute(name, func, ...)
    local ok, err = pcall(func, ...)
    if not ok then
        print(("^1[ERROR]^0 Event '%s' failed: %s"):format(name, err))
    end
end

if not coreline.ready then
    InitializeCoreline()
end
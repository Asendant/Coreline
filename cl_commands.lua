RegisterCommand("events", function()
    print("^3[RegisteredEvents]^0")
    for name in pairs(cl.events) do
        print("- " .. name)
    end
end)

RegisterCommand("reloadcore", function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, "dev.reloadcore") then
        ReloadModules()
    else
        TriggerClientEvent("chat:addMessage", source, {
            args = {"System", "You do not have permission to use this command."}
        })
    end
end, false)
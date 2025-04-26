RegisterCommand("events", function()
    print("^3[RegisteredEvents]^0")
    for name in pairs(cl.events) do
        print("- " .. name)
    end
end)
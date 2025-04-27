AddEventHandler('playerJoining', function(playerName)
    local playerSource = source  -- This should be valid now
    print("Player joining. Source ID: " .. tostring(playerSource))

    if not playerSource then
        print("Error: Invalid source.")  -- Debugging line
        return  -- Skip if invalid source
    end

    -- Initialize the deferrals system
    local deferrals = Deferrals.new()
    deferrals.defer()  -- Defer the connection to allow checks

    Citizen.Wait(0)  -- Wait for the server to process the deferral

    -- Get player identifiers
    local identifiers = GetPlayerIdentifiers(playerSource)

    print("Identifiers: " .. tostring(identifiers))

    if not identifiers or #identifiers == 0 then
        print("Error: No identifiers found for source ID: " .. tostring(playerSource))
        deferrals.done("Error: No identifiers found. Please try again.")
        return
    end

    local playerData = {}

    -- Loop through identifiers to find Steam, License, and Discord IDs
    for _, id in ipairs(identifiers) do
        if string.match(id, "steam:") then
            playerData.steamIdentifier = id
            break
        elseif string.match(id, "license:") then
            playerData.licenseIdentifier = id
        elseif string.match(id, "discord:") then
            playerData.discordIdentifier = id
        end
    end

    if playerData.steamIdentifier then
        print(playerName .. " is using Steam. Steam ID: " .. playerData.steamIdentifier)
        deferrals.done()  -- Allow the connection
    else
        print(playerName .. " is not using Steam.")
        deferrals.done("You must use Steam to join this server.")  -- Reject connection with message
    end
end)

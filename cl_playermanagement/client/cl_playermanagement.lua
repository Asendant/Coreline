AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    deferrals.defer()

    Citizen.Wait(0)

    local identifiers = GetPlayerIdentifiers(source)
    local steamIdentifier = nil

    for _, id in ipairs(identifiers) do
        if string.match(id, "steam:") then
            steamIdentifier = id
            break
        end
    end

    print (playerName .. ' is joining the server.')
end)
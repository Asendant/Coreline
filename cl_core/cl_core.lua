coreline = {} -- Namespace for coreline API
cl = coreline -- Shorthand alias for developers to use

function InitializeCoreline()
    coreline.players = {}
end

if not coreline.ready then
    InitializeCoreline()
end
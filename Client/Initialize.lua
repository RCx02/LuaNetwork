local network = {}
local remotes = game:GetService('ReplicatedStorage'):WaitForChild('Remotes')

function _call(parsed)
    local success,error = pcall(function()
        parsed.method(parsed.content)
    end)
    if error then warn('@CLIENT: ' .. error) end
end

for _,class in pairs(script.Parent:GetChildren()) do
    network[string.lower(class.Name)] = {}
    for _,module in pairs(class:GetChildren()) do
        network[string.lower(class.Name)][string.lower(module.Name)] = require(module)
        _call({method = network[string.lower(class.Name)][string.lower(module.Name)].__init})
        print('@CLIENT: Loaded ' .. class.Name .. '.' .. module.Name)
    end
end

remotes:WaitForChild('RemoteEvent').OnClientEvent:Connect(function(parsed)
    _call({method = network[string.lower(parsed.class)][string.lower(parsed.module)][parsed.method], content = parsed})
end)

remotes:WaitForChild('RemoteFunction').OnClientInvoke = function(parsed)
    return _call({method = network[string.lower(parsed.class)][string.lower(parsed.module)][parsed.method], content = parsed})
end

remotes:WaitForChild('Function').OnInvoke = function(parsed)
    return _call({method = network[string.lower(parsed.class)][string.lower(parsed.module)][parsed.method], content = parsed})
end

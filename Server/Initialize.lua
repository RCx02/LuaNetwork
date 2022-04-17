local network = {}
local remotes = game:GetService('ReplicatedStorage'):WaitForChild('Remotes')

local serverProhibited = {
	'DataService',
}

function _call(parsed)
	local success,error = pcall(function()
		return parsed.method(parsed.content)
	end)
	if error then warn('@SERVER: ' .. error) end
end

for _,class in pairs(script.Parent:GetChildren()) do
	network[string.lower(class.Name)] = {}
	for _,module in pairs(class:GetChildren()) do
		network[string.lower(class.Name)][string.lower(module.Name)] = require(module)
		_call({method = network[string.lower(class.Name)][string.lower(module.Name)].__init})
		
		print('@SERVER: Loaded ' .. class.Name .. '.' .. module.Name)
	end
end

remotes:WaitForChild('RemoteEvent').OnServerEvent:Connect(function(player, parsed)
	if table.find(serverProhibited, parsed.module) then
		warn(player.Name .. ' has tried to access a prohibited module')
	end
	_call({method = network[string.lower(parsed.class)][string.lower(parsed.module)][parsed.method], content = parsed})
end)

remotes:WaitForChild('RemoteFunction').OnServerInvoke = function(player, parsed)
	if table.find(serverProhibited, parsed.module) then
		warn(player.Name .. ' has tried to access a prohibited module')
	end
	return network[string.lower(parsed.class)][string.lower(parsed.module)][parsed.method](parsed)
end

remotes:WaitForChild('Function').OnInvoke = function(parsed)
	return network[string.lower(parsed.class)][string.lower(parsed.module)][parsed.method](parsed)
end

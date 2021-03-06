local websocket = {}

local json = require'json'
server = require'websocket'.server.uloop
tinycore = require("tinycore")

function websocket.init()
	server.listen
	{
	port = 8080,
	protocols = {
		echo = function(ws)
				local message = ws:receive()
				if message then
					local ok, jsonMsg = pcall(json.decode, message)
					if (ok and jsonMsg) then
						if (jsonMsg["config"] and tinycore.config) then
							tinycore.update_config_from_devices(tinycore.config, tinycore.devices)
							ws:send(json.encode({config = tinycore.config}))
						end
						if (jsonMsg["changed"]) then
							for k, v in pairs(jsonMsg["changed"]) do
								if (tinycore.devices[k]) then
									tinycore.runDevice("onWebChange", v, {tinycore.devices[k]})
								end
							end
							tinycore.executeActions()
						end
					end
				else
					ws:close()
					return
				end
		end
		}
	}
end

function websocket.onDeviceChange(params)
	websocket.webBroadcast(params)
end

function websocket.webBroadcast(params)
	for i, param in ipairs(params) do
		local msg = json.encode({changed = param});
		for client in pairs(server.clients["echo"]) do
			pcall(client.send, client, msg)
		end
	end
end

return websocket
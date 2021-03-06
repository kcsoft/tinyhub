local presence = {}

tinycore = require("tinycore")
require'uloop'

function presence.init(plugin)
	presence.plugin = plugin
	presence.timer = uloop.timer(presence.onTimer, 5000)
end

function presence.onTimer()
	local value = ""
	local result = tinycore.plugins.tinyubus.connection:call(presence.plugin.ubusNamespace, presence.plugin.ubusFunction, {})
	if (result and result.clients) then
		for cid, cname in pairs(presence.plugin.clients) do
			if result.clients[cid] then
				if value ~= "" then
					value = value .. ", "
				end
				value = value .. cname
			end
		end
	end

	tinycore.runDevice("onChangeProp", {name = "value", value = value}, {tinycore.devices[presence.plugin.device]})
	tinycore.executeActions()
	presence.timer:set(presence.plugin.interval)
end

return presence
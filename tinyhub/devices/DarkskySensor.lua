require'devices.GenericDevice'

DarkskySensor = {props = {}}

function DarkskySensor:new(o, opt)
	local self = GenericDevice:new(o, opt)
	self:extend(DarkskySensor)
	self.props.value = ""
	return self
end

function DarkskySensor:onWeatherData(eventParam)
	self:onChangeProp({name = "value", value = eventParam.value})
end
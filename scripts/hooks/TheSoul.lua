---@class Encounter : Encounter
---@overload fun(...) : Encounter
local Encounter, super = Utils.hookScript(Encounter)

function Encounter:createSoul(x, y, color)
	super.init(self)
	
	if Game:getFlag("self_discovery") == true then return ParrySoul(x, y, color) end
end
---@class Encounter : Encounter
local Encounter, super = Utils.hookScript(Encounter)

function Encounter:createSoul(x, y, color)
	if Game:getFlag("self_discovery") then
		if Game:getFlag("self_discovery") == 2 then
			return ParrySoul(x, y, color)
		else
			return Soul(x, y, color)
		end
	end
end

return Encounter
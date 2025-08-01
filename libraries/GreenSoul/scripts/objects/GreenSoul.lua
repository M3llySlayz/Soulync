local GreenSoul, super = Class(Soul)

function GreenSoul:init(x, y, angle)
    super:init(self, x, y)

    self.color = {0,192 / 255,0}
	
	-- internal stuff
	self.tween = nil
	
	self.shield = GreenSoulShield(-self.width * 1.5, -self.height * 1.5)
	self.circle = GreenSoulCircle(-self.width * 1.5, -self.height * 1.5)
	
	self:addChild(self.shield)
	self:addChild(self.circle)

	-- parameters
	self.rotationSides = {
		["left"] 	= 270,
		["right"] 	= 90,
		["down"] 	= 180,
		["up"] 		= {0, 360},
		
		["left+up"] = 315,
		["left+down"] = 225,
		["right+up"] = 45,
		["right+down"] = 135
	}
	
	self.rotationSpeed = Kristal.getLibConfig("greensoul", "rotationSpeed")
	self.rotationStyle = Kristal.getLibConfig("greensoul", "rotationStyle")
	self.isDiagonal = Kristal.getLibConfig("greensoul", "diagonal")
	
	self:setShieldRotation(Kristal.getLibConfig("greensoul", "side"))
	self.defaultSide = self.side
end

function GreenSoul:setShieldRotation(side)
	local shield = self.shield
	local val = self.rotationSides[side]
	
	if type(val) == 'table' then val = val[1] end
	
	shield.rotation = math.rad(val)
	shield.side = side
end

function GreenSoul:rotateShield(side)
	local val = self.rotationSides[side]
	local shield = self.shield
	
	if type(val) == 'table' then
		if math.deg(shield.rotation) > 180 then
			val = val[2]
		else
			val = val[1]
		end
	end
	
	shield.side = side
	self.tween = Tween.new(1, shield, {rotation = math.rad(val)}, self.rotationStyle)
end

local function inputCheck(self, keyArg)
	if not self.isDiagonal then
		return Input.down(keyArg)
	end
	
	for key in keyArg:gmatch("([^%+]+)") do
		if not Input.down(key) then
			return false
		end
	end
	
	return true
end

function GreenSoul:doMovement()
	if self.tween then 
		if self.tween:update(self.rotationSpeed) then 
			self.tween = nil
		else
			return
		end
	end
	
	for key in pairs(self.rotationSides) do
		if inputCheck(self, key) then
			self:rotateShield(key)
			isHolding = true
		end
	end
end

return GreenSoul
local GreenSoulShield, super = Class(Object)

function GreenSoulShield:init(x, y)
    super:init(self, x, y)
	
    self.layer = BATTLE_LAYERS["above_bullets"]
    self:setSprite("player/shield")

	local spr = self.sprite
	self.rotation_origin_x = 0.5
	self.rotation_origin_y = 0.5
	
    self.physics = nil
	
	self.rotationHitboxes = {
		["up"] 		= {0, 0, self.width, 1},
		["right"]	= {self.width - 1, 0, 1, self.height},
		["down"]	= {0, self.height - 1, self.width, 1},
		["left"]	= {0, 0, 1, self.height},
		
		["left+up"]		= {0, 0, self.width * .5, self.height * .5},
		["right+up"]	= {self.width * .5, 0, self.width * .5, self.height * .5},
		["left+down"]	= {0, self.height * .5, self.width * .5, self.height * .5},
		["right+down"]	= {self.width * .5, self.height * .5, self.width * .5, self.height * .5},
	}
	
	self.blinkTimer = 0
	self:changeSide("up")
end

function GreenSoulShield:draw()
	super:draw(self)
end

function GreenSoulShield:resolveBulletCollision(bullet)
	Assets.playSound("greensoul/shield")
	self.blinkTimer = Kristal.getLibConfig("greensoul", "blinkTimer")
	self:setSprite("player/shieldHit")
			
	bullet:remove()
end

function GreenSoulShield:update()
    local collided_bullets = {}
    Object.startCache()
    for _,bullet in ipairs(Game.stage:getObjects(Bullet)) do
        if bullet:collidesWith(self.collider) then
            -- Store collided bullets to a table before calling onCollide
            -- to avoid issues with cacheing inside onCollide
            table.insert(collided_bullets, bullet)
        end
    end
    Object.endCache()
	
    for _,bullet in ipairs(collided_bullets) do
        self:resolveBulletCollision(bullet)
    end
	
	if self.blinkTimer > 0 then
		self.blinkTimer = self.blinkTimer - 1
		
		if self.blinkTimer <= 0 then
			self:setSprite("player/shield")
		end
	end
end

function GreenSoulShield:changeSide(side)
	self.collider = Hitbox(self, unpack(self.rotationHitboxes[side or "up"]))
end

function GreenSoulShield:setSprite(sprite)
    if self.sprite then
        self.sprite:remove()
    end
	
    self.sprite = Sprite(sprite, 0, 0)
    self:addChild(self.sprite)
    self:setSize(self.sprite:getSize())
end

function GreenSoulShield:draw()
    super:draw(self)

    if DEBUG_RENDER and self.collider then
        self.collider:drawFor(self, 1, 0, 0)
    end
end

return GreenSoulShield
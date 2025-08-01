local Pushable, super = Class(PushBlock, "pushable")

function Pushable:init(data)
	super.init(self, data.x, data.y, data.width, data.height, data.properties)

    properties = data.properties or {}

    self.default_sprite = properties["sprite"] or sprite or "world/events/push_block"
    self.solved_sprite = properties["solvedsprite"] or properties["sprite"] or solved_sprite or sprite or self.default_sprite

    self:setSprite(self.default_sprite)
    self.solid = true
	self.collider = Hitbox(self, 0, 0, data.width, data.height)
	self.push_collider = Hitbox(self, -1, -1, data.width + 2, data.height + 2)
	
	self.push_dist = properties["pushdist"] or 40
    self.push_time = properties["pushtime"] or 0.2

    self.push_sound = properties["pushsound"] or "noise"

    self.press_buttons = properties["pressbuttons"]

    self.lock_in_place = false
    self.input_lock = false

    -- State variables
    self.start_x = self.x
    self.start_y = self.y

    -- IDLE, PUSH, RESET
    self.state = "IDLE"

    self.solved = false
end

function Pushable:onInteract(chara, facing)
    return true
end

function Pushable:checkCollision(facing)
	local collided = false

    local dx, dy = Utils.getFacingVector(facing)
    local target_x, target_y = self.x + dx * 4, self.y + dy * 4

    local x1, y1 = math.min(self.x, target_x), math.min(self.y, target_y)
    local x2, y2 = math.max(self.x + self.width, target_x + self.width), math.max(self.y + self.height, target_y + self.height)

    local bound_check = Hitbox(self.world, x1 + 1, y1 + 1, x2 - x1 - 2, y2 - y1 - 2)

    Object.startCache()
    for _,collider in ipairs(Game.world.map.block_collision) do
        if collider:collidesWith(bound_check) then
            collided = true
            break
        end
    end
    if not collided then
        self.collidable = false
        collided = self.world:checkCollision(bound_check)
        self.collidable = true
    end
    Object.endCache()

    return collided
end

function Pushable:update()
	super:update(self)

	-- Pushing
	if self.push_collider:collidesWith(Game.world.player) then
		local cx = self.x + (self.width/2)
		local cy = self.y + (self.height/2)
		local pcx = Game.world.player.x
		local pcy = Game.world.player.y - (Game.world.player.height/2)
		
		local angle = Utils.angle(Game.world.player.x, Game.world.player.y, cx, cy)
		local facing = Utils.facingFromAngle(angle)
		
		if not self:checkCollision(facing) then
			if facing == "up" then
				self.y = self.y - 4
			elseif facing == "down" then
				self.y = self.y + 4
			elseif facing == "left" then
				self.x = self.x - 4
			elseif facing == "right" then
				self.x= self.x + 4
			end
		end
	end
end

return Pushable
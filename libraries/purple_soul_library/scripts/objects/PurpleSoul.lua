local PurpleSoul, super = Class(Soul)

function PurpleSoul:init(x, y)
    super:init(self, x, y)

    self.color = {0.83529411764,0.20784313725,0.85098039215}
	
	-- Variables that can be changed
    self.string_count = 1           -- How many strings are there? [real] (any number)
    self.direction = "horizontal"   -- How are the strings laid out? [string] ("horizontal"; "vertical") 
    self.loop = false               -- Will going below or above the strings put you to the other end? [boolean] (true; false)
	
	self.current_string = 2         -- The current string of the soul [real] (any number)
    self.goal_y = self.y            -- The x or y value the soul is moving towards [real] (any number)
end

function PurpleSoul:onStart()

    local arena = Game.battle.arena
end

function PurpleSoul:update()
    super:update(self)
end

function PurpleSoul:doMovement()
    local speed = self.speed

    -- Do speed calculations here if required.

    local move_x, move_y = 0, 0

    if self.direction == "horizontal" then
        if Input.down("cancel") then speed = speed / 2 end -- Focus mode.
        
        if Input.down("left")  then move_x = move_x - 1 end
        if Input.down("right") then move_x = move_x + 1 end

        if Input.pressed("up")  then self.current_string = self.current_string - 1 end
        if Input.pressed("down")  then self.current_string = self.current_string + 1 end

        self:stringStuff()

        if self.y < self.goal_y then
            if self.goal_y - self.y >= 9 then move_y = 9
            else move_y = self.goal_y - self.y end
        end
        if self.y > self.goal_y then
            if self.y - self.goal_y >= 9 then move_y = -9
            else move_y = -(self.y - self.goal_y) end
        end

        self:move(move_x * speed, move_y, DTMULT)

    elseif self.direction == "vertical" then
        if Input.down("cancel") then speed = speed / 2 end -- Focus mode.
        
        if Input.down("up")  then move_y = move_x - 1 end
        if Input.down("down") then move_y = move_x + 1 end

        if Input.pressed("left")  then self.current_string = self.current_string - 1 end
        if Input.pressed("right")  then self.current_string = self.current_string + 1 end

        self:stringStuff()

        if self.x < self.goal_y then 
            if self.goal_y - self.y >= 9 then move_x = 9
            else move_x = self.goal_y - self.y end
        end
        if self.x > self.goal_y then 
            if self.x - self.goal_y >= 9 then move_x = -9
            else move_x = -(self.x - self.goal_y) end
        end

        self:move(move_x, move_y * speed, DTMULT)
    end

    self.moving_x = move_x
    self.moving_y = move_y
end

function PurpleSoul:stringStuff()
    if self.loop == true then
        if (self.current_string < 1) then self.current_string = self.string_count end
        if (self.current_string > self.string_count) then self.current_string = 1 end
    else
        if (self.current_string < 1) then self.current_string = 1 end
        if (self.current_string > self.string_count - 1) then self.current_string = self.string_count end
    end
end

function PurpleSoul:draw()
    local r,g,b,a = self:getDrawColor()
    local heart_texture = Assets.getTexture(self.sprite.texture_path)
    local heart_w, heart_h = heart_texture:getDimensions()

    super:draw(self)
    self.color = {r,g,b}
end

return PurpleSoul
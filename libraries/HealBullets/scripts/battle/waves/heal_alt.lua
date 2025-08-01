local HealAlt, super = Class(Wave)

function HealAlt:onStart()
        -- Every 0.33 seconds...
        self.timer:every(1/3, function()
            -- Our X position is offscreen, to the right
            local x = SCREEN_WIDTH + 20
            -- Get a random Y position between the top and the bottom of the arena
            local y = Utils.random(Game.battle.arena.top, Game.battle.arena.bottom)
            -- Spawn smallbullet going left with speed 8 (see scripts/battle/bullets/smallbullet.lua)
            local bullet = self:spawnBullet("smallbullet", x, y, math.rad(180), 7)
            -- Dont remove the bullet offscreen, because we spawn it offscreen
            bullet.remove_offscreen = false
    
        end)
    
        self.timer:every(1.5, function()
    
        local x2 = SCREEN_WIDTH + 50
        local y2 = Utils.random(Game.battle.arena.top + 10, Game.battle.arena.bottom + 15)
    
        local bullet2 = self:spawnBullet("heal", x2, y2, math.rad(180), 8)
    
        bullet2.remove_offscreen = false
    
        end)

end

function HealAlt:update()
    -- Code here gets called every frame

    super:update(self)
end

return HealAlt
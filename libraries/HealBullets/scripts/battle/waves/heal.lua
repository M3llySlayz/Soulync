local Heal, super = Class(Wave)

function Heal:onStart()
        -- Every 0.33 seconds...
        self.timer:every(1/3, function()
    
        local x2 = SCREEN_WIDTH + 50
        local y2 = Utils.random(Game.battle.arena.top + 10, Game.battle.arena.bottom + 15)
    
        local bullet2 = self:spawnBullet("heal", x2, y2, math.rad(180), 8)
    
        bullet2.remove_offscreen = false
    
        end)

end

function Heal:update()
    -- Code here gets called every frame

    super:update(self)
end

return Heal
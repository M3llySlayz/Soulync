---@class Bullet : Object
---@overload fun(...) : Bullet
---@field attacker EnemyBattler
---@field wave Wave
local Bullet, super = Utils.hookScript(Bullet)

function Bullet:onCollide(soul)
    super.onCollide(self, soul)
	
	Game.battle.attack_left = self.attacker.left
end

return Bullet
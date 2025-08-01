local HealBullet, super = Class(Bullet)

function HealBullet:init(x, y, type, texture)
    super:init(self, x, y, texture)
    self.tp = 0
    self.type = type
    self.color = self:getTypeColor()
    self.override = false
    self.damage = 0
    self.heal = 5
    self.destroy_on_hit = true

end

function HealBullet:getHeal()
    return self.heal or 1
end

function HealBullet:onCollide(soul)
        self:onHeal(soul)

    if self.destroy_on_hit then
        self:remove()
    end
end

function HealBullet:onHeal(soul)

    local amountHealed = self:getHeal()

    if amountHealed > 0 then
        
		if Game:getConfig("targetSystem") then
			local party = Game.battle:getPartyFromTarget(self:getTarget())
            for _, target in pairs (party) do
			target:heal(amountHealed)
            end
		else
			local target = Utils.pick(Game.battle.party)
			target:heal(amountHealed)
		end
    end
    return {}
end

function HealBullet:getTypeColor()
    if self.type == "green" then
        return {0, 255, 0} ----------- green
    else
        return { 255, 255, 255 } ----- white
    end
end

return HealBullet
local PartyBattler, super = Class(PartyBattler)

local function getConfig(name)
    return Kristal.getLibConfig("rolling-health", name)
end

function PartyBattler:init(...)
    super.init(self, ...)

    self.health_rolling_to = self.chara:getHealth()
    self.health_rolling_last = self.health_rolling_to
    self.health_rolling_timer = 0
end

function PartyBattler:removeHealth(amount)
    local health_roll_previous = self.health_rolling_to
    if (self.chara:getHealth() <= 0) then
        amount = Utils.round(amount / 4)
        self.health_rolling_to = self.health_rolling_to - amount
    else
        self.health_rolling_to = self.health_rolling_to - amount
    end
    self.health_rolling_to = math.max(self.health_rolling_to, 0)
    -- if self.health_rolling_to > self.chara:getHealth() and health_roll_previous < self.chara:getHealth() then
    --     self.health_rolling_timer = -getConfig("roll_delay")
    -- end
end

function PartyBattler:removeHealthBroken(amount)
    self:removeHealth(amount)
end

function PartyBattler:isHealthRolling()
    return Utils.round(self.health_rolling_to) ~= Utils.round(self.chara:getHealth()) and
           not self.is_down and
           not Utils.containsValue({"VICTORY", "TRANSITIONOUT"}, Game.battle.state) and
           not (getConfig("halt_during_party_turn") and not Utils.containsValue({"DEFENDING", "DEFENDINGBEGIN", "DEFENDINGEND"}, Game.battle.state))
end

function PartyBattler:canTarget()
    -- Check if all party members received mortal damage
    local all_mortal_damage = true
    for _, battler in ipairs(Game.battle.party) do
        if battler.health_rolling_to > 0 then
            all_mortal_damage = false
            break
        end
    end
    return not self.is_down and
           not (self.health_rolling_to <= 0 and not all_mortal_damage)
end

function PartyBattler:getRollSpeed()
    local speed_up = getConfig("speed_up")
    local current_health = self.chara:getHealth()
    local max_health = self.chara:getStat("health")
    local roll_speed = getConfig("roll_speed") *
                       math.pow(1 - speed_up, math.abs(self.health_rolling_to - current_health) / max_health)
    return roll_speed
end

function PartyBattler:update()
    super.update(self)

    self.health_rolling_timer = self.health_rolling_timer + DT
    local roll_speed = self:getRollSpeed()
    if self.health_rolling_timer > roll_speed then
        self.health_rolling_timer = self.health_rolling_timer - roll_speed
        local current_health = self.chara:getHealth()
        self.health_rolling_last = self.chara:getHealth()
        if self:isHealthRolling() then
            self.chara:setHealth(current_health + Utils.sign(self.health_rolling_to - current_health))
            if self.chara:getHealth() <= 0 then
                local party_index = Game.battle:getPartyIndex(self.chara.id)
                local do_remove_table = Game.battle.current_selecting == party_index
                Game.battle:pushForcedAction(self, "SKIP")
                if do_remove_table then
                    Utils.removeFromTable(Game.battle.selected_character_stack, party_index)
                    table.remove(Game.battle.selected_action_stack, party_index)
                end
                self.chara:setHealth(Utils.round(((-self.chara:getStat("health")) / 2)))
                self.health_rolling_to = self.chara:getHealth()
                self:statusMessage("msg", "down", color, true)
                Assets.playSound("hurt")
                Game.battle:shakeCamera(4)
            end
            self:checkHealth()
        end
    end
end

function PartyBattler:heal(amount, sparkle_color, show_up)
    Assets.stopAndPlaySound("power")

    amount = math.floor(amount)

    local health_roll_previous = self.health_rolling_to
    self.health_rolling_to = self.health_rolling_to + amount

    local was_down = self.is_down
    self:flash()
    
    if self.health_rolling_to >= self.chara:getStat("health") then
        self.health_rolling_to = self.chara:getStat("health")
        self:statusMessage("msg", "max")
    else
        if show_up then
            if was_down ~= self.is_down then
                self:statusMessage("msg", "up")
            end
        else
            self:statusMessage("heal", amount, {0, 1, 0})
        end
    end

    if getConfig("instant_roll_up") then
        self.chara:setHealth(self.health_rolling_to)
    elseif self.is_down then
        if self.health_rolling_to <= 0 or
           (self.health_rolling_to > 0 and getConfig("instant_roll_revive")) then
            self.chara:setHealth(self.health_rolling_to)
        else
            self.chara:setHealth(1)
        end
    end

    -- Kristal.Console:log(tostring(self.health_rolling_to > self.chara:getHealth() and health_roll_previous < self.chara:getHealth()))
    -- if self.health_rolling_to > self.chara:getHealth() and health_roll_previous < self.chara:getHealth() then
    --     self.health_rolling_timer = -getConfig("roll_delay")
    -- end
    
    self:checkHealth()
    self:sparkle(unpack(sparkle_color or {}))
end

return PartyBattler
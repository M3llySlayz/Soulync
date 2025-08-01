local Lib = {}

function Lib:init()
    print("Loaded ExpandedAttackLib: Redux " .. self.info.version .. "!")

    ----------------------------------------------------------------------------------
    -----  ITEM HOOKS
    ----------------------------------------------------------------------------------

    -----  NEW PROPERTIES AND CALLBACKS

    Utils.hook(Item, "init", function(orig, self)
        orig(self)

        self.bolt_count = nil
        self.bolt_speed = nil
        self.bolt_offset = 0
        self.bolt_acceleration = 0
        self.multibolt_variance = 80
    end)

    Utils.hook(Item, "getBoltCount", function(orig, self)
        return self.bolt_count
    end)

    Utils.hook(Item, "getBoltSpeed", function(orig, self)
        return self.bolt_speed
    end)

    Utils.hook(Item, "getBoltOffset", function(orig, self)
        return self.bolt_offset
    end)

    Utils.hook(Item, "getBoltAcceleration", function(orig, self)
        return self.bolt_acceleration
    end)
    
    Utils.hook(Item, "getMultiboltVariance", function(orig, self)
        return self.multibolt_variance
    end)

    ----- CALLBACKS

    Utils.hook(Item, "onHit", function(orig, self, battler, score, bolts, close)
        local attackbox
        for _,box in ipairs(Game.battle.battle_ui.attack_boxes) do
            if box.battler == battler then
                attackbox = box
                break
            end
        end

        local bolt = bolts[1]
    
        attackbox.score = attackbox.score + self:evaluateHit(battler, close)
        bolt:resetPhysics()
        self:onBoltBurst(battler, score, bolts, close)
        table.remove(bolts, 1)

        return self:checkAttackEnd(battler, attackbox.score, bolts, close)
    end)

    Utils.hook(Item, "onAttack", function(orig, self, action, battler, enemy, score, bolts, close)
        local src = Assets.stopAndPlaySound(battler.chara:getAttackSound() or "laz_c" or "squeak")
        src:setPitch(battler.chara:getAttackPitch() or 1)

        Game.battle.actions_done_timer = 1.2

        local crit = (self.crit == nil and action.points >= 150 or self.crit == true) and action.action ~= "AUTOATTACK"
        if crit then
            Assets.stopAndPlaySound("criticalswing")

            for i = 1, 3 do
                local sx, sy = battler:getRelativePos(battler.width, 0)
                local sparkle = Sprite("effects/criticalswing/sparkle", sx + Utils.random(50), sy + 30 + Utils.random(30))
                sparkle:play(4/30, true)
                sparkle:setScale(2)
                sparkle.layer = BATTLE_LAYERS["above_battlers"]
                sparkle.physics.speed_x = Utils.random(2, 6)
                sparkle.physics.friction = -0.25
                sparkle:fadeOutSpeedAndRemove()
                Game.battle:addChild(sparkle)
            end
        end
        
        self.crit = nil

        battler:setAnimation("battle/attack", function()
            action.icon = nil

            if action.target and action.target.done_state then
                enemy = Game.battle:retargetEnemy()
                action.target = enemy
                if not enemy then
                    Game.battle.cancel_attack = true
                    Game.battle:finishAction(action)
                    return
                end
            end

            local damage = Utils.round(enemy:getAttackDamage(action.damage or 0, battler, action.points or 0))
            if damage < 0 then
                damage = 0
            end

            if damage > 0 then
                Game:giveTension(Utils.round(enemy:getAttackTension(Game.battle:getActionBy(battler).action == "AUTOATTACK" and action.points or score / battler:getBoltCount() or 100)))

                local dmg_sprite = Sprite(battler.chara:getAttackSprite() or "effects/attack/cut")
                dmg_sprite:setOrigin(0.5, 0.5)
                if crit then
                    dmg_sprite:setScale(2.5, 2.5)
                else
                    dmg_sprite:setScale(2, 2)
                end
                local relative_pos_x, relative_pos_y = enemy:getRelativePos(enemy.width/2, enemy.height/2)
                dmg_sprite:setPosition(relative_pos_x + enemy.dmg_sprite_offset[1], relative_pos_y + enemy.dmg_sprite_offset[2])
                dmg_sprite.layer = enemy.layer + 0.01
                dmg_sprite.battler_id = action.character_id or nil
                table.insert(enemy.dmg_sprites, dmg_sprite)
                dmg_sprite:play(1/15, false, function(s) s:remove(); Utils.removeFromTable(enemy.dmg_sprites, dmg_sprite) end) -- Remove itself and Remove the dmg_sprite from the enemy's dmg_sprite table when its removed
                enemy.parent:addChild(dmg_sprite)

                local sound = enemy:getDamageSound() or "damage"
                if sound and type(sound) == "string" then
                    Assets.stopAndPlaySound(sound)
                end
                enemy:hurt(damage, battler)

                battler.chara:onAttackHit(enemy, damage)
            else
                enemy:hurt(0, battler, nil, nil, nil, action.points ~= 0)
            end

            Game.battle:finishAction(action)

            Utils.removeFromTable(Game.battle.normal_attackers, battler)
            Utils.removeFromTable(Game.battle.auto_attackers, battler)

            if not Game.battle:retargetEnemy() then
                Game.battle.cancel_attack = true
            elseif #Game.battle.normal_attackers == 0 and #Game.battle.auto_attackers > 0 then
                local next_attacker = Game.battle.auto_attackers[1]

                local next_action = Game.battle:getActionBy(next_attacker)
                if next_action then
                    Game.battle:beginAction(next_action)
                    Game.battle:processAction(next_action)
                end
            end
        end)
    end)

    Utils.hook(Item, "onWeaponMiss", function(orig, self, battler, score, bolts, close)
        local attackbox
        for _,box in ipairs(Game.battle.battle_ui.attack_boxes) do
            if box.battler == battler then
                attackbox = box
                break
            end
        end
    
        local bolt = bolts[1]
        bolt:resetPhysics()
        bolt:fadeOutSpeedAndRemove(0.45)
        table.remove(bolts, 1)

        return self:checkAttackEnd(battler, attackbox.score, bolts, close)
    end)

    Utils.hook(Item, "checkAttackEnd", function(orig, self, battler, score, bolts, close)
        local attackbox
        for _,box in ipairs(Game.battle.battle_ui.attack_boxes) do
            if box.battler == battler then
                attackbox = box
                break
            end
        end

        if #bolts == 0 then
            attackbox.attacked = true
            return self:evaluateScore(battler, score, bolts, close)
        end
    end)

    Utils.hook(Item, "onBoltBurst", function(orig, self, battler, score, bolts, close)
        local bolt = bolts[1]

        bolt:burst()
        bolt.layer = 1
        bolt:setPosition(bolt:getRelativePos(0, 0, Game.battle.battle_ui))
        bolt:setParent(Game.battle.battle_ui)

        if battler:getBoltCount() > 1 then
            local p = math.abs(close)
            if p <= 0.25 then
                Assets.stopAndPlaySound("victor")
                bolt:setColor(1, 1, 0)
                bolt.burst_speed = 0.2
            elseif p > 2.6 then
                bolt:setColor(battler.chara:getDamageColor())
            else
                Assets.stopAndPlaySound("hit")
            end
        else
            local p = math.abs(close)

            if p <= 0.25 then
                bolt:setColor(1, 1, 0)
                bolt.burst_speed = 0.2
            elseif p > 2.6 then
                bolt:setColor(battler.chara:getDamageColor())
            end
        end
    end)

    ----- EVALUATEHIT

    Utils.hook(Item, "evaluateHit", function(orig, self, battler, close)
        local p = math.abs(close)

        if p <= 0.25 then
            return 150
        elseif p <= 1.3 then
            return 120
        elseif p <= 2.6 then
            return 110
        else
            return 100 - (p * 2)
        end
    end)

    ----- EVALUATESCORE

    Utils.hook(Item, "evaluateScore", function(orig, self, battler, score, bolts, close)
        if battler:getBoltCount() > 1 then
            self.crit = false
            local perfect_score = 150 * battler:getBoltCount()
            local increased = battler:getBoltCount() >= 4
    
            if perfect_score - score <= 0 then
                self.crit = true
                Assets.stopAndPlaySound("saber3")
                return increased and 425 or 195
            elseif perfect_score - score <= 30 then
                self.crit = true
                Assets.stopAndPlaySound("saber3")
                return increased and 225 or 175
            elseif perfect_score - score <= 60 then
                return increased and 170 or 160
            elseif perfect_score - score <= 90 then
                return increased and 155 or 150
            else
                return Utils.round(score / battler:getBoltCount())
            end
        else
            return score
        end
    end)

    ----------------------------------------------------------------------------------
    -----  PARTYBATTLER HOOKS
    ----------------------------------------------------------------------------------

    -----  NEW PROPERTIES AND CALLBACKS

    Utils.hook(PartyBattler, "createPartyBattlers", function(orig, self)
        orig(self)

        self.bolt_count = nil
        self.bolt_speed = nil
        self.bolt_offset = nil
        self.bolt_acceleration = nil
    end)

    Utils.hook(PartyBattler, "getBoltCount", function(orig, self)
        local equip = self.chara:getWeapon()
        if equip and equip:getBoltCount() then
            self.bolt_count = equip:getBoltCount()
        else
            self.bolt_count = 1
        end

        return self.bolt_count
    end)

    -- 8 is the default speed
    Utils.hook(PartyBattler, "getBoltSpeed", function(orig, self)
        local equip = self.chara:getWeapon()
        if equip and equip:getBoltSpeed() then
            self.bolt_speed = equip:getBoltSpeed()
        else
            self.bolt_speed = AttackBox.BOLTSPEED
        end

        return self.bolt_speed
    end)

    Utils.hook(PartyBattler, "getBoltOffset", function(orig, self)
        local equip = self.chara:getWeapon()
        if equip and equip:getBoltOffset() then
            self.bolt_offset = equip:getBoltOffset()
        else
            self.bolt_offset = 0
        end

        return self.bolt_offset
    end)
    
    Utils.hook(PartyBattler, "getBoltAcceleration", function(orig, self)
        local equip = self.chara:getWeapon()
        if equip and equip:getBoltAcceleration() then
            self.bolt_acceleration = equip:getBoltAcceleration()
        else
            self.bolt_acceleration = 0
        end

        return self.bolt_acceleration
    end)

    ----------------------------------------------------------------------------------
    -----  ATTACKBOX HOOKS  
    ----------------------------------------------------------------------------------

    -----  INIT

    Utils.hook(AttackBox, "init", function(orig, self, battler, offset, index, x, y)
        Object.init(self, x, y)
    
        self.battler = battler
        self.weapon = battler.chara:getWeapon() or Registry.createItem("everybodyweapon")
        self.offset = offset + self.battler:getBoltOffset()
        self.index = index
    
        self.head_sprite = Sprite(battler.chara:getHeadIcons().."/head", 21, 19)
        self.head_sprite:setOrigin(0.5, 0.5)
        self:addChild(self.head_sprite)
    
        self.press_sprite = Sprite("ui/battle/press", 42, 0)
        self:addChild(self.press_sprite)
    
        self.bolt_target = 80 + 2

        self.bolt_start_x = self.bolt_target + (self.offset * self.battler:getBoltSpeed())
    
        self.bolts = {}
        self.score = 0

        for i = 1, self.battler:getBoltCount() do
            local bolt

            if i == 1 then
                bolt = AttackBar(self.bolt_start_x, 0, 6, 38)
            else
                local next_bolt_x
                local variance = self.weapon:getMultiboltVariance()
                if type(variance) == "table" then
                    local index = variance[i - 1] and (i - 1) or #variance
                    if type(variance[index]) == "number" then
                        next_bolt_x = variance[index]
                    elseif type(variance[index]) == "table" then
                        next_bolt_x = Utils.pick(variance[index])
                    else
                        error("self.multibolt_variance must either be an integer, a table populated with integers, or a table of tables populated with integers.")
                    end
                elseif type(variance) == "number" then
                    next_bolt_x = variance
                else
                    error("self.multibolt_variance must be either a table or a number value.")
                end
                
                bolt = AttackBar(self.bolts[i - 1].x + next_bolt_x, 0, 6, 38)
                
                -- local index = i - 1

                -- if variance[index] then
                    -- if type(variance) == "table" then
                        -- if type(variance[index]) == "number" then
                            -- next_bolt_x = variance[index]
                        -- elseif type(variance[index]) == "table" then
                            -- next_bolt_x = Utils.pick(variance[index])
                        -- else
                            -- error("self.multibolt_variance must either be an integer, a table populated with integers, or a table of tables populated with integers.")
                        -- end
                    -- elseif type(variance) == "number" then
                        -- next_bolt_x = variance
                    -- else
                        -- error("self.multibolt_variance must be either a table or a number value.")
                    -- end
                -- else
                    -- next_bolt_x = Utils.pick(variance[#variance]) + (Utils.pick(variance[#variance]) * (index - #variance))
                -- end

                -- bolt = AttackBar(self.bolts[1].x + next_bolt_x, 0, 6, 38)
            end

            bolt.layer = 1
            bolt.target_magnet = 0
            if #Game.battle.party > 3 then
                bolt.height = math.floor(112 / #Game.battle.party)
            end
            table.insert(self.bolts, bolt)
            self:addChild(bolt)
        end
    
        self.fade_rect = Rectangle(0, 0, SCREEN_WIDTH, 300)
        self.fade_rect:setColor(0, 0, 0, 0)
        self.fade_rect.layer = 2
        self:addChild(self.fade_rect)
    
        self.afterimage_timer = 0
        self.afterimage_count = -1
    
        self.flash = 0
    
        self.attacked = false
        self.removing = false
        
        if Mod.libs["magical-glass"] and Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and Game:isLight() then
            self.head_sprite:addFX(ShaderFX("color", {targetColor = MG_PALETTE["light_world_dark_battle_color"]}))
        end
        
        if #Game.battle.party <= 3 then return end
        
        self.head_sprite:setOrigin(0.5, 0.75 + (2 * (#Game.battle.party - 4) * 0.075))
        self.press_sprite:setOrigin(0, (#Game.battle.party - 4) * 0.025)
        self.head_sprite:setScale(1 - ((#Game.battle.party - 4) * 0.125))
    end)

    -----  GETCLOSE

    Utils.hook(AttackBox, "getClose", function(orig, self)
        local close = self.bolts[1].x - self.bolt_target - 2
        if self.battler:getBoltSpeed() < 8 and self.bolts[1].x <= self.bolt_target + 10 then
            return close / 8
        else
            return close / self.battler:getBoltSpeed()
        end
    end)

    -----  HIT

    Utils.hook(AttackBox, "hit", function(orig, self)
        local close = self:getClose()

        local equip = self.battler.chara:getWeapon() or Registry.createItem("everybodyweapon")
        return equip:onHit(self.battler, self.score, self.bolts, close)
    end)

    -----  MISS

    Utils.hook(AttackBox, "miss", function(orig, self)
        local close = self:getClose()

        local equip = self.battler.chara:getWeapon() or Registry.createItem("everybodyweapon")
        return equip:onWeaponMiss(self.battler, self.score, self.bolts, close)
    end)

    -----  UPDATE

    Utils.hook(AttackBox, "update", function(orig, self)
        if self.removing or Game.battle.cancel_attack then
            self.fade_rect.alpha = Utils.approach(self.fade_rect.alpha, 1, 0.08 * DTMULT)
        end
    
        if not self.attacked then

            self.afterimage_timer = self.afterimage_timer + DTMULT/2
            local acceleration = (self.battler:getBoltAcceleration() * (self.battler:getBoltSpeed() / 8)) / 10

            for _,bolt in ipairs(self.bolts) do
                if acceleration > 0 then
                    if bolt.x <= 84 + self.battler:getBoltSpeed() and bolt.target_magnet < 1 then
                        if not bolt.last_speed then
                            bolt.last_speed = bolt.physics.speed_x
                        end
                        bolt:resetPhysics()
                        bolt.x = 84
                        bolt.target_magnet = bolt.target_magnet + DTMULT
                    else
                        if bolt.last_speed then
                            bolt.physics.speed_x = bolt.last_speed
                            bolt.last_speed = nil
                        end
                        bolt.physics.gravity = acceleration
                        bolt.physics.gravity_direction = math.pi
                    end
                else
                    bolt:move(-(self.battler:getBoltSpeed()) * DTMULT, 0)
                end
            end
            while math.floor(self.afterimage_timer) > self.afterimage_count do
                self.afterimage_count = self.afterimage_count + 1
                for _,bolt in ipairs(self.bolts) do
                    local afterimg = AttackBar(bolt.x, 0, 6, #Game.battle.party > 3 and math.floor(112/#Game.battle.party) or 38)
                    afterimg.layer = 3
                    afterimg.alpha = 0.4
                    afterimg:fadeOutSpeedAndRemove()
                    self:addChild(afterimg)
                end
            end
        end
        
        local pressed_confirm = false
        if Mod.libs["multiplayer"] then
            for i = 2, math.min(Mod.libs["multiplayer"].max_players, #Game.battle.party) do
                if Input.pressed("p".. i .."_confirm") then
                    pressed_confirm = true
                end
            end
        end
    
        if not Game.battle.cancel_attack and (Input.pressed("confirm") or pressed_confirm) then
            self.flash = 1
        else
            self.flash = Utils.approach(self.flash, 0, DTMULT/5)
        end

        Object.update(self)
    end)

    -----  DRAW

    Utils.hook(AttackBox, "draw", function(orig, self)
        local target_color = {self.battler.chara:getAttackBarColor()}
        local box_color = {self.battler.chara:getAttackBoxColor()}
    
        if self.flash > 0 then
            box_color = Utils.lerp(box_color, {1, 1, 1}, self.flash)
        end
    
        love.graphics.setLineWidth(2)
        love.graphics.setLineStyle("rough")

        local ch1_offset = Game:getConfig("oldUIPositions") and #Game.battle.party <= 4

        love.graphics.setColor(box_color)
        local height = #Game.battle.party > 3 and math.floor(104 / #Game.battle.party) or 36
        
        love.graphics.rectangle("line", 80, ch1_offset and 0 or 1, (15 * (self.battler:getBoltSpeed())) + 3, height + (ch1_offset and 1 or 0))

        love.graphics.setColor(target_color)
        love.graphics.rectangle("line", self.bolt_target + 1, 1, 8, height)
        Draw.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 84, 2, 6, height - 2)
    
        love.graphics.setLineWidth(1)
    
        Object.draw(self)
    end)

    ----------------------------------------------------------------------------------
    -----  BATTLE HOOKS  
    ----------------------------------------------------------------------------------

    -----  PROCESSACTION

    Utils.hook(Battle, "processAction", function(orig, self, action)
        local battler = self.party[action.character_id]
        local party_member = battler.chara
        local enemy = action.target
        local battler_weapon = battler.chara:getWeapon() or Registry.createItem("everybodyweapon")

        self.current_processing_action = action

        local next_enemy = self:retargetEnemy()
        if not next_enemy then
            return true
        end

        if enemy and enemy.done_state then
            enemy = next_enemy
            action.target = next_enemy
        end

        -- Call mod callbacks for onBattleAction to either add new behaviour for an action or override existing behaviour
        -- Note: non-immediate actions require explicit "return false"!
        local callback_result = Kristal.modCall("onBattleAction", action, action.action, battler, enemy)
        if callback_result ~= nil then
            return callback_result
        end
        for lib_id,_ in pairs(Mod.libs) do
            callback_result = Kristal.libCall(lib_id, "onBattleAction", action, action.action, battler, enemy)
            if callback_result ~= nil then
                return callback_result
            end
        end
        
        if Mod.libs["classic_turn_based_rpg"] then
            if action.action == "AUTOATTACK" and action.critical then
                Assets.stopAndPlaySound("criticalswing")

                for i = 1, 3 do
                    local sx, sy = battler:getRelativePos(battler.width, 0)
                    local sparkle = Sprite("effects/criticalswing/sparkle", sx + Utils.random(50), sy + 30 + Utils.random(30))
                    sparkle:play(4/30, true)
                    sparkle:setScale(2)
                    sparkle.layer = BATTLE_LAYERS["above_battlers"]
                    sparkle.physics.speed_x = Utils.random(2, 6)
                    sparkle.physics.friction = -0.25
                    sparkle:fadeOutSpeedAndRemove()
                    self:addChild(sparkle)
                end
            end
        end
        
        local attackbox
        for _,box in ipairs(Game.battle.battle_ui.attack_boxes) do
            if box.battler == battler then
                attackbox = box
                break
            end
        end

        if action.action == "ATTACK" or action.action == "AUTOATTACK" then
            if action.action == "ATTACK" and attackbox.attacked then
                battler_weapon:onAttack(action, battler, enemy, attackbox.score, attackbox.bolts, attackbox.close)
            elseif action.action == "AUTOATTACK" then
                battler_weapon:onAttack(action, battler, enemy, 150, 1, 0)
            end
            return false
        elseif action.action == "SKIP" then
            return true -- multi act fix
        else
            orig(self, action)
        end
    end)

    -----  UPDATEATTACKING

    Utils.hook(Battle, "updateAttacking", function(orig, self)
        if self.cancel_attack then
            self:finishAllActions()
            self:setState("ACTIONSDONE")
            return
        end

        if not self.attack_done then
            if not self.battle_ui.attacking then
                self.battle_ui:beginAttack()
            end

            if #self.attackers == #self.auto_attackers and self.auto_attack_timer < 4 then
                self.auto_attack_timer = self.auto_attack_timer + DTMULT

                if self.auto_attack_timer >= 4 then
                    local next_attacker = self.auto_attackers[1]

                    local next_action = self:getActionBy(next_attacker)
                    if next_action then
                        self:beginAction(next_action)
                        self:processAction(next_action)
                    end
                end
            end

            local all_done = true

            for _,box in ipairs(self.battle_ui.attack_boxes) do
                if not box.attacked and box.fade_rect.alpha < 1 then

                    local close = box:getClose()

                    if close <= -2 and #box.bolts > 1 then

                        all_done = false
                        box:miss()                 

                    elseif close <= -2 then

                        local points = box:miss() -- lmao

                        local action = self:getActionBy(box.battler)
                        action.points = points

                        if self:processAction(action) then
                            self:finishAction(action)
                        end

                    else
                        all_done = false
                    end

                end
            end

            if #self.auto_attackers > 0 then
                all_done = false
            end

            if all_done then
                self.attack_done = true
            end
        else
            if self:allActionsDone() then
                self:setState("ACTIONSDONE")
            end
        end
    end)

    -----  DRAWDEBUG

    Utils.hook(Battle, "drawDebug", function(orig, self)
        orig(self)

        local ui = self.battle_ui

        for i, box in ipairs(self.battle_ui.attack_boxes) do
            local battler = box.battler

            if battler:getBoltCount() > 1 then
                local perfect_score = (150 * battler:getBoltCount())
                local crit_req = perfect_score - 30
        
                if self.state == "ATTACKING" or self.state == "ACTIONSDONE" and ui.attack_boxes[i] then

                    if perfect_score - ui.attack_boxes[i].score <= 0 then
                        love.graphics.setColor(0, 1, 0, 1)
                    elseif perfect_score - ui.attack_boxes[i].score <= 30 then
                        love.graphics.setColor(0, 1, 1, 1)
                    elseif perfect_score - ui.attack_boxes[i].score <= 80 then
                        love.graphics.setColor(1, 1, 0, 1)
                    elseif perfect_score - ui.attack_boxes[i].score <= 120 then
                        love.graphics.setColor(1, 0, 0, 1)
                    end

                    self:debugPrintOutline(battler.chara.name .. "'s score: " .. math.floor(ui.attack_boxes[i].score) .. ", (" .. crit_req .. " for a crit)", 4, ui.attack_boxes[i].y + 310)
                end
            end
        end
    end)
end

return Lib
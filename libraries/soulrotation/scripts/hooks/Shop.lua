local Shop, super = Class(Shop)

function Shop:draw()
    self:drawBackground()

    super.super.draw(self)

    love.graphics.setFont(self.font)
    if self.state == "MAINMENU" then
        Draw.setColor(COLORS.white)
        for i = 1, #self.menu_options do
            love.graphics.print(self.menu_options[i][1], 480, 220 + (i * 40))
        end
        Draw.setColor(Game:getSoulColor())
        Draw.draw(self.heart_sprite, 458, 238 + (self.main_current_selecting * 40), Game:getSoulRotation(), 1, 1, 8, 8)
    elseif self.state == "BUYMENU" then

        while self.current_selecting - self.item_offset > 5 do
            self.item_offset = self.item_offset + 1
        end

        while self.current_selecting - self.item_offset < 1 do
            self.item_offset = self.item_offset - 1
        end

        if self.item_offset + 5 > #self.items + 1 then
            if #self.items + 1 > 5 then
                self.item_offset = self.item_offset - 1
            end
        end

        if #self.items + 1 == 5 then
            self.item_offset = 0
        end

        -- Item type (item, key, weapon, armor)
        for i = 1 + self.item_offset, self.item_offset + math.max(4, math.min(5, #self.items)) do
            if i == math.max(4, #self.items) + 1 then break end
            local y = 220 + ((i - self.item_offset) * 40)
            local item = self.items[i]
            if not item then
                -- If the item is null, add some empty space
                Draw.setColor(COLORS.dkgray)
                love.graphics.print("--------", 60, y)
            elseif item.options["stock"] and (item.options["stock"] <= 0) then
                -- If we've depleted the stock, show a "sold out" message
                Draw.setColor(COLORS.gray)
                love.graphics.print("--SOLD OUT--", 60, y)
            else
                Draw.setColor(item.options["color"])
                love.graphics.print(item.options["name"], 60, y)
                if not self.hide_price then
                    Draw.setColor(COLORS.white)
                    love.graphics.print(string.format(self.currency_text, item.options["price"] or 0), 60 + 240, y)
                end
            end
        end
        Draw.setColor(COLORS.white)
        if self.item_offset == math.max(4, #self.items) - 4 then
            love.graphics.print("Exit", 60, 220 + (math.max(4, #self.items) + 1 - self.item_offset) * 40)
        end
        Draw.setColor(Game:getSoulColor())
        if not self.buy_confirming then
            Draw.draw(self.heart_sprite, 38, 238 + ((self.current_selecting - self.item_offset) * 40), Game:getSoulRotation(), 1, 1, 8, 8)
        else
            Draw.draw(self.heart_sprite, 38 + 420, 238 + 80 + 10 + (self.current_selecting_choice * 30), Game:getSoulRotation(), 1, 1, 8, 8)
            Draw.setColor(COLORS.white)
            local lines = Utils.split(string.format(self.buy_confirmation_text, string.format(self.currency_text, self.items[self.current_selecting].options["price"] or 0)), "\n")
            for i = 1, #lines do
                love.graphics.print(lines[i], 60 + 400, 420 - 160 + ((i - 1) * 30))
            end
            love.graphics.print("Yes", 60 + 420, 420 - 80)
            love.graphics.print("No",  60 + 420, 420 - 80 + 30)
        end
        Draw.setColor(COLORS.white)

        if (self.current_selecting <= #self.items) then
            local current_item = self.items[self.current_selecting]
            local box_left, box_top = self.info_box:getBorder()

            local left = self.info_box.x - self.info_box.width - (box_left / 2) * 1.5
            local top = self.info_box.y - self.info_box.height - (box_top / 2) * 1.5
            local width = self.info_box.width + box_left * 1.5
            local height = self.info_box.height + box_top * 1.5

            Draw.pushScissor()
            Draw.scissor(left, top, width, height)

            Draw.setColor(COLORS.white)
            love.graphics.print(current_item.options["description"], left + 32, top + 20)

            if current_item.item.type == "armor" or current_item.item.type == "weapon" then
                for i = 1, #Game.party do
                    -- Turn the index into a 2 wide grid (0-indexed)
                    local transformed_x = (i - 1) % 2
                    local transformed_y = math.floor((i - 1) / 2)

                    -- Transform the grid into coordinates
                    local offset_x = transformed_x * 100
                    local offset_y = transformed_y * 45

                    local party_member = Game.party[i]
                    local can_equip = party_member:canEquip(current_item.item)
                    local head_path = ""

                    love.graphics.setFont(self.plain_font)
                    Draw.setColor(COLORS.white)

                    if can_equip then
                        head_path = Assets.getTexture(party_member:getHeadIcons() .. "/head")
                        if current_item.item.type == "armor" then
                            Draw.draw(self.stat_icons["defense_1"], offset_x + 470, offset_y + 127 + top)
                            Draw.draw(self.stat_icons["defense_2"], offset_x + 470, offset_y + 147 + top)

                            for j = 1, 2 do
                                self:drawBonuses(party_member, party_member:getArmor(j), current_item.options["bonuses"], "defense", offset_x + 470 + 21, offset_y + 127 + ((j - 1) * 20) + top)
                            end

                        elseif current_item.item.type == "weapon" then
                            Draw.draw(self.stat_icons["attack"], offset_x + 470, offset_y + 127 + top)
                            Draw.draw(self.stat_icons["magic" ], offset_x + 470, offset_y + 147 + top)
                            self:drawBonuses(party_member, party_member:getWeapon(), current_item.options["bonuses"], "attack", offset_x + 470 + 21, offset_y + 127 + top)
                            self:drawBonuses(party_member, party_member:getWeapon(), current_item.options["bonuses"], "magic",  offset_x + 470 + 21, offset_y + 147 + top)
                        end
                    else
                        head_path = Assets.getTexture(party_member:getHeadIcons() .. "/head_error")
                    end

                    Draw.draw(head_path, offset_x + 426, offset_y + 132 + top)
                end
            end

            Draw.popScissor()

            Draw.setColor(COLORS.white)

            if not self.hide_storage_text then
                love.graphics.setFont(self.plain_font)

                local current_storage = Game.inventory:getDefaultStorage(current_item.item)
                local space = Game.inventory:getFreeSpace(current_storage)

                if space <= 0 then
                    love.graphics.print("NO SPACE", 521, 430)
                else
                    love.graphics.print("Space:" .. space, 521, 430)
                end
            end
        end
    elseif self.state == "SELLMENU" then
        Draw.setColor(Game:getSoulColor())
        Draw.draw(self.heart_sprite, 58, 238 + (self.sell_current_selecting * 40), Game:getSoulRotation(), 1, 1, 8, 8)
        Draw.setColor(COLORS.white)
        love.graphics.setFont(self.font)
        for i, v in ipairs(self.sell_options) do
            love.graphics.print(v[1], 80, 220 + (i * 40))
        end
        love.graphics.print("Return", 80, 220 + ((#self.sell_options + 1) * 40))
    elseif self.state == "SELLING" then
        if self.item_current_selecting - self.item_offset > 5 then
            self.item_offset = self.item_offset + 1
        end

        if self.item_current_selecting - self.item_offset < 1 then
            self.item_offset = self.item_offset - 1
        end

        local inventory = Game.inventory:getStorage(self.state_reason[2])

        if inventory and inventory.sorted then
            if self.item_offset + 5 > #inventory then
                if #inventory > 5 then
                    self.item_offset = self.item_offset - 1
                end
            end
            if #inventory == 5 then
                self.item_offset = 0
            end
        end

        Draw.setColor(Game:getSoulColor())

        Draw.draw(self.heart_sprite, 38, 238 + ((self.item_current_selecting - self.item_offset) * 40), Game:getSoulRotation(), 1, 1, 8, 8)
        if self.sell_confirming then
            Draw.draw(self.heart_sprite, 38 + 420, 238 + 80 + 10 + (self.current_selecting_choice * 30), Game:getSoulRotation(), 1, 1, 8, 8)
            Draw.setColor(COLORS.white)
            local lines = Utils.split(string.format(self.sell_confirmation_text, string.format(self.currency_text, inventory[self.item_current_selecting]:getSellPrice())), "\n")
            for i = 1, #lines do
                love.graphics.print(lines[i], 60 + 400, 420 - 160 + ((i - 1) * 30))
            end
            love.graphics.print("Yes", 60 + 420, 420 - 80)
            love.graphics.print("No",  60 + 420, 420 - 80 + 30)
        end

        Draw.setColor(COLORS.white)

        if inventory then
            for i = 1 + self.item_offset, self.item_offset + math.min(5, inventory.max) do
                local item = inventory[i]
                love.graphics.setFont(self.font)

                if item then
                    Draw.setColor(COLORS.white)
                    love.graphics.print(item:getName(), 60, 220 + ((i - self.item_offset) * 40))
                    if item:isSellable() then
                        love.graphics.print(string.format(self.currency_text, item:getSellPrice()), 60 + 240, 220 + ((i - self.item_offset) * 40))
                    end
                else
                    Draw.setColor(COLORS.dkgray)
                    love.graphics.print("--------", 60, 220 + ((i - self.item_offset) * 40))
                end
            end

            local max = inventory.max
            if inventory.sorted then
                max = #inventory
            end

            Draw.setColor(COLORS.white)

            if max > 5 then

                for i = 1, max do
                    local percentage = (i - 1) / (max - 1)
                    local height = 129

                    local draw_location = percentage * height

                    local tocheck = self.item_current_selecting
                    if self.sell_confirming then
                        tocheck = self.current_selecting_choice
                    end

                    if i == tocheck then
                        love.graphics.rectangle("fill", 372, 292 + draw_location, 9, 9)
                    elseif inventory.sorted then
                        love.graphics.rectangle("fill", 372 + 3, 292 + 3 + draw_location, 3, 3)
                    end
                end

                -- Draw arrows
                if not self.sell_confirming then
                    local sine_off = math.sin((Kristal.getTime()*30)/6) * 3
                    if self.item_offset + 4 < (max - 1) then
                        Draw.draw(self.arrow_sprite, 370, 149 + sine_off + 291)
                    end
                    if self.item_offset > 0 then
                        Draw.draw(self.arrow_sprite, 370, 14 - sine_off + 291 - 25, 0, 1, -1)
                    end
                end
            end
        else
            love.graphics.print("Invalid storage", 60, 220 + (1 * 40))
        end
    elseif self.state == "TALKMENU" then
        Draw.setColor(Game:getSoulColor())
        Draw.draw(self.heart_sprite, 58, 238 + (self.current_selecting * 40), Game:getSoulRotation(), 1, 1, 8, 8)
        Draw.setColor(COLORS.white)
        love.graphics.setFont(self.font)
        for i = 1, math.max(4, #self.talks) do
            local v = self.talks[i]
            if v then
                Draw.setColor(v[2].color)
                love.graphics.print(v[1], 80, 220 + (i * 40))
            else
                Draw.setColor(COLORS.dkgray)
                love.graphics.print("--------", 80, 220 + (i * 40))
            end
        end
        Draw.setColor(COLORS.white)
        love.graphics.print("Exit", 80, 220 + ((math.max(4, #self.talks) + 1) * 40))
    end

    if self.state == "MAINMENU" or
       self.state == "BUYMENU"  or
       self.state == "SELLMENU" or
       self.state == "SELLING"  or
       self.state == "TALKMENU" then
        Draw.setColor(COLORS.white)
        love.graphics.setFont(self.font)
        love.graphics.print(string.format(self.currency_text, self:getMoney()), 440, 420)
    end

    Draw.setColor(0, 0, 0, self.fade_alpha)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
end

return Shop
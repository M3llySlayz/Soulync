--- Like some king of... oftome cool transition...
---@class Event.cooltransition : Transition
local event, super = Class(Transition, "cooltransition")

function event:init(data)
    local properties = data and data.properties or {}
    super.init(self, data.x, data.y, {data.width, data.height, data.polygon}, properties)
end


function event:onEnter(chara)
    if chara.is_player then
        local x, y = self.target.x, self.target.y
        local facing = self.target.facing
        local marker = self.target.marker

        if self.sound then
            Assets.playSound(self.sound, 1, self.pitch)
        end

        if self.target.shop then
            self.world:shopTransition(self.target.shop, {x=x, y=y, marker=marker, facing=facing, map=self.target.map})
        elseif self.target.map then
            local callback = function(map)
                if self.exit_sound then
                    Assets.playSound(self.exit_sound, 1, self.exit_pitch)
                end
                Game.world.door_delay = self.exit_delay
            end

            if marker then
                self.world:coolMapTransition(self.target.map, marker, facing or chara.facing, callback)
            else
                self.world:coolMapTransition(self.target.map, x, y, facing or chara.facing, callback)
            end
        end
    end
end
return event
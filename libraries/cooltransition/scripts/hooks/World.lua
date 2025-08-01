---@class World : World
local World, super = Utils.hookScript(World)

--- Loads a new map and starts the transition effects for world music, borders, and the screen as a whole
---@overload fun(self: World, map: string, ...: any)
---@param ... any   Additional arguments that will be passed into World:loadMap()
---@see World - World:loadMap() 
function World:coolMapTransition(...)
    local resume
    local wait = coroutine.yield
    resume = coroutine.wrap(function (...)
        local args = {...}
        local map = args[1]
        if type(map) == "string" then
            local map = Registry.createMap(map)
            if not map.keep_music then
                self:transitionMusic(Kristal.callEvent(KRISTAL_EVENT.onMapMusic, self.map, self.map.music) or map.music, true)
            end
            local dark_transition = map.light ~= Game:isLight()
            local map_border = map:getBorder(dark_transition)
            if map_border then
                Game:setBorder(Kristal.callEvent(KRISTAL_EVENT.onMapBorder, self.map, map_border) or map_border, 1)
            end
        end
        local map = table.remove(args, 1)
        local marker, x, y, facing, callback
        if type(args[1]) == "string" then
            marker = table.remove(args, 1)
        elseif type(args[1]) == "number" then
            x = table.remove(args, 1)
            y = table.remove(args, 1)
        else
            marker = "spawn"
        end
        if args[1] then
            facing = table.remove(args, 1)
        end
        if args[1] then
            callback = table.remove(args, 1)
        end

        if self.map then
            self.map:onExit()
        end
        self.old_map_parent = Object()
        self.old_map_parent.world = self
        for _, follower in ipairs(self.followers) do
            follower.persistent = true
        end
        for index, child in ipairs(self.children) do
            ---@cast child Object|Player
            if not child.persistent and not (child:includes(OverworldSoul) or child:includes(Follower)) then
                local wld = child.world
                child:setParent(self.old_map_parent)
                child.world = wld
            end
        end
        self:updateChildList()
        self:addChild(self.old_map_parent)
        self:setState("FADING")
        local afx = self.old_map_parent:addFX(AlphaFX(1))
        self.timer:after(0.1, resume)
        wait()
        local opx, opy = self.player:getPosition()
        self.old_map_parent.persistent = true
        local followers = self.followers
        self:setupMap(map, ...)
        self.followers = followers
        self.old_map_parent.persistent = false
        if marker then x, y = self.map:getMarker(marker) end

        local off_x, off_y = x - opx, y - opy

        self.player.x = self.player.x + off_x
        self.player.layer = self.map.object_layer
        self.player.y = self.player.y + off_y
        for _, follower in ipairs(self.followers) do
            ---@cast follower Follower
            follower.persistent = false
            follower.layer = self.map.object_layer
            follower.x = follower.x + off_x
            follower.y = follower.y + off_y
            for _, hist in ipairs(follower.history) do
                hist.x = hist.x + off_x
                hist.y = hist.y + off_y
            end
        end
        self.old_map_parent.x = self.old_map_parent.x + off_x
        self.old_map_parent.y = self.old_map_parent.y + off_y

        local newafx = AlphaFX(0)
        ---@type Object[]
        local all_objects = Utils.mergeMultiple(self.map.events, self.map.tile_layers, self.map.image_layers)
        for _, value in ipairs(all_objects) do
            value:addFX(newafx)
        end
        self.timer:tween(0.25, afx, {alpha = 0}, "linear", resume)
        self.timer:tween(0.25, newafx, {alpha = 1}, "linear", resume)
        wait()
        wait()
        for _, value in ipairs(all_objects) do
            value:removeFX(newafx)
        end
        self:setState("GAMEPLAY")
        self.old_map_parent:remove()
        self.old_map_parent = nil
        if callback then
            callback(self.map)
        end
    end)
    resume(...)
end

return World
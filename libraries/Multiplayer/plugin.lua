local plugin = love.filesystem.load(Kristal.Mods.data.multiplayer.path.."/lib.lua")()
plugin.init = Utils.override(plugin.init, function(orig, self, ...)
    MULTIPLAYER_IS_PLUGIN = true
    orig(self, ...)
end)
return plugin
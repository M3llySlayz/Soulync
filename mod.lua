function Mod:init()
    print("Loaded "..self.info.name.."!")
end

function Mod:postInit()
    Kristal.callEvent("setDesc", "mainline", "I have to find him.")
    if not Game:getFlag("self_discovery") then Game:addFlag("self_discovery", false) end
end
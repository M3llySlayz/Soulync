function Mod:init()
    print("Loaded "..self.info.name.."!")
end

function Mod:postInit()
    Kristal.callEvent("setDesc", "mainline", "I have to find him.")
end
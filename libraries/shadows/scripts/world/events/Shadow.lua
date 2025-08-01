local Shadow, super = Class(Event, "shadow")

function Shadow:init(data)
    super:init(self, data.x, data.y, data.w, data.h)
	
	properties = data.properties or {}

    self.solid = false

    self.canvas = love.graphics.newCanvas(data.width, data.height)
	
	self.shadow_scale = properties and properties["scale"] or 1.3
	
	self.opacity = properties and properties["opacity"] or 0.55
	
	self.shear = properties and properties["shear"] or 0.5
end

function Shadow:drawCharacter(object)
	love.graphics.push()
    local last_scale_y = object.scale_y
	object.scale_y = -self.shadow_scale
	object:preDraw()
	love.graphics.translate(-object.height * self.shear, 0)
	love.graphics.shear(self.shear, 0)
	object:draw()
	object:postDraw()
	object.scale_y = last_scale_y
	love.graphics.pop()
end

function Shadow:draw()
    super:draw(self)

    Draw.pushCanvas(self.canvas)
    love.graphics.clear()

    love.graphics.translate(-self.x, -self.y)

    for _, object in ipairs(Game.world.children) do
        if object:includes(Character) then

            love.graphics.setShader(Kristal.Shaders["AddColor"])

            Kristal.Shaders["AddColor"]:send("inputcolor", {0, 0, 0, 1})
            Kristal.Shaders["AddColor"]:send("amount", 1)

            self:drawCharacter(object)

            love.graphics.setShader()
        end
    end

    Draw.popCanvas()

    love.graphics.setColor(0, 0, 0, self.opacity)
    love.graphics.draw(self.canvas)
    love.graphics.setColor(1, 1, 1, 1)
end

return Shadow
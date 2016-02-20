local Camera = {}
Camera.__index = Camera

function Camera.new(args)
    local camera = setmetatable({}, Camera)
    camera:init(args)
    return camera
end

function Camera:init(args)
    self.game = args.game
    self.categories = args.categories or {"camera"}

    self.x, self.y = args.x or 0, args.y or 0
    self.scale = args.scale or 1

    self.game.drawHandlers.camera[self] = Camera.draw
    self.game:register(self, self.categories)
end

function Camera:destroy()
    self.game:deregister(self, self.categories)
    self.game.drawHandlers.camera[self] = nil
end

function Camera:draw()
    local width, height = love.graphics.getDimensions()
    local scale = self.scale * height

    love.graphics.translate(0.5 * width, 0.5 * height)
    love.graphics.scale(scale)
    love.graphics.translate(-self.x, -self.y)
    love.graphics.setLineWidth(1 / scale)
end

return Camera

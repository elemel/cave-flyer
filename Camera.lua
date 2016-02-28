local Camera = {}
Camera.__index = Camera

function Camera.new(args)
    local camera = setmetatable({}, Camera)
    camera:init(args)
    return camera
end

function Camera:init(args)
    self.game = args.game
    self.tags = args.tags or {"camera"}

    self.x, self.y = args.x or 0, args.y or 0
    self.scale = args.scale or 1

    self.game.drawHandlers.camera[self] = Camera.draw
    self.game:register(self, self.tags)
end

function Camera:destroy()
    self.game:deregister(self, self.tags)
    self.game.drawHandlers.camera[self] = nil
end

function Camera:draw()
    local width, height = love.graphics.getDimensions()
    local scale = self.scale * height

    love.graphics.translate(0.5 * width, 0.5 * height)
    love.graphics.scale(scale)
    love.graphics.translate(-self.x, -self.y)
    love.graphics.setLineWidth(1 / scale)

    local worldX, worldY = self:getWorldPoint(love.mouse.getPosition())
    love.graphics.circle("line", worldX, worldY, 1 / 16, 16)
end

function Camera:getWorldPoint(screenX, screenY)
    local width, height = love.graphics.getDimensions()
    local scale = self.scale * height

    local worldX, worldY = screenX - 0.5 * width, screenY - 0.5 * height
    return self.x + worldX / scale, self.y + worldY / scale
end

return Camera

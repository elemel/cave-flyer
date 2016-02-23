local Bullet = require "Bullet"

local Gun = {}
Gun.__index = Gun

function Gun.new(args)
    local gun = setmetatable({}, Gun)
    gun:init(args)
    return gun
end

function Gun:init(args)
    self.game = assert(args.game)
    self.ship = assert(args.ship)
    self.body = assert(args.body)
    self.localAngle = (args.angle or 0) - self.body:getAngle()
    self.delay = args.delay or 1
    self.speed = args.speed or 1
    self.currentDelay = args.currentDelay or 0
    self.groupIndex = args.groupIndex or 0

    self.game.updateHandlers.control[self] = Gun.updateControl
end

function Gun:destroy()
    self.game.updateHandlers.control[self] = nil
end

function Gun:updateControl(dt)
    self.currentDelay = self.currentDelay + dt

    if self.ship.inputs.fire * self.currentDelay > self.delay then
        local x, y = self.body:getWorldCenter()
        local linearVelocityX, linearVelocityY =
            self.body:getLinearVelocityFromWorldPoint(x, y)
        local angle = self.localAngle + self.body:getAngle()

        Bullet.new({
            game = self.game,
            x = x, y = y,
            angle = angle,

            linearVelocityX = linearVelocityX + self.speed * math.cos(angle),
            linearVelocityY = linearVelocityY + self.speed * math.sin(angle),

            groupIndex = self.groupIndex,
        })

        self.currentDelay = 0
    end
end

return Gun

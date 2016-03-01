local Turner = {}
Turner.__index = Turner

function Turner.new(args)
    local turner = setmetatable({}, Turner)
    turner:init(args)
    return turner
end

function Turner:init(args)
    self.game = assert(args.game)
    self.ship = assert(args.ship)
    self.body = assert(args.body)
    self.acceleration = args.acceleration or 1
    self.speed = args.speed or 1
    self.mass = args.mass or 1 / 64

    self:updateJoint()
    self.game.updateHandlers.control[self] = Turner.updateControl
end

function Turner:destroy()
    self.game.updateHandlers.control[self] = nil

    if self.joint then
        self.joint:destroy()
    end

    if self.fixedBody then
        self.fixedBody:destroy()
    end
end

function Turner:updateControl(dt)
    if self.joint then
        self.joint:setMotorSpeed(self.ship.inputs.turn * self.speed)
    end
end

function Turner:updateJoint()
    local linearVelocityX, linearVelocityY = 0, 0

    if self.joint then
        self.joint:destroy()
    end

    if self.fixedBody then
        linearVelocityX, linearVelocityY = self.fixedBody:getLinearVelocity()
        self.fixedBody:destroy()
    end

    local physics = next(self.game.registry.physics)
    local x, y = self.body:getWorldCenter()
    local inertia = self.body:getInertia()

    self.fixedBody = love.physics.newBody(physics.world, x, y, "dynamic")
    self.fixedBody:setFixedRotation(true)
    self.fixedBody:setMass(self.mass)
    self.fixedBody:setLinearVelocity(linearVelocityX, linearVelocityY)

    self.joint = love.physics.newRevoluteJoint(self.fixedBody, self.body, x, y)
    self.joint:setMotorEnabled(true)
    self.joint:setMaxMotorTorque(self.acceleration * inertia)
end

return Turner

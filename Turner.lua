local Turner = {}
Turner.__index = Turner

function Turner.new(args)
    local turner = setmetatable({}, Turner)
    turner:init(args)
    return turner
end

function Turner:init(args)
    self.game = assert(args.game)
    self.body = assert(args.body)
    self.acceleration = args.acceleration or 1
    self.speed = args.speed or 1
    self.input = args.input or 0

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
        self.joint:setMotorSpeed(self.input * self.speed)
    end
end

function Turner:updateJoint()
    if self.joint then
        self.joint:destroy()
    end

    if self.fixedBody then
        self.fixedBody:destroy()
    end

    local physics = next(self.game.registry.physics)
    local x, y = self.body:getWorldCenter()
    local inertia = self.body:getInertia()

    self.fixedBody = love.physics.newBody(physics.world, x, y, "dynamic")
    self.fixedBody:setFixedRotation(true)

    self.joint = love.physics.newRevoluteJoint(self.fixedBody, self.body, x, y)
    self.joint:setMotorEnabled(true)
    self.joint:setMaxMotorTorque(self.acceleration * inertia)
end

return Turner

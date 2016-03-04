local MotorTurner = {}
MotorTurner.__index = MotorTurner

function MotorTurner.new(args)
    local turner = setmetatable({}, MotorTurner)
    turner:init(args)
    return turner
end

function MotorTurner:init(args)
    self.game = assert(args.game)
    self.ship = assert(args.ship)
    self.body = assert(args.body)
    self.acceleration = args.acceleration or 1

    local physics = next(self.game.registry.physics)

    self.joint = love.physics.newMotorJoint(physics.ground, self.body)
    self.joint:setMaxForce(0)

    self.game.updateHandlers.control[self] = MotorTurner.updateControl
end

function MotorTurner:destroy()
    self.game.updateHandlers.control[self] = nil

    if self.joint then
        self.joint:destroy()
    end
end

function MotorTurner:updateControl(dt)
    local inertia = self.body:getInertia()
    self.joint:setMaxTorque(self.acceleration * inertia)

    local x, y = self.body:getPosition()
    local inputs = self.ship.inputs
    local angle = math.atan2(inputs.targetY - y, inputs.targetX - x)

    while angle < self.body:getAngle() do
        angle = angle + 2 * math.pi
    end

    while angle > self.body:getAngle() do
        angle = angle - 2 * math.pi
    end

    if math.abs(angle + 2 * math.pi - self.body:getAngle()) < math.abs(angle - self.body:getAngle()) then
        angle = angle + 2 * math.pi
    end

    self.joint:setAngularOffset(angle)
end

return MotorTurner

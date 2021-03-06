local Thruster = {}
Thruster.__index = Thruster

function Thruster.new(args)
    local thruster = setmetatable({}, Thruster)
    thruster:init(args)
    return thruster
end

function Thruster:init(args)
    self.game = assert(args.game)
    self.ship = assert(args.ship)
    self.body = assert(args.body)
    self.acceleration = args.acceleration or 0
    self.localAngle = (args.angle or 0) - self.body:getAngle()

    self.game.updateHandlers.control[self] = Thruster.updateControl
end

function Thruster:destroy()
    self.game.updateHandlers.control[self] = nil
end

function Thruster:updateControl(dt)
    local x, y, mass, inertia = self.body:getMassData()
    local force = self.ship.inputs.thrust * mass * self.acceleration
    local angle = self.localAngle + self.body:getAngle()
    self.body:applyForce(force * math.cos(angle), force * math.sin(angle))
end

return Thruster

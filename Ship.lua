local Thruster = require "Thruster"
local Wall = require "Wall"

local Ship = {}
Ship.__index = Ship

function Ship.new(args)
    local ship = setmetatable({}, Ship)
    ship:init(args)
    return ship
end

function Ship:init(args)
    self.game = args.game
    self.turnSpeed = args.turnSpeed or 2 * math.pi
    self.turnAcceleration = args.turnAcceleration or 4 * math.pi
    self.thrustAcceleration = args.thrustAcceleration or 20

    local x, y = args.x or 0, args.y or 0

    self.wall = Wall.new({
        game = self.game,
        x = x, y = y,
        bodyType = "dynamic",
    })

    self.thruster = Thruster.new({
        game = self.game,
        body = self.wall.body,
        acceleration = self.thrustAcceleration,
        angle = math.atan2(-1, 1),
    })

    self.game.updateHandlers.input[self] = Ship.updateInput
    self.game.updateHandlers.control[self] = Ship.updateControl
    self.game.updateHandlers.animation[self] = Ship.updateAnimation
end

function Ship:destroy()
    self.game.updateHandlers.animation[self] = nil
    self.game.updateHandlers.control[self] = nil
    self.game.updateHandlers.input[self] = nil

    if self.turnJoint then
        self.turnJoint:destroy()
    end

    if self.turnBody then
        self.turnBody:destroy()
    end

    self.wall:destroy()
end

function Ship:updateInput(dt)
    self.thruster.input = love.keyboard.isDown("up") and 1 or 0
end

function Ship:updateControl(dt)
    if self.turnJoint then
        local leftInput = love.keyboard.isDown("left") and 1 or 0
        local rightInput = love.keyboard.isDown("right") and 1 or 0
        local turnInput = rightInput - leftInput
        self.turnJoint:setMotorSpeed(turnInput * self.turnSpeed)
    end
end

function Ship:updateAnimation(dt)
    local camera = next(self.game.registry.camera)
    camera.x, camera.y = self.wall.body:getWorldCenter()
end

function Ship:updateTurnJoint()
    if self.turnJoint then
        self.turnBody:destroy()
    end

    if self.turnBody then
        self.turnBody:destroy()
    end

    local physics = next(self.game.registry.physics)
    local x, y, mass, inertia = self.wall.body:getMassData()

    self.turnBody = love.physics.newBody(physics.world, x, y, "dynamic")
    self.turnBody:setFixedRotation(true)

    self.turnJoint = love.physics.newRevoluteJoint(self.turnBody, self.wall.body, x, y)
    self.turnJoint:setMotorEnabled(true)
    self.turnJoint:setMaxMotorTorque(self.turnAcceleration * inertia)
end

return Ship

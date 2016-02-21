local Gun = require "Gun"
local Thruster = require "Thruster"
local Turner = require "Turner"
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
    self.groupIndex = args.groupIndex or 0

    local x, y = args.x or 0, args.y or 0

    self.wall = Wall.new({
        game = self.game,
        x = x, y = y,
        bodyType = "dynamic",
        groupIndex = self.groupIndex,
    })

    self.turner = Turner.new({
        game = self.game,
        body = self.wall.body,
        acceleration = args.turnAcceleration or 4 * math.pi,
        speed = args.turnSpeed or 2 * math.pi,
    })

    self.thruster = Thruster.new({
        game = self.game,
        body = self.wall.body,
        acceleration = args.thrustAcceleration or 20,
        angle = math.atan2(-1, 1),
    })

    self.gun = Gun.new({
        game = self.game,
        body = self.wall.body,
        angle = math.atan2(-1, 1),
        speed = 16,
        delay = 1 / 4,
        groupIndex = self.groupIndex,
    })

    self.game.updateHandlers.input[self] = Ship.updateInput
    self.game.updateHandlers.animation[self] = Ship.updateAnimation
end

function Ship:destroy()
    self.game.updateHandlers.animation[self] = nil
    self.game.updateHandlers.input[self] = nil

    self.thruster:destroy()
    self.turner:destroy()
    self.wall:destroy()
end

function Ship:updateInput(dt)
    local leftInput = love.keyboard.isDown("a") and 1 or 0
    local rightInput = love.keyboard.isDown("d") and 1 or 0
    self.turner.input = rightInput - leftInput

    self.thruster.input = love.keyboard.isDown("w") and 1 or 0
    self.gun.input = love.keyboard.isDown("j") and 1 or 0
end

function Ship:updateAnimation(dt)
    local camera = next(self.game.registry.camera)
    camera.x, camera.y = self.wall.body:getWorldCenter()
end

return Ship

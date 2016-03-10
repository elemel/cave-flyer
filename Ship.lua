local Builder = require "Builder"
local Gun = require "Gun"
local Thruster = require "Thruster"
local TractorBeam = require "TractorBeam"
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
    self.destroyed = false
    self.game = args.game
    self.groupIndex = args.groupIndex or 0

    local x, y = args.x or 0, args.y or 0

    self.inputs = {
        turn = 0,
        thrust = 0,
        fire1 = 0, fire2 = 0, fire3 = 0,
        targetX = 0, targetY = 0,
    }

    self.wall = Wall.new({
        game = self.game,
        x = x, y = y,
        bodyType = "dynamic",
        groupIndex = self.groupIndex,
        category = "ship",
    })

    self.wall.body:setUserData({ship = self})

    self.wall:setBlock(0, 0, "metal")
    self.wall:setBlock(1, 0, "metal")
    self.wall:setBlock(0, -1, "metal")
    self.wall:setBlock(0, 1, "metal")

    self.wall:updateBlocks()

    self.turner = Turner.new({
        game = self.game,
        ship = self,
        body = self.wall.body,
        acceleration = args.turnAcceleration or 4 * math.pi,
        speed = args.turnSpeed or 2 * math.pi,
    })

    self.thruster = Thruster.new({
        game = self.game,
        ship = self,
        body = self.wall.body,
        acceleration = args.thrustAcceleration or 4,
    })

    self.gun = Gun.new({
        game = self.game,
        ship = self,
        body = self.wall.body,
        speed = 4,
        delay = 1 / 16,
        groupIndex = self.groupIndex,
    })

    self.tractorBeam = TractorBeam.new({
        game = self.game,
        ship = self,
        body = self.wall.body,
        groupIndex = self.groupIndex,
    })

    self.builder = Builder.new({
        game = self.game,
        ship = self,
        body = self.wall.body,
        groupIndex = self.groupIndex,
    })
end

function Ship:destroy()
    self.builder:destroy()
    self.tractorBeam:destroy()
    self.gun:destroy()
    self.thruster:destroy()
    self.turner:destroy()
    self.wall:destroy()

    self.destroyed = true
end

return Ship

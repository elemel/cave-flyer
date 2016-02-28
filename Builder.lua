local common = require "common"

local Builder = {}
Builder.__index = Builder

function Builder.new(args)
	local builder = setmetatable({}, Builder)
	builder:init(args)
	return builder
end

function Builder:init(args)
	self.game = args.game
	self.ship = args.ship
	self.body = args.body

    self.game.updateHandlers.control[self] = Builder.updateControl
    self.game.drawHandlers.debug[self] = Builder.debugDraw
end

function Builder:destroy()
    self.game.drawHandlers.debug[self] = nil
    self.game.updateHandlers.control[self] = nil
end

function Builder:updateControl(dt)
    if self.ship.inputs.fire2 > 0.5 then
        local x, y = self.ship.wall:getIndicesFromWorldPoint(self.ship.inputs.targetX, self.ship.inputs.targetY)
        self.ship.wall:setBlock(x, y, "metal")
        self.ship.wall:updateBlockFixtures()
        self.ship.turner:updateJoint()
    end

    if self.ship.inputs.fire3 > 0.5 then
        local x, y = self.ship.wall:getIndicesFromWorldPoint(self.ship.inputs.targetX, self.ship.inputs.targetY)
        self.ship.wall:setBlock(x, y, nil)
        self.ship.wall:updateBlockFixtures()
        self.ship.turner:updateJoint()
    end
end

function Builder:debugDraw()
    local x, y = self.body:getWorldCenter()
    local targetX, targetY = self.ship.inputs.targetX, self.ship.inputs.targetY
	love.graphics.line(x, y, targetX, targetY)
end

return Builder

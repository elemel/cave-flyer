local common = require "common"

local Player = {}
Player.__index = Player

function Player.new(args)
	local player = setmetatable({}, Player)
	player:init(args)
	return player
end

function Player:init(args)
	self.game = assert(args.game)
	self.ship = assert(args.ship)
	self.camera = assert(args.camera)

	self.game.updateHandlers.input[self] = Player.updateInput
	self.game.updateHandlers.animation[self] = Player.updateAnimation
end

function Player:destroy()
	self.game.updateHandlers.animation[self] = nil
	self.game.updateHandlers.input[self] = nil
end

function Player:updateInput(dt)
    local leftInput = love.keyboard.isDown("a") and 1 or 0
    local rightInput = love.keyboard.isDown("d") and 1 or 0
    self.ship.inputs.turn = rightInput - leftInput

    self.ship.inputs.thrust = love.keyboard.isDown("w") and 1 or 0
    self.ship.inputs.fire1 = love.keyboard.isDown("space") and 1 or 0

    self.ship.inputs.targetX, self.ship.inputs.targetY = self.camera:getWorldPoint(love.mouse.getPosition())
    self.ship.inputs.fire2 = love.mouse.isDown(1) and 1 or 0
    self.ship.inputs.fire3 = love.mouse.isDown(2) and 1 or 0
end

function Player:updateAnimation(dt)
	if not self.ship.destroyed then
	    self.camera.x, self.camera.y = self.ship.wall.body:getPosition()
	    local distance = common.length2(self.ship.wall.body:getPosition())
	    self.camera.scale = 0.5 / distance
	end
end

return Player

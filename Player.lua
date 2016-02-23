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
    self.ship.inputs.fire = love.keyboard.isDown("j") and 1 or 0
end

function Player:updateAnimation(dt)
    self.camera.x, self.camera.y = self.ship.wall.body:getWorldCenter()
end

return Player
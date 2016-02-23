local Ai = {}
Ai.__index = Ai

function Ai.new(args)
	local player = setmetatable({}, Ai)
	player:init(args)
	return player
end

function Ai:init(args)
	self.game = assert(args.game)
	self.ship = assert(args.ship)
	self.seed = args.seed or love.math.random()
	self.time = 0

	self.game.updateHandlers.input[self] = Ai.updateInput
end

function Ai:destroy()
	self.game.updateHandlers.input[self] = nil
end

function Ai:updateInput(dt)
	self.time = self.time + dt

    self.ship.inputs.turn = 2 * love.math.noise(1, self.time, self.seed) - 1

    self.ship.inputs.thrust = love.math.noise(2, self.time, self.seed)
    self.ship.inputs.fire = love.math.noise(3, self.time, self.seed)
end

return Ai

local Bullet = {}
Bullet.__index = Bullet

function Bullet.new(args)
	local bullet = setmetatable({}, Bullet)
	bullet:init(args)
	return bullet
end

function Bullet:init(args)
	self.game = args.game
	self.groupIndex = args.groupIndex or 0

    local physics = next(self.game.registry.physics)
    local world = physics.world
    local x, y = args.x or 0, args.y or 0
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.body:setAngle(args.angle or 0)

	local linearVelocityX = args.linearVelocityX or 0
	local linearVelocityY = args.linearVelocityY or 0
	self.body:setLinearVelocity(linearVelocityX, linearVelocityY)
	self.body:setAngularVelocity(args.angularVelocity or 0)

	local width, height = args.width or 1, args.height or 1
	local shape = love.physics.newRectangleShape(width, height)
	local density = args.density or 1
	self.fixture = love.physics.newFixture(self.body, shape, density)
	self.fixture:setGroupIndex(self.groupIndex)
	self.fixture:setCategory(physics.categoryIndices.bullet)
end

function Bullet:destroy()
	self.body:destroy()
end

return Bullet

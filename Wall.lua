local common = require "common"

local Wall = {}
Wall.__index = Wall

function Wall.new(args)
    local wall = setmetatable({}, Wall)
    wall:init(args)
    return wall
end

function Wall:init(args)
    self.game = args.game
    self.blocks = {}
    self.blockFixtures = {}
    self.dirtyBlockFixtures = {}
    self.groupIndex = args.groupIndex or 0

    self.blockWidth = args.blockWidth or 1 / 8
    self.blockHeight = args.blockHeight or 1 / 8

    self.originX, self.originY = args.originX or 0, args.originY or 0

    local physics = next(self.game.registry.physics)
    local world = physics.world

    local category = args.category or "unknown"
    self.categoryIndex = assert(physics.categoryIndices[category])

    local x, y = args.x or 0, args.y or 0
    local bodyType = args.bodyType or "static"
    self.body = love.physics.newBody(world, x, y, bodyType)
    self.body:setAngle(args.angle or 0)
end

function Wall:destroy()
    self.body:destroy()
end

function Wall:getBlock(x, y)
    return common.get2(self.blocks, x, y)
end

function Wall:setBlock(x, y, block)
    if block ~= self:getBlock(x, y) then
        common.set2(self.blocks, x, y, block)
        common.set2(self.dirtyBlockFixtures, x, y, true)
    end
end

function Wall:updateBlockFixtures()
    if next(self.dirtyBlockFixtures) then
        for x, column in pairs(self.dirtyBlockFixtures) do
            for y, _ in pairs(column) do
                self:updateBlockFixture(x, y)
            end
        end

        self.dirtyBlockFixtures = {}
    end
end

function Wall:updateBlockFixture(x, y)
    local block = common.get2(self.blocks, x, y)
    local fixture = common.get2(self.blockFixtures, x, y)

    if fixture then
        fixture:destroy()
        fixture = nil
    end

    if block then
        local blockX = (x + 0.5) * self.blockWidth - self.originX
        local blockY = (y + 0.5) * self.blockHeight - self.originY
        local shape = love.physics.newRectangleShape(blockX, blockY,
            self.blockWidth, self.blockHeight)

        fixture = love.physics.newFixture(self.body, shape, 1)
        fixture:setGroupIndex(self.groupIndex)
        fixture:setCategory(self.categoryIndex)
        fixture:setUserData({x = x, y = y})
    end

    common.set2(self.blockFixtures, x, y, fixture)
end

function Wall:getIndicesFromWorldPoint(worldX, worldY)
    local localX, localY = self.body:getLocalPoint(worldX, worldY)

    local x = math.floor((localX + self.originX) / self.blockWidth)
    local y = math.floor((localY + self.originY) / self.blockHeight)

    return x, y
end

return Wall

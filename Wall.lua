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
    self.dirtyBlocks = {}
    self.groupIndex = args.groupIndex or 0

    self.blockWidth = args.blockWidth or 1 / 8
    self.blockHeight = args.blockHeight or 1 / 8

    self.blockX1, self.blockY1 = math.huge, math.huge
    self.blockX2, self.blockY2 = -math.huge, -math.huge
    self.blockBoundsDirty = false

    self.canvas = nil
    self.canvasWidth, self.canvasHeight = 0, 0
    self.canvasOriginX, self.canvasOriginY = 0, 0

    local physics = next(self.game.registry.physics)
    local world = physics.world

    local category = args.category or "unknown"
    self.categoryIndex = assert(physics.categoryIndices[category])

    local x, y = args.x or 0, args.y or 0
    local bodyType = args.bodyType or "static"
    self.body = love.physics.newBody(world, x, y, bodyType)
    self.body:setAngle(args.angle or 0)

    self.game.drawHandlers.wall[self] = Wall.draw
end

function Wall:destroy()
    self.game.drawHandlers.wall[self] = nil

    self.body:destroy()
end

function Wall:getBlock(x, y)
    return common.get2(self.blocks, x, y)
end

function Wall:setBlock(x, y, block)
    if block ~= self:getBlock(x, y) then
        common.set2(self.blocks, x, y, block)

        for dirtyX = x - 1, x + 1 do
            for dirtyY = y - 1, y + 1 do
                common.set2(self.dirtyBlocks, dirtyX, dirtyY, true)
            end
        end

        if block then
            self.blockX1 = math.min(self.blockX1, x)
            self.blockY1 = math.min(self.blockY1, y)

            self.blockX2 = math.max(self.blockX2, x)
            self.blockY2 = math.max(self.blockY2, y)
        else
            self.blockBoundsDirty = true
        end
    end
end

function Wall:updateBlockBounds()
    if self.blockBoundsDirty then
        self.blockX1, self.blockY1 = math.huge, math.huge
        self.blockX2, self.blockY2 = -math.huge, -math.huge

        for x, column in pairs(self.blocks) do
            for y, _ in pairs(column) do
                self.blockX1 = math.min(self.blockX1, x)
                self.blockY1 = math.min(self.blockY1, y)

                self.blockX2 = math.max(self.blockX2, x)
                self.blockY2 = math.max(self.blockY2, y)
            end
        end

        self.blockBoundsDirty = false
    end
end

function Wall:updateBlocks()
    self:updateBlockBounds()

    if next(self.dirtyBlocks) then
        for x, column in pairs(self.dirtyBlocks) do
            for y, _ in pairs(column) do
                self:updateBlockFixture(x, y)
            end
        end

        self:updateCanvas()
        self.dirtyBlocks = {}
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
        local neighbor1 = common.get2(self.blocks, x - 1, y - 1)
        local neighbor2 = common.get2(self.blocks, x, y - 1)
        local neighbor3 = common.get2(self.blocks, x + 1, y - 1)
        local neighbor4 = common.get2(self.blocks, x - 1, y)

        local neighbor6 = common.get2(self.blocks, x + 1, y)
        local neighbor7 = common.get2(self.blocks, x - 1, y + 1)
        local neighbor8 = common.get2(self.blocks, x, y + 1)
        local neighbor9 = common.get2(self.blocks, x + 1, y + 1)

        if not (neighbor1 and neighbor2 and neighbor3 and neighbor4 and
                neighbor6 and neighbor7 and neighbor8 and neighbor9) then
            local blockX = (x + 0.5) * self.blockWidth
            local blockY = (y + 0.5) * self.blockHeight
            local shape = love.physics.newRectangleShape(blockX, blockY,
                self.blockWidth, self.blockHeight)

            fixture = love.physics.newFixture(self.body, shape, 1)
            fixture:setGroupIndex(self.groupIndex)
            fixture:setCategory(self.categoryIndex)
            fixture:setUserData({x = x, y = y})
        end
    end

    common.set2(self.blockFixtures, x, y, fixture)
end

function Wall:updateCanvas()
    local oldCanvas, oldCanvasOriginX, oldCanvasOriginY

    if self.canvas then
        local canvasWidth, canvasHeight = self.canvas:getDimensions()

        local pixelX1 = -self.canvasOriginX
        local pixelY1 = -self.canvasOriginY

        local pixelX2 = canvasWidth - self.canvasOriginX - 1
        local pixelY2 = canvasHeight - self.canvasOriginY - 1

        if self.blockX1 < pixelX1 or self.blockY1 < pixelY1 or
                self.blockX2 > pixelX2 or self.blockY2 > pixelY2 then
            oldCanvas = self.canvas

            oldCanvasOriginX = self.canvasOriginX
            oldCanvasOriginY = self.canvasOriginY

            self.canvas = nil
        end
    end

    if not self.canvas then
        local canvasWidth = self.blockX2 - self.blockX1 + 1
        local canvasHeight = self.blockY2 - self.blockY1 + 1

        self.canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
        self.canvas:setFilter("nearest")

        self.canvasOriginX = -self.blockX1
        self.canvasOriginY = -self.blockY1
    end

    if self.canvas then
        love.graphics.setCanvas(self.canvas)
        love.graphics.setBlendMode("replace", "premultiplied")
        love.graphics.origin()

        if oldCanvas then
            local x = self.canvasOriginX - oldCanvasOriginX
            local y = self.canvasOriginY - oldCanvasOriginY

            love.graphics.setColor(0xff, 0xff, 0xff, 0xff)
            love.graphics.draw(oldCanvas, x, y)
        end

        for x, column in pairs(self.dirtyBlocks) do
            for y, _ in pairs(column) do
                local block = common.get2(self.blocks, x, y)

                if block then
                    love.graphics.setColor(0xff, 0xff, 0xff, 0xff)
                else
                    love.graphics.setColor(0x00, 0x00, 0x00, 0x00)
                end

                local canvasX = x + self.canvasOriginX
                local canvasY = y + self.canvasOriginY

                love.graphics.rectangle("fill", canvasX, canvasY, 1, 1)
            end
        end

        love.graphics.setCanvas(nil)
        love.graphics.setColor(0xff, 0xff, 0xff, 0xff)
        love.graphics.setBlendMode("alpha", "alphamultiply")
    end
end

function Wall:getIndicesFromWorldPoint(worldX, worldY)
    local localX, localY = self.body:getLocalPoint(worldX, worldY)

    local x = math.floor(localX / self.blockWidth)
    local y = math.floor(localY / self.blockHeight)

    return x, y
end

function Wall:draw()
    if self.canvas then
        local x, y = self.body:getPosition()
        local angle = self.body:getAngle()
        local scale = 1 / 8

        love.graphics.draw(self.canvas, x, y, angle, scale, scale,
            self.canvasOriginX, self.canvasOriginY)
    end
end

return Wall

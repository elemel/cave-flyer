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

    self.blockFixtures1 = {}
    self.blockFixtures3 = {}
    self.blockFixtures5 = {}
    self.blockFixtures7 = {}
    self.blockFixtures9 = {}

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
    local fixture1 = common.get2(self.blockFixtures1, x, y)
    local fixture3 = common.get2(self.blockFixtures3, x, y)
    local fixture5 = common.get2(self.blockFixtures5, x, y)
    local fixture7 = common.get2(self.blockFixtures7, x, y)
    local fixture9 = common.get2(self.blockFixtures9, x, y)

    if fixture1 then
        fixture1:destroy()
        fixture1 = nil
    end

    if fixture3 then
        fixture3:destroy()
        fixture3 = nil
    end

    if fixture5 then
        fixture5:destroy()
        fixture5 = nil
    end

    if fixture7 then
        fixture7:destroy()
        fixture7 = nil
    end

    if fixture9 then
        fixture9:destroy()
        fixture9 = nil
    end

    local block1 = common.get2(self.blocks, x - 1, y - 1)
    local block2 = common.get2(self.blocks, x, y - 1)
    local block3 = common.get2(self.blocks, x + 1, y - 1)

    local block4 = common.get2(self.blocks, x - 1, y)
    local block5 = common.get2(self.blocks, x, y)
    local block6 = common.get2(self.blocks, x + 1, y)

    local block7 = common.get2(self.blocks, x - 1, y + 1)
    local block8 = common.get2(self.blocks, x, y + 1)
    local block9 = common.get2(self.blocks, x + 1, y + 1)

    local x1, y1 = x * self.blockWidth, y * self.blockHeight
    local x2, y2 = (x + 0.5) * self.blockWidth, (y + 0.5) * self.blockHeight
    local x3, y3 = (x + 1) * self.blockWidth, (y + 1) * self.blockHeight

    if not (block1 and block2 and block3 and block4 and block6 and block7 and block8 and block9) then
        if block5 then
            local shape = love.physics.newPolygonShape(x1, y2, x2, y3, x3, y2, x2, y1)
            fixture5 = love.physics.newFixture(self.body, shape, 1)
        end

        if block2 and block4 or block5 and (block1 or block2 or block4) then
            local shape = love.physics.newPolygonShape(x1, y1, x2, y1, x1, y2)
            fixture1 = love.physics.newFixture(self.body, shape, 1)
        end

        if block2 and block6 or block5 and (block2 or block3 or block6) then
            local shape = love.physics.newPolygonShape(x3, y1, x3, y2, x2, y1)
            fixture3 = love.physics.newFixture(self.body, shape, 1)
        end

        if block4 and block8 or block5 and (block4 or block7 or block8) then
            local shape = love.physics.newPolygonShape(x1, y3, x1, y2, x2, y3)
            fixture7 = love.physics.newFixture(self.body, shape, 1)
        end

        if block6 and block8 or block5 and (block6 or block8 or block9) then
            local shape = love.physics.newPolygonShape(x3, y3, x2, y3, x3, y2)
            fixture9 = love.physics.newFixture(self.body, shape, 1)
        end
    end

    if fixture1 then
        fixture1:setGroupIndex(self.groupIndex)
        fixture1:setCategory(self.categoryIndex)
        fixture1:setUserData({x = x, y = y})
    end

    if fixture3 then
        fixture3:setGroupIndex(self.groupIndex)
        fixture3:setCategory(self.categoryIndex)
        fixture3:setUserData({x = x, y = y})
    end

    if fixture5 then
        fixture5:setGroupIndex(self.groupIndex)
        fixture5:setCategory(self.categoryIndex)
        fixture5:setUserData({x = x, y = y})
    end

    if fixture7 then
        fixture7:setGroupIndex(self.groupIndex)
        fixture7:setCategory(self.categoryIndex)
        fixture7:setUserData({x = x, y = y})
    end

    if fixture9 then
        fixture9:setGroupIndex(self.groupIndex)
        fixture9:setCategory(self.categoryIndex)
        fixture9:setUserData({x = x, y = y})
    end

    common.set2(self.blockFixtures1, x, y, fixture1)
    common.set2(self.blockFixtures3, x, y, fixture3)
    common.set2(self.blockFixtures5, x, y, fixture5)
    common.set2(self.blockFixtures7, x, y, fixture7)
    common.set2(self.blockFixtures9, x, y, fixture9)
end

function Wall:updateCanvas()
    local oldCanvas, oldCanvasOriginX, oldCanvasOriginY

    if self.canvas then
        local canvasWidth, canvasHeight = self.canvas:getDimensions()

        local pixelX1 = -self.canvasOriginX
        local pixelY1 = -self.canvasOriginY

        local pixelX2 = canvasWidth - self.canvasOriginX - 1
        local pixelY2 = canvasHeight - self.canvasOriginY - 1

        if 3 * self.blockX1 < pixelX1 or 3 * self.blockY1 < pixelY1 or
                3 * self.blockX2 > pixelX2 or 3 * self.blockY2 > pixelY2 then
            oldCanvas = self.canvas

            oldCanvasOriginX = self.canvasOriginX
            oldCanvasOriginY = self.canvasOriginY

            self.canvas = nil
        end
    end

    if not self.canvas then
        local canvasWidth = 3 * (self.blockX2 - self.blockX1 + 1)
        local canvasHeight = 3 * (self.blockY2 - self.blockY1 + 1)

        self.canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
        self.canvas:setFilter("nearest")

        self.canvasOriginX = -3 * self.blockX1
        self.canvasOriginY = -3 * self.blockY1
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
                local canvasX = 3 * x + self.canvasOriginX
                local canvasY = 3 * y + self.canvasOriginY

                love.graphics.setColor(0x00, 0x00, 0x00, 0x00)
                love.graphics.rectangle("fill", canvasX, canvasY, 3, 3)

                local block = common.get2(self.blocks, x, y)
                local fixture5 = common.get2(self.blockFixtures5, x, y)

                if block and not fixture5 then
                    love.graphics.setColor(0xff, 0xff, 0xff, 0xff)
                    love.graphics.rectangle("fill", canvasX, canvasY, 3, 3)
                else
                    local fixture1 = common.get2(self.blockFixtures1, x, y)
                    local fixture3 = common.get2(self.blockFixtures3, x, y)
                    local fixture7 = common.get2(self.blockFixtures7, x, y)
                    local fixture9 = common.get2(self.blockFixtures9, x, y)

                    love.graphics.setColor(0xff, 0xff, 0xff, 0xff)
                    love.graphics.push()
                    love.graphics.translate(self.canvasOriginX, self.canvasOriginY)
                    love.graphics.scale(24)

                    for i, fixture in pairs({fixture1, fixture3, fixture5, fixture7, fixture9}) do
                        if fixture then
                            love.graphics.polygon("fill", fixture:getShape():getPoints())
                        end
                    end

                    love.graphics.pop()
                end
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
        local scale = 1 / 24

        love.graphics.draw(self.canvas, x, y, angle, scale, scale,
            self.canvasOriginX, self.canvasOriginY)
    end
end

return Wall

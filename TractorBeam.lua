local common = require "common"

local TractorBeam = {}
TractorBeam.__index = TractorBeam

function TractorBeam.new(args)
    local beam = setmetatable({}, TractorBeam)
    beam:init(args)
    return beam
end

function TractorBeam:init(args)
    self.game = args.game
    self.ship = args.ship
    self.body = args.body

    self.game.updateHandlers.control[self] = TractorBeam.updateControl
    -- self.game.drawHandlers.debug[self] = TractorBeam.debugDraw
end

function TractorBeam:destroy()
    self.game.drawHandlers.debug[self] = nil
    self.game.updateHandlers.control[self] = nil
end

function TractorBeam:updateControl(dt)
    if self.ship.inputs.fire2 then
        local x, y = self.body:getPosition()

        local physics = next(self.game.registry.physics)
        local terrainIndex = physics.categoryIndices.terrain
        local terrainFixtures = {}

        local function callback(fixture, x, y, normalX, normalY, fraction)
            local categoryIndex = fixture:getCategory()

            if categoryIndex == terrainIndex then
                table.insert(terrainFixtures, fixture)
            end

            return 1
        end

        local world = self.body:getWorld()
        world:rayCast(x, y, self.ship.inputs.targetX, self.ship.inputs.targetY,
            callback)

        for i, fixture in ipairs(terrainFixtures) do
            local terrain = fixture:getBody():getUserData().terrain

            local x = fixture:getUserData().x
            local y = fixture:getUserData().y

            -- terrain.wall:setBlock(x, y, nil)
            terrain.wall:updateBlockFixtures()
        end

        self.currentDelay = 0
    end
end

function TractorBeam:debugDraw()
    local x, y = self.body:getPosition()
    local targetX, targetY = self.ship.inputs.targetX, self.ship.inputs.targetY
    love.graphics.line(x, y, targetX, targetY)
end

return TractorBeam

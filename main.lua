local Camera = require "Camera"
local Game = require "Game"
local Physics = require "Physics"
local Ship = require "Ship"
local Terrain = require "Terrain"

function love.load()
    love.window.setTitle("Cave Flyer")

    love.window.setMode(800, 600, {
        -- fullscreen = true,
        fullscreentype = "desktop",
        resizable = true,
        msaa = 16,
    })

    love.physics.setMeter(1)

    game = Game.new({
        updatePhases = {"input", "control", "physics", "collision", "animation"},
        drawPhases = {"camera", "debug"},
        categories = {"camera", "physics", "terrain"},
    })

    Camera.new({
        game = game,
        scale = 0.02,
    })

    Physics.new({
        game = game,
    })

    local terrain = Terrain.new({
        game = game,
    })

    local z = 1000 * love.math.random()
    local terrainFrequency = 0.05

    for x = -20, 20 do
        for y = -20, 20 do
            local density = love.math.noise(terrainFrequency * x, terrainFrequency * y, z)

            if density > 0.5 then
                terrain.wall:setBlock(x, y, "stone")
            end
        end
    end

    terrain.wall:updateBlockFixtures()

    local ship = Ship.new({
        game = game,
    })

    ship.wall:setBlock(0, 0, "metal")
    ship.wall:setBlock(-1, 0, "metal")
    ship.wall:setBlock(0, 1, "metal")
    ship.wall:updateBlockFixtures()
    ship:updateTurnJoint()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

local Ai = require "Ai"
local Camera = require "Camera"
local Collider = require "Collider"
local common = require "common"
local Game = require "Game"
local Physics = require "Physics"
local Player = require "Player"
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
        tags = {"camera", "physics", "terrain"},
    })

    local camera = Camera.new({
        game = game,
        scale = 1 / 8,
    })

    local physics = Physics.new({
        game = game,
        categories = {"unknown", "bullet", "ship", "terrain"},
    })

    local collider = Collider.new({
        game = game,
        physics = physics,
    })

    local terrain = Terrain.new({
        game = game,
    })

    local z = 1000 * love.math.random()
    local terrainFrequency = 0.05

    for x = -20, 20 do
        for y = -20, 20 do
            local density = common.fbm3(terrainFrequency * x, terrainFrequency * y, z)

            if density > 0.5 then
                terrain.wall:setBlock(x, y, "stone")
            end
        end
    end

    terrain.wall:updateBlockFixtures()

    local ship = Ship.new({
        game = game,
        groupIndex = -physics:generateGroupIndex(),
    })

    Player.new({
        game = game,
        ship = ship,
        camera = camera,
    })

    local enemyShip = Ship.new({
        game = game,
        x = 1, y = 1,
        groupIndex = -physics:generateGroupIndex(),
    })

    Ai.new({
        game = game,
        ship = enemyShip,
    })
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

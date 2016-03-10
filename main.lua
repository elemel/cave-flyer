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
        highdpi = true,
    })

    love.physics.setMeter(1)

    game = Game.new({
        updatePhases = {"input", "control", "physics", "collision", "animation"},
        drawPhases = {"camera", "wall", "debug"},
        tags = {"camera", "physics", "terrain"},
    })

    local camera = Camera.new({
        game = game,
        scale = 1 / 32,
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
    local radius = 512

    for x = -radius, radius - 1 do
        for y = -radius, radius - 1 do
            local distance = common.length2(x + 0.5, y + 0.5)

            if distance < radius then
                local density = common.fbm3(terrainFrequency * (x + 0.5), terrainFrequency * (y + 0.5), z)
                local threshold = 0.75 - 0.25 * common.smoothstep(radius / 3, 2 * radius / 3, distance)

                if density < threshold then
                    terrain.wall:setBlock(x, y, "stone")
                end
            end
        end
    end

    terrain.wall:updateBlocks()

    local ship = Ship.new({
        game = game,
        x = 64, y = 64,
        groupIndex = -physics:generateGroupIndex(),
    })

    Player.new({
        game = game,
        ship = ship,
        camera = camera,
    })

    local enemyShip = Ship.new({
        game = game,
        x = 65, y = 65,
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

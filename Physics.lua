local Physics = {}
Physics.__index = Physics

function Physics.new(args)
    local physics = setmetatable({}, Physics)
    physics:init(args)
    return physics
end

function Physics:init(args)
    self.game = args.game
    self.name = args.name
    self.categories = args.categories

    local gravityX, gravityY = args.gravityX or 0, args.gravityY or 0
    self.world = love.physics.newWorld(gravityX, gravityY, true)
    self.ground = love.physics.newBody(self.world)

    self.game.updateHandlers.physics[self] = Physics.update
    self.game.drawHandlers.debug[self] = Physics.debugDraw
    self.game:register(self, self.name, self.categories)
end

function Physics:destroy()
    self.game:deregister(self, self.name, self.categories)
    self.game.drawHandlers.debug[self] = nil
    self.game.updateHandlers.physics[self] = nil
    self.world:destroy()
end

function Physics:update(dt)
    self.world:update(dt)
end

function Physics:debugDraw()
    for i, body in ipairs(self.world:getBodyList()) do
        for j, fixture in ipairs(body:getFixtureList()) do
            local shape = fixture:getShape()

            if shape:getType() == "polygon" then
                love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
            end
        end
    end
end

return Physics

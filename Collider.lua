local Collider = {}
Collider.__index = Collider

function Collider.new(args)
    local collider = setmetatable({}, Collider)
    collider:init(args)
    return collider
end

function Collider:init(args)
    self.game = args.game
    self.physics = args.physics
    self.world = self.physics.world
    self.tasks = {}

    local function beginContact(...)
        self:beginContact(...)
    end

    self.world:setCallbacks(beginContact)
    self.game.updateHandlers.collision[self] = Collider.update
 end

function Collider:destroy()
    self.game.updateHandlers.collision[self] = nil
    self.world:setCallbacks()
end

function Collider:beginContact(fixture1, fixture2, contact)
    local index1, index2 = fixture1:getCategory(), fixture2:getCategory()

    local category1 = assert(self.physics.categories[index1])
    local category2 = assert(self.physics.categories[index2])

    if category1 == "bullet" and category2 == "terrain" then
        self:collideBulletAndTerrain(fixture1, fixture2)
    end

    if category1 == "terrain" and category2 == "bullet" then
        self:collideBulletAndTerrain(fixture2, fixture1)
    end
end

function Collider:collideBulletAndTerrain(bulletFixture, terrainFixture)
    local bulletBody = bulletFixture:getBody()
    local terrainBody = terrainFixture:getBody()

    local bullet = bulletBody:getUserData().bullet
    local terrain = terrainBody:getUserData().terrain
    local x = terrainFixture:getUserData().x
    local y = terrainFixture:getUserData().y

    local function task()
        if not bullet.destroyed then
            bullet:destroy()

            terrain.wall:setBlock(x, y, nil)
            terrain.wall:updateBlockFixtures()
        end
    end

    table.insert(self.tasks, task)
end

function Collider:update(dt)
    if next(self.tasks) then
        for i, task in ipairs(self.tasks) do
            task()
        end

        self.tasks = {}
    end
end

return Collider

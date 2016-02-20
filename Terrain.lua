local Wall = require "Wall"

local Terrain = {}
Terrain.__index = Terrain

function Terrain.new(args)
    local terrain = setmetatable({}, Terrain)
    terrain:init(args)
    return terrain
end

function Terrain:init(args)
    self.game = args.game
    self.categories = args.categories or {"terrain"}

    self.wall = Wall.new({
        game = self.game,
    })

    self.game:register(self, self.categories)
end

function Terrain:destroy()
    self.game:deregister(self, self.categories)
    self.wall:destroy()
end

return Terrain
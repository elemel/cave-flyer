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
    self.tags = args.tags or {"terrain"}

    self.wall = Wall.new({
        game = self.game,
        category = "terrain",
    })

    self.game:register(self, self.tags)
end

function Terrain:destroy()
    self.game:deregister(self, self.tags)
    self.wall:destroy()
end

return Terrain